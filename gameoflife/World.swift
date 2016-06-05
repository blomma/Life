import QuartzCore

struct World {
    var m: Matrix<Cell>

    init(width: Int, height: Int) {
        m = Matrix<Cell>(width: width, height: height, repeatValue: Cell(state: .Alive))
    }

	func updateWorld() -> Void {
        let c: Int = m.filter { (x: Int, y: Int, element: Cell) -> Bool in
            element.state == .Alive
        }.count
        
        let newM = m.map({ (x: Int, y: Int, element: Cell) -> Cell in
            let neighbours = livingNeighboursForCell(x, y: y)
            
            if element.state == .Alive {
                if neighbours < 2 || neighbours > 3 {
                    return (x, y, Cell(state: .Dead))
                }
            } else {
                if neighbours == 3 {
                    return (x, y, Cell(state: .Alive))
                }
            }
            
            return (x, y, cell)
        })
        
        
        for (x, y, cell) in m {
            let neighbours = livingNeighboursForCell(x, y: y)
            if cell.state == .Alive {
                if neighbours < 2 || neighbours > 3 {                    
                    cell.state == .Dead
                }
            } else {
                if neighbours == 3 {
                    cell.state == .Alive
                }
            }
        }
        
        let d: Int = m.filter { (x: Int, y: Int, element: Cell) -> Bool in
            element.state == .Alive
            }.count
        
        print("\(c) \(d)")
	}

	func neighboursForCell(x: Int, y: Int) -> [Cell] {
        var cells = [Cell]()
        let neighboursDelta = [(1, 0), (0, 1), (-1, 0), (0, -1),
                               (1, 1), (-1, 1), (-1, -1), (1, -1)]

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

	func livingNeighboursForCell(x: Int, y: Int) -> Int {
		return neighboursForCell(x, y: y).filter{ $0.state == CellState.Alive }.count
	}
}

