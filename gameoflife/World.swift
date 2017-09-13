import Foundation

class World {
	fileprivate let m: Matrix<Cell>
	fileprivate var activeCells: [Cell] = []

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
		return m.filter { (arg: (x: Int, y: Int, element: Cell)) -> Bool in
			let (_, _, element) = arg
			return element.state == .alive
		}.reduce([Cell](), { (result: [Cell], next: (x: Int, y: Int, element: Cell)) -> [Cell] in
				var r = result
				r.append(next.element)
				
				return r
		})
	}

	func update(_ state: CellState, x: Int, y: Int) -> Cell {
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
				if !(2...3 ~= neighbours) {
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

//	func memoize<T:Hashable, U>(_ fn : @escaping (T) -> U) -> (T) -> U {
//		var cache = [T:U]()
//		return { val in
//			if let value = cache[val] {
//				return value
//			}
//
//			let newValue = fn(val)
//			cache[val] = newValue
//
//			return newValue
//		}
//	}
}

extension World {
	fileprivate func neighbours(for cell: Cell) -> [Cell] {
		let neighboursDelta = [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (-1, 1), (-1, -1), (1, -1)]
		let neighbours: [Cell] = neighboursDelta
			.reduce([Cell](), { (result: [Cell], next: (dx: Int, dy: Int)) -> [Cell] in
				var nx = next.dx + cell.x
				var ny = next.dy + cell.y
				
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
				
				var r = result
				r.append(m[nx, ny])
				
				return r
			})
		
		return neighbours
	}
	
	fileprivate func livingNeighbours(for cell: Cell) -> Int {
		return cell.neighbours
			.filter{ $0.state == .alive }
			.count
	}
}

