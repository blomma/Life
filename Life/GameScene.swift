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

        let _ = world.update(state: .alive, x: 10, y: 10)
        let _ = world.update(state: .alive, x: 11, y: 9)
        let _ = world.update(state: .alive, x: 9, y: 8)
        let _ = world.update(state: .alive, x: 10, y: 8)
        let _ = world.update(state: .alive, x: 11, y: 8)

        super.init(size: size)
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

        nodesInWorld[cell.x * 1000 + cell.y] = node
        worldNode.addChild(node)
    }

    func remove(cell: Cell) {
        if let node: SKSpriteNode = nodesInWorld.removeValue(forKey: cell.x * 1000 + cell.y) {
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.removeFromParent(),
            ]))
        }
    }

    var lastUpdateTime: TimeInterval = 0
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let timeSinceLastUpdate = currentTime - lastUpdateTime
        if timeSinceLastUpdate < 0.2 {
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
