import machine

fn main() {
	mut machine := machine.initialize()
	machine.load_rom('roms/pong.rom')
	machine.start()
}