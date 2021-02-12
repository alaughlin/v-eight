module chip8

struct Gfx {
pub mut:
	vram [][]byte
	width int
	height int
}

pub fn initialize_gfx(width int, height int) &Gfx {
	return &Gfx{
		vram: [][]byte{
			len: height,
			init: []byte{
				len: width,
				init: 0
			}
		}
		width: width
		height: height
	}
}

pub fn (mut gfx Gfx) clear() {
	gfx.vram = [][]byte{
		len: gfx.height,
		init: []byte{
			len: gfx.width,
			init: 0
		}
	}
}