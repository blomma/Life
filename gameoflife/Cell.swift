enum CellState {
	case Alive, Dead
}

class Cell {
	var state: CellState
    
    init(state: CellState) {
        self.state = state
    }   
}
