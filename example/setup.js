import * as wasm from "../wasm/runtime.js"

import {IS_DEV, WEB_SOCKET_PORT, MESSAGE_RELOAD, WASM_FILENAME} from "./_config.js"

/*
Development server
*/

if (IS_DEV) {
	wasm.enableConsole()

	/* Hot Reload */
	new WebSocket("ws://localhost:" + WEB_SOCKET_PORT).addEventListener(
		"message",
		event => event.data === MESSAGE_RELOAD && location.reload(),
	)

	/* To test dispatching custom events */
	document.body.addEventListener("lol", () => {
		console.log("lol event has been received")
	})
}

/*
Example selection
*/

/** @enum {(typeof Example_Kind)[keyof typeof Example_Kind]} */
const Example_Kind = /** @type {const} */ ({
	Rectangle : 0,
	Pyramid   : 1,
	Boxes     : 2,
	Camera    : 3,
	Lighting  : 4,
	Specular  : 5,
	Spotlight : 6,
	Candy     : 7,
	Sol_System: 8,
})
/** @type {Example_Kind[]} */
const example_kinds = Object.values(Example_Kind)

/** @type {Record<Example_Kind, string>} */
const example_kind_href_hashes = {
	[Example_Kind.Rectangle] : "#rectangle",
	[Example_Kind.Pyramid]   : "#pyramid",
	[Example_Kind.Boxes]     : "#boxes",
	[Example_Kind.Camera]    : "#camera",
	[Example_Kind.Lighting]  : "#lighting",
	[Example_Kind.Specular]  : "#specular",
	[Example_Kind.Spotlight] : "#spotlight",
	[Example_Kind.Candy]     : "#candy",
	[Example_Kind.Sol_System]: "#sol-system",
}

/** @type {Example_Kind} */
let example_kind = Example_Kind.Boxes

for (const kind of example_kinds) {
	const hash = example_kind_href_hashes[kind]
	if (location.hash === hash) {
		example_kind = kind
		break
	}
}

for (const kind of example_kinds) {
	const hash = example_kind_href_hashes[kind]
	const anchor = document.querySelector(`a[href="${hash}"]`)
	if (!anchor) continue

	anchor.addEventListener("click", event => {
		event.preventDefault()
		location.hash = hash
	})

	if (example_kind === kind) {
		anchor.classList.add("active")
	}
}

/* Reload on hash change */
window.addEventListener("hashchange", () => location.reload())

/*
Wasm instance
*/

/**
 * @typedef  {object}                   Example_Exports
 * @property {Example_Start           } start
 * @property {Example_Frame           } frame
 * @property {Example_On_Window_Resize} on_window_resize
 *
 * @typedef {wasm.OdinExports & Example_Exports} Wasm_Exports
 *
 * @callback Example_Start
 * @param   {wasm.rawptr } ctx_ptr
 * @param   {Example_Kind} example_type
 * @returns {wasm.bool   }
 *
 * @callback Example_Frame
 * @param   {wasm.rawptr} ctx_ptr
 * @param   {wasm.f32   } delta
 * @returns {void       }
 *
 * @callback Example_On_Window_Resize
 * @param   {wasm.f32} window_w
 * @param   {wasm.f32} window_h
 * @param   {wasm.f32} canvas_w
 * @param   {wasm.f32} canvas_h
 * @param   {wasm.f32} canvas_x
 * @param   {wasm.f32} canvas_y
 * @returns {void    }
 */

const wasm_state = wasm.makeWasmState()
const webgl_state = wasm.webgl.makeWebGLState()

const src_instance = await wasm.fetchInstanciateWasm(WASM_FILENAME, {
	env: {}, // TODO
	odin_env: wasm.env.makeOdinEnv(wasm_state),
	odin_dom: wasm.dom.makeOdinDOM(wasm_state),
	webgl   : wasm.webgl.makeOdinWebGL(wasm_state, webgl_state),
	webgl2  : wasm.webgl.makeOdinWegGL2(wasm_state, webgl_state),
})

wasm.initWasmState(wasm_state, src_instance)
const exports = /** @type {Wasm_Exports} */ (wasm_state.exports)

if (IS_DEV) {
	console.log("WASM exports:", exports)
	console.log("WASM memory:", exports.memory)
}

/*
Main
*/

exports._start() // Calls main
const odin_ctx = exports.default_context_ptr()
/* _end() should be called when the program is done */
// exports._end()

const ok = exports.start(odin_ctx, example_kind)
if (!ok) throw Error("Failed to start example")

void requestAnimationFrame(prev_time => {
	/** @type {FrameRequestCallback} */
	const frame = time => {
		const delta = time - prev_time
		prev_time = time
		exports.frame(odin_ctx, delta)
		void requestAnimationFrame(frame)
	}

	void requestAnimationFrame(frame)
})

const canvas = /** @type {HTMLCanvasElement} */ (document.getElementById("canvas"))
const dpr = window.devicePixelRatio || 1

function updateCanvasSize() {
	const rect = canvas.getBoundingClientRect()
	canvas.width  = rect.width * dpr
	canvas.height = rect.height * dpr
	exports.on_window_resize(
		window.innerWidth,
		window.innerHeight,
		rect.width,
		rect.height,
		rect.left,
		rect.top,
	)
}
updateCanvasSize()
window.addEventListener("resize", updateCanvasSize)
