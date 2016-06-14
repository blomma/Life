import SpriteKit
import Darwin

class GameScene: SKScene {
	private struct Action {
		static let pinch = #selector(GameScene.pinch(_:))
		static let rotate = #selector(GameScene.rotate(_:))
	}
	
	var previousDistance: Double = 0
	var previousPoint: CGPoint = CGPointZero
	var deltaAngle: CGFloat = 0
	
	let world: World
	let worldNode: SKNode
	
	let cellSize: Double = 4
	let cellMargin: Double = 1

	// let xOffset: Double
	// let yOffset: Double

	var cameraNode: SKCameraNode = SKCameraNode()
	
	var pinch: UIPinchGestureRecognizer?
	var rotation: UIRotationGestureRecognizer?
	
	override init(size: CGSize) {
		// Initial size
		let maxX: Int = Int(Double(size.width)/(cellSize + cellMargin))
		let maxY: Int = Int(Double(size.height)/(cellSize + cellMargin))

		// xOffset = ((Double(size.width) - Double(maxX) * (cellSize + cellMargin)) - cellMargin) / 2
		// yOffset = ((Double(size.height) - Double(maxY) * (cellSize + cellMargin))) / 2

		world = World(width: maxX, height: maxY)
		worldNode = SKNode()

		// Add initial state
		let aliveCells: [(x: Int, y: Int)] = [(19, 20), (20, 20), (20, 21), (20, 19)]
		for cell in aliveCells {
			world.update(cell.x, y: cell.y, cell: Cell(state: .Alive))
		}

		super.init(size: size)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func didMoveToView(view: SKView) {
		super.didMoveToView(view)
		
		let pinch = UIPinchGestureRecognizer(target: self, action: Action.pinch)
		self.pinch = pinch
		self.view?.addGestureRecognizer(pinch)
		
		let rotation = UIRotationGestureRecognizer(target: self, action: Action.rotate)
		self.rotation = rotation
		self.view?.addGestureRecognizer(rotation)
		
		self.addChild(cameraNode)
		self.camera = cameraNode
		
		cameraNode.position = CGPoint(x: Double(size.width / 2), y: Double(size.height / 2))
		
		self.addChild(worldNode)
	}
	
	func addCell(x: Int, y: Int) -> Void {
		let px: Double = (Double(x) * (cellSize + cellMargin)) + (cellSize / 2)
		let py: Double = (Double(y) * (cellSize + cellMargin)) + (cellSize / 2)

		let sprite = SKSpriteNode()
		sprite.color = UIColor.orangeColor()
		sprite.size = CGSize(width: cellSize, height: cellSize)
		sprite.position = CGPoint(x: px, y: py)

		worldNode.addChild(sprite)
	}

	var lastUpdate: CFTimeInterval = 0
	override func update(currentTime: CFTimeInterval) {
		if (currentTime - lastUpdate < 1) {
			return
		}

		lastUpdate = currentTime

		world.update()

		let aliveCells = world.m.filter { (x: Int, y: Int, element: Cell) -> Bool in
			element.state == .Alive
		}

		worldNode.removeAllChildren()
		for cell in aliveCells {
			addCell(cell.x, y: cell.y)
		}
	}
}

extension GameScene {
	func pinch(recognizer: UIPinchGestureRecognizer) -> Void {
		guard let camera = camera else {
			return
		}
		
		var cameraScaledTo = recognizer.scale < 0 ? 0 : recognizer.scale
		cameraScaledTo = cameraScaledTo < 0 ? 0 : cameraScaledTo
		camera.xScale = cameraScaledTo
		camera.yScale = cameraScaledTo
	}
	
	func rotate(recognizer: UIRotationGestureRecognizer) -> Void {
		guard let camera = camera else {
			return
		}
		
		let rotateAction = SKAction.rotateToAngle(recognizer.rotation, duration: 0)
		camera.removeAllActions()
		camera.runAction(rotateAction)
	}
	
	func distanceSquared(p1: CGPoint, p2: CGPoint) -> Double {
		return Double(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
	}
	
	func vectorFromPoint(firstPoint: CGPoint, toPoint:CGPoint) -> CGPoint {
		return CGPoint(x: toPoint.x - firstPoint.x, y: toPoint.y - firstPoint.y)
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if touches.count == 2 {
			guard let camera = camera,let view = self.view else {
				return
			}
			
			let touchArray = Array(touches)
			let location1 = touchArray[0].locationInView(self.view)
			let location2 = touchArray[1].locationInView(self.view)
			
//			let x = (max(location1.x, location2.x) - min(location1.x, location2.x)) / 2 + min(location1.x, location2.x)
//			let y = (max(location1.y, location2.y) - min(location1.y, location2.y)) / 2 + min(location1.y, location2.y)
//			
//			camera.position = CGPoint(x: x, y: y)
			
			previousDistance = distanceSquared(location1, p2: location2)
			
			deltaAngle = atan2(location1.y - view.center.y, location1.x - view.center.x)
		} else if touches.count == 1 {
			previousPoint = (touches.first?.locationInNode(self))!
			
//			cameraNode.runAction(SKAction.moveTo(previousPoint, duration: 0.25))
		}
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if touches.count == 2 {
			// This is a zoom andor rotate
			guard let camera = camera, let view = self.view else {
				return
			}
			
			let touchArray = Array(touches)
			let location1 = touchArray[0].locationInView(view)
			let location2 = touchArray[1].locationInView(view) // 0.02
			
			let distanceNew = distanceSquared(location1, p2: location2)
			
			// Both x and y is scaled the same ammount
//			var cameraScaledTo = distanceNew > previousDistance ? camera.xScale + 0.05 : camera.xScale - 0.05
//			cameraScaledTo = cameraScaledTo < 0 ? 0 : cameraScaledTo
//			camera.xScale = cameraScaledTo
//			camera.yScale = cameraScaledTo
			
//			let zoomAction = SKAction.scaleTo(cameraScaledTo, duration: 0)

//			let previousLocation1 = touchArray[0].previousLocationInView(view)
//			let previousDifference = vectorFromPoint(camera.position, toPoint: previousLocation1)
//			let previousRoation = atan2(previousDifference.y, previousDifference.x)
//			let currentDifference = vectorFromPoint(camera.position, toPoint: location1)
//			let currentRotation = atan2(currentDifference.y, currentDifference.x)
//			let angle = currentRotation - previousRoation

//			let angle = atan2(location1.y - view.center.y , location1.x - view.center.x)
//			let angleDifference = deltaAngle - angle
//			print("\(angleDifference)")
//			let rotateAction = SKAction.rotateByAngle(0, duration: 0)
			
//			let s = SKAction.sequence([zoomAction, rotateAction])
//			cameraNode.removeAllActions()
//			cameraNode.runAction(s)
			
			
//			camera.
			previousDistance = distanceNew
		} else if touches.count == 1 {
			// And this is a move
//			guard let camera = camera else {
//				return
//			}
//			
//			for touch in touches {
//				let location = touch.locationInNode(self)
//				let deltaX = previousPoint.x - location.x
//				let deltaY = previousPoint.y - location.y
//				previousPoint = location
//				
//				camera.position.x += deltaX
//				camera.position.y += deltaY
//			}
		}
		
//		for touch in touches {
//			let location = touch.locationInNode(self)
//			
//			let xLoc: Double = Double(location.x)
//			let yLoc: Double = Double(location.y)
//			
//			// The grid is zero based
//			let x: Int = (Int)(xLoc / (cellSize + cellMargin)) - 1
//			let y: Int = (Int)(yLoc / (cellSize + cellMargin)) - 1
//			
//			world.update(x, y: y, cell: Cell(state: .Alive))
//			addCell(x, y: y)
//		}
	}
	

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event)
	}
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		super.touchesCancelled(touches, withEvent: event)
	}
}
