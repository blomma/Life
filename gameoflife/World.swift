struct World {
	let m: Matrix<Cell>

	init(width: Int, height: Int) {
		let c: Cell = Cell(state: .Dead)
		m = Matrix<Cell>(width: width, height: height, repeatValue: c)
	}

	func update(x: Int, y: Int, cell: Cell) {
		m[x, y] = cell
	}

	func update() -> Void {
		for (x, y, cell) in m {
			let neighbours = livingNeighboursForCell(x, y: y)
			if cell.state == .Alive {
				if neighbours < 2 || neighbours > 3 {
					m[x, y] = Cell(state: .Dead)
				}
			} else {
				if neighbours == 3 {
					m[x, y] = Cell(state: .Alive)
				}
			}
		}
	}

	private func neighboursForCell(x: Int, y: Int) -> [Cell] {
		var cells = [Cell]()
		let neighboursDelta = [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (-1, 1), (-1, -1), (1, -1)]

		for (deltaX, deltaY) in neighboursDelta {
			let neighbourX = x + deltaX
			let neighbourY = y + deltaY

			if neighbourX < 0 || neighbourX >= m.width { continue }
			if neighbourY < 0 || neighbourY >= m.height { continue }

			let cell = m[neighbourX, neighbourY]
			cells.append(cell)
		}

		return cells
	}

	private func livingNeighboursForCell(x: Int, y: Int) -> Int {
		return neighboursForCell(x, y: y).filter{ $0.state == CellState.Alive }.count
	}
}
