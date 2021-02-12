import chip8
import gg
import gx
import sokol.sapp

fn main() {
	width := 64
	height := 32
	scale_factor := 10

	mut app := &chip8.App{
		context: 0
		width: width
		height: height
		scale_factor: scale_factor
		cpu: chip8.initialize_cpu()
		ram: chip8.initialize_ram()
		gfx: chip8.initialize_gfx(width, height)
		input: chip8.initialize_input()
	}

	app.context = gg.new_context({
		bg_color: gx.black
		width: width * scale_factor
		height: height * scale_factor
		use_ortho: true
		create_window: true
		window_title: 'CHIP-8'
		event_fn: on_event
		frame_fn: frame
		user_data: app
	})

	app.load_rom('roms/pong.rom')
	app.start()
}

fn on_event(e &sapp.Event, mut app chip8.App) {
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

fn frame(mut app chip8.App) {
	app.context.begin()
	app.draw()
	app.context.end()
}