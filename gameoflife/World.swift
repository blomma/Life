import Foundation

class World {
	private let m: Matrix<Cell>
	private var activeCells: [Cell] = []

	init(width: Int, height: Int) {
		m = Matrix<Cell>(width: width, height: height, repeatValue: Cell(state: .dead, x: 0, y: 0))

		// We walk the matrix
		for (x, y, cell) in m {
			m[x, y] = Cell(state: cell.state, x: x, y: y)
		}

		// Update neighbours
		for (_, _, cell) in m {
			cell.neighbours = neighbours(for: cell)
		}
	}

	func livingCells() -> [Cell] {
		return m.filter { (x: Int, y: Int, element: Cell) -> Bool in
			return element.state == .alive
		}.map { (x: Int, y: Int, element: Cell) -> Cell in
			return element
		}
	}

	func update(state: CellState, x: Int, y: Int) -> Cell {
		let cell = m[x, y]
		cell.state = state

		if !cell.active {
			cell.active = true
			activeCells.append(cell)
		}

		for nCell in cell.neighbours {
			if !nCell.active {
				nCell.active = true
				activeCells.append(nCell)
			}
		}

		return cell
	}

	func update() -> (dyingCells: [Cell], bornCells: [Cell]) {
		var dyingCells: [Cell] = []
		var bornCells: [Cell] = []

		for cell in activeCells {
			cell.active = false

			let neighbours = self.livingNeighbours(for: cell)
			if cell.state == .alive {
				if 2...3 !~= neighbours {
					dyingCells.append(cell)
				}
			} else {
				if neighbours == 3 {
					bornCells.append(cell)
				}
			}
		}

		activeCells.removeAll()

		for cell in dyingCells {
			cell.state = .dead

			if !cell.active {
				cell.active = true
				activeCells.append(cell)
			}

			for nCell in cell.neighbours {
				if !nCell.active {
					nCell.active = true
					activeCells.append(nCell)
				}
			}
		}

		for cell in bornCells {
			cell.state = .alive

			if !cell.active {
				cell.active = true
				activeCells.append(cell)
			}

			for nCell in cell.neighbours {
				if !nCell.active {
					nCell.active = true
					activeCells.append(nCell)
				}
			}
		}

		return (dyingCells, bornCells)
	}

	func memoize<T:Hashable, U>(fn : (T) -> U) -> (T) -> U {
		var cache = [T:U]()
		return { val in
			if let value = cache[val] {
				return value
			}

			let newValue = fn(val)
			cache[val] = newValue

			return newValue
		}
	}

	let neighboursDelta = [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (-1, 1), (-1, -1), (1, -1)]
	private func neighbours(for cell: Cell) -> [Cell] {
		let neighbours: [Cell] = neighboursDelta
			.map { (dx, dy) -> Cell in
				var nx = dx + cell.x
				var ny = dy + cell.y

				// Wrap it around
				if nx >= m.width {
					nx = 0
				}

				if nx < 0 {
					nx = m.width - 1
				}

				if ny >= m.height {
					ny = 0
				}

				if ny < 0 {
					ny = m.height - 1
				}

				return m[nx, ny]
			}

		return neighbours
	}

	private func livingNeighbours(for cell: Cell) -> Int {
		return cell.neighbours
			.filter{ $0.state == .alive }
			.count
	}
}
