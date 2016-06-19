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
				if 2...3 !~= neighbours {
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

	let neighboursDelta = [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (-1, 1), (-1, -1), (1, -1)]
	private func neighboursForCell(x: Int, y: Int) -> [Cell] {
		let neightbours = neighboursDelta
			// TODO: This can be precalculated
			.map { (dx, dy) -> (Int, Int) in
				return (dx + x, dy + y)
			}
			// TODO: This can be precalculated
			.filter { (nx, ny) -> Bool in
				if 0..<m.width ~= nx && 0..<m.height ~= ny{
					return true
				}

				return false
			}
			.map { (nx, ny) -> Cell in
				return Cell(state: m[nx, ny], x: nx, y: ny)
		}

		return neightbours
	}

	private func livingNeighboursForCell(x: Int, y: Int) -> Int {
		return neighboursForCell(x: x, y: y)
			.filter{ $0.state == .alive }
			.count
	}
}
