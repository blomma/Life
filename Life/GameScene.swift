import Darwin
import SpriteKit
import SwiftUI

class GameScene: SKScene {
    var nodesInWorld = [Int: SKSpriteNode]()

    let world: World
    let worldNode: SKNode

    // The width and height of the cell
    let cellSize: Double = 8.0

    // The total margin as applied to x and y
    let cellMargin: Double = 1.0

    let xOffset: Double
    let yOffset: Double

    let p0: String = """
    9b2o4b2o3bo$9bobo2bobo3b3o$11bo2bo8bo$10bo4bo6b2o$10b2o2b2o$12b2o$$24b
    3o9b2o$2o21bo3bo5b2o2bo$o2b2o6b3o8bo5bo4bob2o$b2obo5bo3bo7bo5bo3bo$5bo
    3bo5bo6bo5bo3bo$5bo3bo5bo7bo3bo5bob2o$b2obo4bo5bo8b3o6b2o2bo$o2b2o5bo
    3bo21b2o$2o9b3o$$24b2o$22b2o2b2o$14b2o6bo4bo$14bo8bo2bo$15b3o3bobo2bob
    o$17bo3b2o4b2o!
    """

    // #N 117P9H3V0
    // #O David Bell
    // #C The first known period 9 spaceship
    // #C https://www.conwaylife.com/wiki/index.php?title=117P9H3V0
    // x = 17, y = 29, rule = b3/s23
    let p1: String = """
8bo8b$7bobo7b$6bo3bo6b$7b3o7b2$5b2o3b2o5b$2b2o3bobo3b2o2b$2b2o3bobo3b
2o2b$2o5bobo5b2o$4b2obobob2o4b$o6bobo6bo$3b2o2bobo2b2o3b$bo2bobo3bobo
2bob$b2o11b2ob$b2o11b2ob$4bo7bo4b$4b3o3b3o4b$6bo3bo6b$3b2obo3bob2o3b$
5b2o3b2o5b$5bobobobo5b2$5bo2bo2bo5b$6b2ob2o6b$5b2o3b2o5b2$4bo2b3o2bo4b
$3b11o3b$3b2obo3bob2o!
"""
    
    // #N Phoenix 1
    // #C A period 2 oscillator found in December 1971. It is the smallest known phoenix.
    // #C www.conwaylife.com/wiki/index.php?title=Phoenix_1
    // x = 8, y = 8, rule = B3/S23
    let p2: String = """
3bo4b$3bobo2b$bo6b$6b2o$2o6b$6bob$2bobo3b$4bo!
"""
    func parseRLE(pattern: String) -> ([(Int, Int)], [(Int, Int)]) {
        let trimmedString = pattern.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        var y = 0
        var x = 0
        var previousNumber: String = ""
        
        var alive : [(Int, Int)] = []
        var dead : [(Int, Int)] = []

        for c in trimmedString {
            if c.lowercased() == "$" {
                y += 1
                previousNumber = ""
                x = 0
            } else if c.isNumber {
                previousNumber += String(c)
            } else if c.lowercased() == "b" {
                var runCount: Int = 1
                if let parsedRunCount = Int(previousNumber) {
                    runCount = parsedRunCount
                }
                
                for i in 1...runCount {
                    dead.append((x + i, y))
                }
                x += runCount
                previousNumber = ""
            } else if c.lowercased() == "o" {
                var runCount: Int = 1
                if let parsedRunCount = Int(previousNumber) {
                    runCount = parsedRunCount
                }
                
                for i in 1...runCount {
                    alive.append((x + i, y))
                }
                x += runCount
                previousNumber = ""
            }
        }
        
        return (alive, dead)
    }
    
    override init(size: CGSize) {
        // Initial size
        let width = Double(size.width)
        let height = Double(size.height)

        // Make note that for this to work and be equal
        // we need to make sure that and extra cellmargin fits to the end
        var maxX = Int(floor(width / (cellSize + cellMargin)))
        var maxY = Int(floor(height / (cellSize + cellMargin)))

        let x = Double(maxX - 1)
        let y = Double(maxY - 1)

        let px: Double = (x * cellSize) + (cellSize / 2) + cellMargin + x + (cellSize / 2)
        let py: Double = (y * cellSize) + (cellSize / 2) + cellMargin + y + (cellSize / 2)

        if px == width { maxX -= 1 }
        if py == height { maxY -= 1 }

        let xo = (Double(maxX - 1) * cellSize) + (cellSize / 2) + cellMargin + Double(maxX - 1) + (cellSize / 2) + cellMargin
        let yo = (Double(maxY - 1) * cellSize) + (cellSize / 2) + cellMargin + Double(maxY - 1) + (cellSize / 2) + cellMargin

        xOffset = (width - xo) / 2
        yOffset = (height - yo) / 2

        world = World(width: maxX, height: maxY)
        worldNode = SKNode()

        super.init(size: size)
        let (alive, dead) = parseRLE(pattern: p1)
        let xStartPos = (maxX - 17) / 2
        let yStartPos = (maxY - 29) / 2
        
        for d in dead {
            let _ = world.update(state: .dead, x: xStartPos + d.0, y: yStartPos + d.1)
        }
        
        for a in alive {
            let _ = world.update(state: .alive, x: xStartPos + a.0, y: yStartPos + a.1)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        worldNode.position.x += CGFloat(xOffset)
        worldNode.position.y += CGFloat(yOffset)
        addChild(worldNode)

        // Setup initial state of world
        let cells = world.livingCells()
        for cell in cells {
            add(cell: cell)
        }
    }

    func add(cell: Cell) {
        let cx = Double(cell.x)
        let cy = Double(cell.y)

        let px: Double = (cx * cellSize) + (cellSize / 2) + cellMargin + cx
        let py: Double = (cy * cellSize) + (cellSize / 2) + cellMargin + cy

        let node = SKSpriteNode(color: NSColor(Color.orange), size: CGSize(width: cellSize, height: cellSize))
        node.position = CGPoint(x: px, y: py)
        node.blendMode = .replace

        nodesInWorld[cell.x * 1000 + cell.y] = node
        worldNode.addChild(node)
    }

    func remove(cell: Cell) {
        if let node: SKSpriteNode = nodesInWorld.removeValue(forKey: cell.x * 1000 + cell.y) {
            node.removeFromParent()
        }
    }

    var lastUpdateTime: TimeInterval = 0
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let timeSinceLastUpdate = currentTime - lastUpdateTime
        if timeSinceLastUpdate < 0.4 {
            return
        }

        lastUpdateTime = currentTime

        let cells = world.update()
        for dyingCell in cells.dyingCells {
            remove(cell: dyingCell)
        }

        for bornCell in cells.bornCells {
            add(cell: bornCell)
        }
    }
}

// MARK: - Touches

// extension GameScene {
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.location(in: self)
//
//            let xLoc: Double = Double(location.x)
//            let yLoc: Double = Double(location.y)
//
//            // The grid is zero based
//            let x: Int = (Int)(xLoc / (cellSize + cellMargin))
//            let y: Int = (Int)(yLoc / (cellSize + cellMargin))
//
//            let cell = world.update(state: .alive, x: x, y: y)
//            add(cell: cell)
//        }
//    }
//
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesCancelled(touches, with: event)
//    }
// }
