import SpriteKit
import Darwin

class GameScene: SKScene {
    var world: World
    let cellSize: Double = 2
    let cellMargin: Double = 1

    var isTouching: Bool = false
    
    override init(size: CGSize) {
        let width: Int = Int(Double(size.width)/(cellSize + 2 * cellMargin))
        let height: Int = Int(Double(size.height)/(cellSize + 2 * cellMargin))

        let aliveCells: [(x: Int, y: Int)] = [(19, 20), (20, 20), (20, 21), (20, 19)]
        world = World(width: width, height: height, aliveCells: aliveCells)

        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let x: Int = (Int)(Double(location.x) / (cellSize + 2 * cellMargin))
            let y: Int = (Int)(Double(location.y) / (cellSize + 2 * cellMargin))
            
            world.updateWorld(x, y: y, cell: Cell(state: .Alive))
            
            let sprite = SKSpriteNode()
            sprite.color = UIColor.orangeColor()
            sprite.size = CGSize(width: cellSize, height: cellSize)
            sprite.anchorPoint = CGPoint(x: 1, y: 0)
            sprite.position = CGPoint(x: Double(x) * (cellSize + 2 * cellMargin), y: Double(y) * (cellSize + 2 * cellMargin))
            
            self.addChild(sprite)
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
        
        world.updateWorld()
        
        self.removeAllChildren()

        let aliveCells = world.m.filter { (x: Int, y: Int, element: Cell) -> Bool in
            element.state == .Alive
        }

        for cell in aliveCells {
            let sprite = SKSpriteNode()
            sprite.color = UIColor.orangeColor()
            sprite.size = CGSize(width: cellSize, height: cellSize)
            sprite.anchorPoint = CGPoint(x: 1, y: 0)
            sprite.position = CGPoint(x: Double(cell.x) * (cellSize + 2 * cellMargin), y: Double(cell.y) * (cellSize + 2 * cellMargin))

            self.addChild(sprite)
        }
    }
}
