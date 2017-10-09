import Foundation

class World {
	private let m: Matrix<Cell>
	private var activeCells: Set<Cell> = []
    public var width: Int
    public var height: Int
    
	init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
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

        activeCells.insert(cell)

        for nCell in cell.neighbours {
            activeCells.insert(nCell)
        }

		return cell
	}

	func update() -> (dyingCells: [Cell], bornCells: [Cell]) {
		var dyingCells: [Cell] = []
		var bornCells: [Cell] = []

		for cell in activeCells {
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

            activeCells.insert(cell)

			for nCell in cell.neighbours {
                activeCells.insert(nCell)
			}
		}

		for cell in bornCells {
			cell.state = .alive

            activeCells.insert(cell)

			for nCell in cell.neighbours {
                activeCells.insert(nCell)
			}
		}

		return (dyingCells, bornCells)
	}

//    func memoize<T:Hashable, U>(fn : @escaping (T) -> U) -> (T) -> U {
//        var cache = [T:U]()
//        return { val in
//            if let value = cache[val] {
//                return value
//            }
//
//            let newValue = fn(val)
//            cache[val] = newValue
//
//            return newValue
//        }
//    }

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
