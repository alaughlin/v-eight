module machine

struct Input {
pub mut:
	keys []byte
}

fn initialize_input() &Input {
	return &Input{
		keys: []byte{
			len: 16,
			init: 0
		}
	}
}