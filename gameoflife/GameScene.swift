import SpriteKit
import Darwin

class GameScene: SKScene {
    var world: World
    let cellSize: Double = 2
    let cellMargin: Double = 1

    let xOffset: Double
    let yOffset: Double
    
    var isTouching: Bool = false
    
    override init(size: CGSize) {
        let maxX: Int = Int(Double(size.width)/(cellSize + 2 * cellMargin))
        let maxY: Int = Int(Double(size.height)/(cellSize + 2 * cellMargin))
        
        xOffset = ((Double(size.width) - Double(maxX) * (cellSize + 2 * cellMargin))) / 2
        yOffset = ((Double(size.height) - Double(maxY) * (cellSize + 2 * cellMargin))) / 2
        
        let aliveCells: [(x: Int, y: Int)] = [(19, 20), (20, 20), (20, 21), (20, 19)]
        world = World(width: maxX, height: maxY, aliveCells: aliveCells)
        
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    }

    func addCell(x: Int, y: Int) -> Void {
        let sprite = SKSpriteNode()
        sprite.color = UIColor.orangeColor()
        sprite.size = CGSize(width: cellSize, height: cellSize)
        sprite.anchorPoint = CGPoint(x: 0, y: 0)
        sprite.position =
            CGPoint(
                x: Double(x) * (cellSize - cellMargin) + xOffset + (2 * cellMargin),
                y: Double(y) * (cellSize - cellMargin) + yOffset + (2 * cellMargin))
        
        self.addChild(sprite)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let xLoc: Double = Double(location.x)
            print("xloc:\(xLoc), offset:\(xOffset)")
            if (xLoc - xOffset < 0 || xLoc + xOffset > Double(self.size.width)) {
                continue
            }
            
            let yLoc: Double = Double(location.y)
            print("yloc:\(yLoc), offset:\(yOffset)")
            if (yLoc - yOffset < 0 || yLoc + yOffset > Double(self.size.height)) {
                continue
            }
            
            let x: Int = (Int)(xLoc / (cellSize + 2 * cellMargin))
            let y: Int = (Int)(yLoc / (cellSize + 2 * cellMargin))
            
            world.updateWorld(x, y: y, cell: Cell(state: .Alive))
            addCell(x, y: y)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouching = true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isTouching = false
    }
    
    var lastUpdate: CFTimeInterval = 0
    override func update(currentTime: CFTimeInterval) {
        if (isTouching) {
            return
        }
        
        if (currentTime - lastUpdate < 1) {
            return
        }
        
        lastUpdate = currentTime
        
//        world.updateWorld()
        
        self.removeAllChildren()

        let aliveCells = world.m.filter { (x: Int, y: Int, element: Cell) -> Bool in
            element.state == .Alive
        }

        for cell in aliveCells {
            addCell(cell.x, y: cell.y)
        }
    }
}
