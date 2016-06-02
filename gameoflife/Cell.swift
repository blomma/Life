infix operator !~= {}
func !~= <I : IntervalType>(value: I.Bound, pattern: I) -> Bool {
	return !(pattern ~= value)
}

enum CellState {
	case Alive, Dead
}

struct Cell {
	let x: Int
	let y: Int
	let state: CellState
}

extension Cell: Equatable {}

func ==(lhs: Cell, rhs: Cell) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}
