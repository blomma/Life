enum CellState {
	case alive, dead
}

struct Cell {
	let state: CellState
	let x: Int
	let y: Int
}

func ==(lhs: Cell, rhs: Cell) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

extension Cell: Hashable {
	var hashValue: Int {
		return x.hashValue ^ y.hashValue
	}
}
