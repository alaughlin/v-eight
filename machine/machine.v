module machine

import os
import time

struct Machine {
mut:
	cpu &CPU
	ram &RAM
	input &Input
	window &Window
}

pub fn initialize() &Machine {
	return &Machine{
		cpu: initialize_cpu()
		ram: initialize_ram()
		input: initialize_input()
		window: initialize_window()
	}
}

pub fn (mut machine Machine) load_rom(path string) {
	rom := os.read_file(path) or { panic(err) }

	for i, val in rom.bytes() {
		machine.ram.write(u16(i + machine.cpu.pc), val)
	}
}

fn (mut machine Machine) game_loop() {
	for {
		opcode := u16(machine.ram.read(machine.cpu.pc)) << 8 | u16(machine.ram.read(machine.cpu.pc + 1))
		results := machine.cpu.process_opcode(opcode, mut machine.ram, mut machine.window, mut machine.input)

		if results.clear_screen {
			machine.window.clear()
		}

		if results.play_sound {
			// TODO
		}

		// TODO figure out better way to get constant framerate
		time.sleep_ms(16)
	}
}

pub fn (mut machine Machine) start() {
	go machine.game_loop()
	machine.window.run()
}