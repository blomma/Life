import SpriteKit
import Darwin

class GameScene: SKScene {
	var world: World
	let cellSize: Double = 4
	let cellMargin: Double = 1

	let xOffset: Double
	let yOffset: Double

	var isTouching: Bool = false

	let c: SKCameraNode = SKCameraNode()

	override init(size: CGSize) {
		let maxX: Int = Int(Double(size.width)/(cellSize + cellMargin))
		let maxY: Int = Int(Double(size.height)/(cellSize + cellMargin))

		xOffset = ((Double(size.width) - Double(maxX) * (cellSize + cellMargin)) - cellMargin) / 2
		yOffset = ((Double(size.height) - Double(maxY) * (cellSize + cellMargin))) / 2

		let aliveCells: [(x: Int, y: Int)] = [(19, 20), (20, 20), (20, 21), (20, 19)]
		world = World(width: maxX, height: maxY, aliveCells: aliveCells)

		super.init(size: size)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func didMoveToView(view: SKView) {
//		c.position = CGPoint(x: Double(size.width / 2) + xOffset, y: Double(size.height / 2))
//
//		self.addChild(c)
//		self.camera = c
	}

	func addCell(x: Int, y: Int) -> Void {
		let px: Double =
		(Double(x) * (cellSize + cellMargin))

		let py: Double =
		(Double(y) * (cellSize + cellMargin))

		let sprite = SKSpriteNode()
		sprite.color = UIColor.orangeColor()
		sprite.size = CGSize(width: cellSize, height: cellSize)
		sprite.anchorPoint = CGPoint(x: 0, y: 0)
		sprite.position = CGPoint(x: px, y: py)

		self.addChild(sprite)
	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for touch in touches {
			let location = touch.locationInNode(self)

			let xLoc: Double = Double(location.x)
			let yLoc: Double = Double(location.y)

			// The grid is zero based
			let x: Int = (Int)(xLoc / (cellSize + cellMargin)) - 1
			let y: Int = (Int)(yLoc / (cellSize + cellMargin)) - 1

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

		world.updateWorld()

		self.removeAllChildren()

		let aliveCells = world.m.filter { (x: Int, y: Int, element: Cell) -> Bool in
			element.state == .Alive
		}

		for cell in aliveCells {
			addCell(cell.x, y: cell.y)
		}
	}
}
