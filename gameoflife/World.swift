struct World {
	private let m: Matrix<Cell>
	
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
		
		return cell
	}
	
	func update() -> (dyingCells: [Cell], bornCells: [Cell]) {
		var dyingCells: [Cell] = [Cell]()
		var bornCells: [Cell] = [Cell]()
		
		for (_, _, cell) in m {
//			var neighbours: Int = 0
//			for cell in cell.neighbours {
//				if cell.state == .alive {
//					neighbours += 1
//				}
//			}
			
			let neighbours = livingNeighboursForCell(cell: cell)
			if cell.state == .alive {
				if 2...3 !~= neighbours {
					cell.state = .dead
					dyingCells.append(cell)
				}
			} else {
				if neighbours == 3 {
					cell.state = .alive
					bornCells.append(cell)
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
		var neighbours: [Cell] = [Cell]()
		for (deltaX, deltaY) in neighboursDelta {
			let neighbourX = cell.x + deltaX
			let neighbourY = cell.y + deltaY
			
			if neighbourX < 0 || neighbourX >= m.width { continue }
			if neighbourY < 0 || neighbourY >= m.height { continue }
			
			neighbours.append(m[neighbourX, neighbourY])
		}
		
		return neighbours
	}
	
//	private func neighboursForCell(x: Int, y: Int) -> [CellState] {
//		let neighbours: [CellState] = neighboursDelta
//			// TODO: This can be precalculated
//			.map { (dx, dy) -> (Int, Int) in
//				return (dx + x, dy + y)
//			}
//			// TODO: This can be precalculated
//			.filter { (nx, ny) -> Bool in
//				if 0..<m.width ~= nx && 0..<m.height ~= ny{
//					return true
//				}
//				
//				return false
//			}
//			.map { (nx, ny) -> CellState in
//				return m[nx, ny]
//		}
//		
//		return neighbours
//	}
	
	private func livingNeighboursForCell(cell: Cell) -> Int {
		return cell.neighbours
			.filter{ $0.state == .alive }
			.count
	}
}
