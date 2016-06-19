enum CellState {
	case alive, dead
}

class Cell {
	let x: Int
	let y: Int
	
	var state: CellState
	var neighbours: [Cell]
	
	init(state: CellState, x: Int, y: Int) {
		self.state = state
		self.x = x
		self.y = y
		self.neighbours = [Cell]()
	}
}

func ==(lhs: Cell, rhs: Cell) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

extension Cell: Hashable {
	var hashValue: Int {
		return x.hashValue ^ y.hashValue
	}
}
