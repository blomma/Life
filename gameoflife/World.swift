import Foundation

class World {
	private let m: Matrix<Cell>
	private var activeCells = [Cell]()

	init(width: Int, height: Int) {
		m = Matrix<Cell>(width: width, height: height, repeatValue: Cell(state: .dead, x: 0, y: 0))
		
		// We walk the matrix
		for (x, y, cell) in m {
			m[x, y] = Cell(state: cell.state, x: x, y: y)
		}
		
		// Update neighbours
		for (_, _, cell) in m {
			cell.neighbours = neighboursForCell(cell: cell)
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
		var dyingCells: [Cell] = [Cell]()
		var bornCells: [Cell] = [Cell]()
		
		let g = DispatchGroup()
		
		let d = DispatchQueue.init(label: "work", attributes: DispatchQueueAttributes.concurrent)
		let b = DispatchQueue.init(label: "dyingcells", attributes: DispatchQueueAttributes.serial)
		let b2 = DispatchQueue.init(label: "borncells", attributes: DispatchQueueAttributes.serial)
		
		for cell in activeCells {
			d.async(group: g, execute: {
				cell.active = false
				let neighbours = self.livingNeighboursForCell(cell: cell)
				if cell.state == .alive {
					if 2...3 !~= neighbours {
						b.async(group: g, execute: {
							dyingCells.append(cell)
						})
					}
				} else {
					if neighbours == 3 {
						b2.async(group: g, execute: {
							bornCells.append(cell)
						})
					}
				}
			})
		}

		g.wait()
//		for cell in activeCells {
//			cell.active = false
//			let neighbours = self.livingNeighboursForCell(cell: cell)
//			if cell.state == .alive {
//				if 2...3 !~= neighbours {
//					dyingCells.append(cell)
//				}
//			} else {
//				if neighbours == 3 {
//					bornCells.append(cell)
//				}
//			}
//		}

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
	private func neighboursForCell(cell: Cell) -> [Cell] {
		let neighbours: [Cell] = neighboursDelta
			.map { (dx, dy) -> (Int, Int) in
				return (dx + cell.x, dy + cell.y)
			}
			.filter { (nx, ny) -> Bool in
				if 0..<m.width ~= nx && 0..<m.height ~= ny {
					return true
				}
				
				return false
			}
			.map { (nx, ny) -> Cell in
				return m[nx, ny]
		}
		
		return neighbours
	}
	
	private func livingNeighboursForCell(cell: Cell) -> Int {
		return cell.neighbours
			.filter{ $0.state == .alive }
			.count
	}
}
