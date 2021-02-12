module machine

import rand

struct OpcodeResults {
mut:
	clear_screen bool
	draw_screen bool
	play_sound bool
}

struct CPU {
pub mut:
	pc u16
	opcode byte
	i u16
	v [16]byte
	delay_timer byte
	sound_timer byte
	stack []u16
}

fn initialize_cpu() &CPU {
	return &CPU{
		pc: 0x200
		opcode: 0
		i: 0
		v: [16]byte{}
		delay_timer: 0
		sound_timer: 0
		stack: []u16{cap: 16}
	}
}

pub fn (mut cpu CPU) process_opcode(opcode u16, mut ram RAM, mut window Window, mut input Input) OpcodeResults {
	mut clear_screen := false
	mut draw_screen := false
	mut play_sound := false

	n := byte(opcode & 0x000F)
	nn := byte(opcode & 0x00FF)
	nnn := opcode & 0x0FFF
	x := byte((opcode & 0x0F00) >> 8)
	y := byte((opcode & 0x00F0) >> 4)

	match (opcode & 0xF000) >> 12 {
		0x0 {
			match nn {
				0xE0 {
					clear_screen = true
					cpu.pc += 2
				}
				0xEE {
					cpu.pc = cpu.stack[cpu.stack.len - 1]
					cpu.stack = cpu.stack[..cpu.stack.len - 1]
				}
				else {}
			}
		}
		0x1 { cpu.pc = nnn }
		0x2 {
			cpu.stack << cpu.pc + 2
			cpu.pc = nnn
		}
		0x3 {
			if cpu.v[x] == nn {
				cpu.pc += 4
			} else {
				cpu.pc += 2
			}
		}
		0x4 {
			if cpu.v[x] != nn {
				cpu.pc += 4
			} else {
				cpu.pc += 2
			}
		}
		0x5 {
			if cpu.v[x] == cpu.v[y] {
				cpu.pc += 4
			} else {
				cpu.pc += 2
			}
		}
		0x6 {
			cpu.v[x] = nn
			cpu.pc += 2
		}
		0x7 {
			cpu.v[x] += nn
			cpu.pc += 2
		}
		0x8 {
			match opcode & 0x000F {
				0x0 { cpu.v[x] = cpu.v[y] }
				0x1 { cpu.v[x] |= cpu.v[y] }
				0x2 { cpu.v[x] &= cpu.v[y] }
				0x3 { cpu.v[x] ^= cpu.v[y] }
				0x4 {
					res := int(cpu.v[x]) + int(cpu.v[y])
					if res > 255 {
						cpu.v[0xF] = 1
					} else {
						cpu.v[0xF] = 0
					}
					cpu.v[x] = byte(res)
				}
				0x5 {
					res := int(cpu.v[y]) - int(cpu.v[x])
					if res < 0 {
						cpu.v[0xF] = 0
					} else {
						cpu.v[0xF] = 1
					}
					cpu.v[x] = byte(res)
				}
				0x6 {
					cpu.v[0xF] = cpu.v[x] << 7
					cpu.v[x] >> 1
				}
				0x7 {
					res := int(cpu.v[x]) - int(cpu.v[y])
					if res < 0 {
						cpu.v[0xF] = 0
					} else {
						cpu.v[0xF] = 1
					}
					cpu.v[x] = byte(res)
				}
				0xE {
					cpu.v[0xF] = cpu.v[x] >> 7
					cpu.v[x] <<= 1 
				}
				else {}
			}
			cpu.pc += 2
		}
		0x9 {
			if cpu.v[x] != cpu.v[y] {
				cpu.pc += 4
			} else {
				cpu.pc += 2
			}
		}
		0xA {
			cpu.i = nnn
			cpu.pc += 2
		}
		0xB {
			cpu.pc = nnn + cpu.v[0]
		}
		0xC {
			cpu.v[x] = byte(rand.intn(255))
			cpu.pc += 2
		}
		0xD {
			for i in 0..n {
				row := (cpu.v[y] + i) % window.height
				for bit in 0..8 {
					col := (cpu.v[x] + bit) % window.width
					color := (ram.read(u16(cpu.i + row)) >> (7 - bit)) & 1
					cpu.v[0xF] |= color & window.vram[row][col]
					window.vram[row][col] ^= color
            	}
			}
			draw_screen = true
			cpu.pc += 2
		}
		0xE {
			match opcode & 0x00FF {
				0x9E {
					if input.keys[x] == 1 {
						cpu.pc += 4
					} else {
						cpu.pc += 2
					}
				}
				0xE1 {
					if input.keys[x] == 1 {
						cpu.pc += 2
					} else {
						cpu.pc += 4
					}
				}
				else {}
			}
		}
		0xF {
			match opcode & 0x00FF {
				0x07 {
					cpu.v[x] = cpu.delay_timer
					cpu.pc += 2
				}
				0x0A {
					for i in input.keys {
						key := input.keys[i]
						if key == 1 {
							cpu.v[x] = key
							cpu.pc += 2
							break
						}
					}
				}
				0x15 {
					cpu.delay_timer = cpu.v[x]
					cpu.pc += 2
				}
				0x18 {
					cpu.sound_timer = cpu.v[x]
					cpu.pc += 2
				}
				0x1E {
					cpu.i += cpu.v[x]
					cpu.pc += 2
				}
				0x29 {
					cpu.i = cpu.v[x] * 5
					cpu.pc += 2
				}
				0x33 {
					ram.write(cpu.i, cpu.v[x] / 100)
					ram.write(cpu.i + 1, cpu.v[x] % 100 / 10)
					ram.write(cpu.i + 2, cpu.v[x] % 100 % 10)
					cpu.pc += 2
				}
				0x55 {
					for i in 0..x {
						ram.write(u16(cpu.i + i), cpu.v[i])
					}
					cpu.pc += 2
				}
				0x65 {
					for i in 0..x {
						cpu.v[i] = ram.read(u16(cpu.i + i))
					}
					cpu.pc += 2
				}
				else {}
			}
		}
		else {}
	}

	if cpu.delay_timer > 0 {
		cpu.delay_timer--
	}

	if cpu.sound_timer > 0 {
		if cpu.sound_timer == 1 {
			play_sound = true
		}
		cpu.sound_timer--
	}

	return OpcodeResults{
		clear_screen: clear_screen
		draw_screen: draw_screen
		play_sound: play_sound
	}
}