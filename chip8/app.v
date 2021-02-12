module chip8

import gg
import gx
import os
import time

pub struct App {
pub mut:
	context &gg.Context
	width int
	height int
	scale_factor int
	cpu &CPU
	ram &RAM
	gfx &Gfx
	input &Input
}

pub fn (mut app App) load_rom(path string) {
	rom := os.read_file(path) or { panic(err) }

	for i, val in rom.bytes() {
		app.ram.write(u16(i + app.cpu.pc), val)
	}
}

pub fn (mut app App) game_loop() {
	for {
		opcode := u16(app.ram.read(app.cpu.pc)) << 8 | u16(app.ram.read(app.cpu.pc + 1))
		results := app.cpu.process_opcode(opcode, mut app)

		if results.clear_screen {
			app.gfx.clear()
		}

		if results.play_sound {
			// TODO
		}

		// TODO figure out better way to get constant framerate
		time.sleep_ms(16)
	}
}

pub fn (mut app App) draw() {
	gfx := app.gfx
	scale_factor := app.scale_factor

	for row in 0..app.height {
		for col in 0..app.width {
			if gfx.vram[row][col] == 1 {
				app.context.draw_rect(col * scale_factor, row * scale_factor, scale_factor, scale_factor, gx.white)
			}
		}
	}
}

pub fn (mut app App) start() {
	go app.game_loop()
	app.context.run()
}