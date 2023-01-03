enum CellState {
    case alive, dead
}

class Cell {
    let x: Int
    let y: Int

    var state: CellState

    var neighbours: [Cell] = .init()

    init(state: CellState, x: Int, y: Int) {
        self.state = state
        self.x = x
        self.y = y
    }
}

extension Cell: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(x.hashValue ^ y.hashValue)
    }

    static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
