module machine

import gg
import gx
import sokol.sapp

struct Window {
pub mut:
	vram [][]byte
	width int
	height int
	scale_factor int
mut:
	context &gg.Context
}

fn (mut window Window) draw() {
	scale_factor := window.scale_factor
	for row in 0..window.height {
		for col in 0..window.width {
			if window.vram[row][col] == 1 {
				window.context.draw_rect(col * scale_factor, row * scale_factor, scale_factor, scale_factor, gx.white)
			}
		}
	}
}

fn (mut window Window) clear() {
	window.vram = [][]byte{
		len: window.height,
		init: []byte{
			len: window.width,
			init: 0
		}
	}
	window.draw()
}

fn initialize_window() &Window {
	width := 64
	height := 32
	scale_factor := 10

	mut window := &Window{
		context: gg.new_context({
			bg_color: gx.black
			width: width * scale_factor
			height: height * scale_factor
			use_ortho: true
			create_window: true
			window_title: 'CHIP-8'
			event_fn: on_event
		})
		vram: [][]byte{
			len: height,
			init: []byte{
				len: width,
				init: 0
			}
		}
		width: width
		height: height
		scale_factor: scale_factor

	}

	return window
}

fn on_event(e &sapp.Event, mut window Window) {
	println('code=$e.char_code')
	// if e.typ == .key_down {
	// 	game.key_down(e.key_code)
	// }
	// if e.typ == .touches_began || e.typ == .touches_moved {
	// 	if e.num_touches > 0 {
	// 		touch_point := e.touches[0]
	// 		game.touch_event(touch_point)
	// 	}
	// }
}

pub fn (mut window Window) run() {
	window.context.run()
}