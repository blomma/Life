struct World {
	let cells: [Cell]

	func worldWithNewCells(newCells: [Cell]) -> World {
		let c = cells
			.filter { !newCells.contains($0) }

		return World(cells: c + newCells)
	}

	func updateWorld() -> World {
		let dyingCells = cells
			.filter({$0.state == CellState.Alive && (livingNeighboursForCell($0) !~= 2...3) })

		let newLife = cells
			.filter({$0.state != CellState.Alive && livingNeighboursForCell($0) == 3})

		return worldWithNewCells(dyingCells + newLife)
	}

	func cellsAreNeigbours(cell1: Cell, cell2: Cell) -> Bool {
		let delta = (abs(cell1.x - cell2.x), abs(cell1.y - cell2.y))
		switch (delta) {
			case (1,1), (1,0), (0,1):
				return true
			default:
				return false
		}
	}

	func neighboursForCell(cell: Cell) -> [Cell] {
		return cells.filter { cellsAreNeigbours(cell, cell2: $0)}
	}

	func livingNeighboursForCell(cell: Cell) -> Int {
		return neighboursForCell(cell).filter{ $0.state == CellState.Alive }.count
	}
}

