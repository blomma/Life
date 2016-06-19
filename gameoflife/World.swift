struct World {
	private let m: Matrix<CellState>

	init(width: Int, height: Int) {
		m = Matrix<CellState>(width: width, height: height, repeatValue: .dead)
	}

	func update(cell: Cell) {
		m[cell.x, cell.y] = cell.state
	}

	func update() -> (dyingCells: [Cell], bornCells: [Cell]) {
		var dyingCells: [Cell] = [Cell]()
		var bornCells: [Cell] = [Cell]()
		
		for (x, y, state) in m {
			let neighbours = livingNeighboursForCell(x: x, y: y)
			if state == .alive {
				if neighbours < 2 || neighbours > 3 {
					m[x, y] = .dead
					dyingCells.append(Cell(state: .dead, x: x, y: y))
				}
			} else {
				if neighbours == 3 {
					m[x, y] = .alive
					bornCells.append(Cell(state: .alive, x: x, y: y))
				}
			}
		}
		
		return (dyingCells, bornCells)
	}

	private func neighboursForCell(x: Int, y: Int) -> [Cell] {
		var cells = [Cell]()
		let neighboursDelta = [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (-1, 1), (-1, -1), (1, -1)]

		for (deltaX, deltaY) in neighboursDelta {
			let neighbourX = x + deltaX
			let neighbourY = y + deltaY

			if neighbourX < 0 || neighbourX >= m.width { continue }
			if neighbourY < 0 || neighbourY >= m.height { continue }

			let state = m[neighbourX, neighbourY]
			cells.append(Cell(state: state, x: neighbourX, y: neighbourY))
		}

		return cells
	}

	private func livingNeighboursForCell(x: Int, y: Int) -> Int {
		return neighboursForCell(x: x, y: y).filter{ $0.state == .alive }.count
	}
}
