enum CellState {
	case Alive, Dead
}

struct Cell {
	let state: CellState

    init(state: CellState) {
        self.state = state
    }
}
