import * as fs from "node:fs"
import * as fsp from "node:fs/promises"
import * as path from "node:path"
import * as url from "node:url"
import * as http from "node:http"
import * as child_process from "node:child_process"
import * as chokidar from "chokidar"
import * as ws from "ws"
import * as rollup from "rollup"
import * as terser from "terser"

import {
	DIST_DIRNAME,
	CONFIG_FILENAME,
	HTTP_PORT,
	MESSAGE_RELOAD,
	PACKAGE_DIRNAME,
	PLAYGROUND_DIRNAME,
	WASM_PATH,
	WEB_SOCKET_PORT,
	CONFIG_OUT_FILENAME,
	SCRIPT_FILENAME,
	WASM_FILENAME,
} from "./config.js"

const dirname = path.dirname(url.fileURLToPath(import.meta.url))
const playground_path = path.join(dirname, PLAYGROUND_DIRNAME)
const dist_path = path.join(dirname, DIST_DIRNAME)
const config_path = path.join(dirname, CONFIG_FILENAME)
const config_out_path = path.join(playground_path, CONFIG_OUT_FILENAME)

/** @enum {string} */
const Command = {
	Dev: "dev",
	Server: "server",
	Build: "build",
}

/** @type {Record<Command, (args: string[]) => void>} */
const command_handlers = {
	[Command.Dev]() {
		/** @type {child_process.ChildProcess} */
		let child = makeChildServer()

		const watcher = chokidar.watch(["./*.js"], {
			ignored: "**/.*",
			ignoreInitial: true,
		})
		void watcher.on("change", () => {
			// eslint-disable-next-line no-console
			console.log("Stopping server...")
			const ok = child.kill("SIGINT")
			// eslint-disable-next-line no-console
			if (!ok) console.log("Failed to kill server")

			child = makeChildServer()
		})
	},
	[Command.Server]() {
		/* Make sure the dist dir exists */
		void fs.mkdirSync(dist_path, {recursive: true})

		const server = http.createServer(requestListener).listen(HTTP_PORT)
		const wss = new ws.WebSocketServer({port: WEB_SOCKET_PORT})

		// eslint-disable-next-line no-console
		console.log(`
Server running at http://127.0.0.1:${HTTP_PORT}
WebSocket server running at http://127.0.0.1:${WEB_SOCKET_PORT}
`)

		let wasm_build_promise = buildWASM(WASM_PATH)
		const config_promise = buildConfig(true)

		const watcher = chokidar.watch(
			[`./${PLAYGROUND_DIRNAME}/**/*.{js,html,odin}`, `./${PACKAGE_DIRNAME}/**/*.{js,odin}`],
			{
				ignored: ["**/.*", "**/_*", "**/*.test.js"],
				ignoreInitial: true,
			},
		)
		void watcher.on("change", filepath => {
			if (filepath.endsWith(".odin")) {
				// eslint-disable-next-line no-console
				console.log("Rebuilding WASM...")
				wasm_build_promise = buildWASM(WASM_PATH)
			}
			// eslint-disable-next-line no-console
			console.log("Reloading page...")
			sendToAllClients(wss, MESSAGE_RELOAD)
		})

		void process.on("SIGINT", () => {
			void server.close()
			void wss.close()
			void watcher.close()
			sendToAllClients(wss, MESSAGE_RELOAD)
			void process.exit(0)
		})

		/** @returns {Promise<void>} */
		async function requestListener(
			/** @type {http.IncomingMessage} */ req,
			/** @type {http.ServerResponse} */ res,
		) {
			if (!req.url || req.method !== "GET") return end404()

			if (req.url === "/" + CONFIG_FILENAME) {
				await config_promise
			} else if (req.url === "/" + WASM_FILENAME) {
				const code = await wasm_build_promise
				if (code !== 0) return end404()
			} else if (req.url === "/" || req.url === "/index.html") {
				req.url = "/" + PLAYGROUND_DIRNAME + "/index.html"
			}

			/* Static files */
			const relative_filepath = toWebFilepath(req.url)
			const filepath = path.join(dirname, relative_filepath)

			const exists = await fileExists(filepath)
			if (!exists) return end404()

			const ext = toExt(filepath)
			const mime_type = mimeType(ext)
			void res.writeHead(200, {"Content-Type": mime_type})

			const stream = fs.createReadStream(filepath)
			void stream.pipe(res)

			// eslint-disable-next-line no-console
			console.log(`${req.method} ${req.url} 200`)
		}

		function end404(
			/** @type {http.IncomingMessage} */ req,
			/** @type {http.ServerResponse} */ res,
		) {
			void res.writeHead(404)
			void res.end()
			// eslint-disable-next-line no-console
			console.log(`${req.method} ${req.url} 404`)
		}
	},
	async [Command.Build]() {
		const wasm_promise = buildWASM(DIST_DIRNAME + "/" + WASM_FILENAME)
		const config_promise = buildConfig(false)

		const [wasm_res] = await Promise.all([wasm_promise, config_promise])

		// eslint-disable-next-line @nothing-but/no-ignored-return
		if (wasm_res != 0) panic("Failed to build WASM, code:", wasm_res)

		const bundle_res = await safeRollupBundle({
			input: path.join(playground_path, "index.js"),
		})
		// eslint-disable-next-line @nothing-but/no-ignored-return
		if (bundle_res instanceof Error) panic("Failed to bundle, error:", bundle_res)

		const generate_res = await safeRollupGenerate(bundle_res, {})
		// eslint-disable-next-line @nothing-but/no-ignored-return
		if (generate_res instanceof Error) panic("Failed to generate, error:", generate_res)

		/** @type {rollup.OutputAsset[]} */
		const assets = []
		/** @type {rollup.OutputChunk[]} */
		const chunks = []

		for (const output of generate_res.output) {
			if (output.type === "asset") assets.push(output)
			else chunks.push(output)
		}

		/** @type {Promise<void>[]} */
		const promises = []

		for (const asset of assets) {
			const filepath = path.join(dist_path, asset.fileName)
			promises.push(fsp.writeFile(filepath, asset.source))
		}

		const should_minify = /** @type {boolean} */ (true)
		if (should_minify) {
			for (const chunk of chunks) {
				const filepath = path.join(dist_path, chunk.fileName)
				const minified = terser.minify(chunk.code, {module: true})
				promises.push(
					// eslint-disable-next-line @nothing-but/no-return-to-void
					minified.then(output =>
						output.code ? fsp.writeFile(filepath, output.code) : void 0,
					),
				)
			}
		} else {
			for (const chunk of chunks) {
				const filepath = path.join(dist_path, chunk.fileName)
				promises.push(fsp.writeFile(filepath, chunk.code))
			}
		}

		await Promise.all(promises) // TODO error handling

		void bundle_res.close()

		// eslint-disable-next-line no-console
		console.log("Build complete")
	},
}

const args = process.argv.slice(2)
const command = args[0]
// eslint-disable-next-line @nothing-but/no-ignored-return
if (!command) panic("Command not specified")

const command_handler = command_handlers[command]
// eslint-disable-next-line @nothing-but/no-ignored-return
if (!command_handler) panic("Unknown command", command)

command_handler(args.slice(1))

/** @returns {child_process.ChildProcess} */
function makeChildServer() {
	return child_process.spawn("node", [SCRIPT_FILENAME, Command.Server], {
		stdio: "inherit",
	})
}

/**
 * @param   {string}          dist_path
 * @returns {Promise<number>}           exit code
 */
function buildWASM(dist_path) {
	const child = child_process.execFile(
		"odin",
		["build", playground_path, "-out:" + dist_path, "-target:js_wasm32"],
		{cwd: dirname},
	)
	child.stderr?.on("data", data => {
		// eslint-disable-next-line no-console
		console.error(data.toString())
	})
	return childProcessToPromise(child)
}

/**
 * Copy the config file to the playground source dir, with a correct env mode.
 *
 * @param   {boolean}       is_dev
 * @returns {Promise<void>}
 */
async function buildConfig(is_dev) {
	const content = await fsp.readFile(config_path, "utf8")
	const corrected =
		"export const IS_DEV = /** @type {boolean} */ (" + is_dev + ")\n" + shiftLines(content, 1)
	await fsp.writeFile(config_out_path, corrected)
}

/** @returns {Promise<rollup.RollupBuild | Error>} */
function safeRollupBundle(/** @type {rollup.RollupOptions} */ options) {
	return rollup.rollup(options).then(
		// eslint-disable-next-line @nothing-but/no-return-to-void
		build => build,
		// eslint-disable-next-line @nothing-but/no-return-to-void
		error => error,
	)
}

/**
 * @param   {rollup.RollupBuild}                   build
 * @param   {rollup.OutputOptions}                 options
 * @returns {Promise<rollup.RollupOutput | Error>}
 */
function safeRollupGenerate(build, options) {
	return build.generate(options).then(
		// eslint-disable-next-line @nothing-but/no-return-to-void
		output => output,
		// eslint-disable-next-line @nothing-but/no-return-to-void
		error => error,
	)
}

/** @returns {never} */
function panic(/** @type {any[]} */ ...message) {
	// eslint-disable-next-line no-console
	console.error(...message)
	// eslint-disable-next-line @nothing-but/no-ignored-return
	process.exit(1)
}

/** @typedef {Parameters<ws.WebSocket["send"]>[0]} BufferLike */

/** @returns {void} */
function sendToAllClients(/** @type {ws.WebSocketServer} */ wss, /** @type {BufferLike} */ data) {
	for (const client of wss.clients) {
		client.send(data)
	}
}

/** @returns {string} */
function mimeType(/** @type {string} */ ext) {
	switch (ext) {
		case "html":
			return "text/html; charset=UTF-8"
		case "js":
		case "mjs":
			return "application/javascript"
		case "json":
			return "application/json"
		case "wasm":
			return "application/wasm"
		case "css":
			return "text/css"
		case "png":
			return "image/png"
		case "jpg":
			return "image/jpg"
		case "gif":
			return "image/gif"
		case "ico":
			return "image/x-icon"
		case "svg":
			return "image/svg+xml"
		default:
			return "application/octet-stream"
	}
}

function trueFn() {
	return true
}
function falseFn() {
	return false
}

/** @returns {Promise<boolean>} */
function unsafePromiseToBool(/** @type {Promise<any>} */ promise) {
	return promise.then(trueFn, falseFn)
}

/** @returns {Promise<number>} Exit code */
function childProcessToPromise(/** @type {child_process.ChildProcess} */ child) {
	return new Promise(resolve => {
		void child.on("close", resolve)
	})
}

/** @returns {string} */
function toWebFilepath(/** @type {string} */ path) {
	return path.endsWith("/") ? path + "index.html" : path
}

/** @returns {Promise<boolean>} */
function fileExists(/** @type {string} */ filepath) {
	return unsafePromiseToBool(fsp.access(filepath))
}

/** @returns {string} */
function toExt(/** @type {string} */ filepath) {
	return path.extname(filepath).substring(1).toLowerCase()
}

/** @returns {string} */
function shiftLines(/** @type {string} */ str, /** @type {number} */ lines) {
	while (lines > 0) {
		str = str.substring(str.indexOf("\n") + 1)
		lines--
	}

	return str
}
