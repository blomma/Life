import SpriteKit
import Darwin

class GameScene: SKScene {
	private struct Action {
		static let pinch = #selector(GameScene.pinch(_:))
		static let rotate = #selector(GameScene.rotate(_:))
	}

	var nodesInWorld: Dictionary<Cell, SKSpriteNode> = Dictionary<Cell, SKSpriteNode>()

	var previousDistance: Double = 0
	var previousPoint: CGPoint = CGPoint.zero
	var deltaAngle: CGFloat = 0

	let world: World
	let worldNode: SKNode

	// The width and height of the cell
	let cellSize: Double = 8.0

	// The total margin as applied to x and y
	let cellMargin: Double = 1.0

	let xOffset: Double
	let yOffset: Double

	var cameraNode: SKCameraNode = SKCameraNode()

	var pinch: UIPinchGestureRecognizer?
	var rotation: UIRotationGestureRecognizer?
	var isEditing: Bool = false

	override init(size: CGSize) {
		// Initial size
		let width: Double = Double(size.width)
		let height: Double = Double(size.height)

		// Make note that for this to work and be equal
		// we need to make sure that and extra cellmargin fits to the end
		var maxX: Int = Int(floor(width / (cellSize + cellMargin)))
		var maxY: Int = Int(floor(height / (cellSize + cellMargin)))

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

		// Add initial state
//		let aliveCells: [(x: Int, y: Int)] = [(19, 20), (20, 20), (20, 21), (20, 19)]
//		let aliveCells: [(x: Int, y: Int)] = [(19, 20), (20, 20), (21, 20)]
//		for cell in aliveCells {
//			let _ = world.update(state: .alive, x: cell.x, y: cell.y)
//		}

		let _ = world.update(state: .dead, x: 19, y: 20)
		let _ = world.update(state: .alive, x: 20, y: 20)

		let _ = world.update(state: .dead, x: 19, y: 19)
		let _ = world.update(state: .dead, x: 20, y: 19)
		let _ = world.update(state: .alive, x: 21, y: 19)

		let _ = world.update(state: .alive, x: 19, y: 18)
		let _ = world.update(state: .alive, x: 20, y: 18)
		let _ = world.update(state: .alive, x: 21, y: 18)

		super.init(size: size)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func didMove(to view: SKView) {
		super.didMove(to: view)

		//		let pinch = UIPinchGestureRecognizer(target: self, action: Action.pinch)
		//		self.pinch = pinch
		//		self.view?.addGestureRecognizer(pinch)
		//
		//		let rotation = UIRotationGestureRecognizer(target: self, action: Action.rotate)
		//		self.rotation = rotation
		//		self.view?.addGestureRecognizer(rotation)

		self.addChild(cameraNode)
		self.camera = cameraNode

		let x = Double(size.width / 2)  - xOffset //- (xOffset / 2) + (cellMargin / 2)
		let y = Double(size.height / 2) - yOffset //- (yOffset / 2) + (cellMargin / 2)

		cameraNode.position = CGPoint(x: x, y: y)
		self.addChild(worldNode)

		// Setup initial state of world
		let cells = world.livingCells()
		for cell in cells {
			add(cell: cell)
		}
	}

	func add(cell: Cell, withAnimation: Bool = true) -> Void {
		let cx: Double = Double(cell.x)
		let cy: Double = Double(cell.y)

		let px: Double = (cx * cellSize) + (cellSize / 2) + cellMargin + cx
		let py: Double = (cy * cellSize) + (cellSize / 2) + cellMargin + cy

		let sprite = SKSpriteNode()
		sprite.color = UIColor.orange()
		sprite.size = CGSize(width: cellSize, height: cellSize)
		sprite.position = CGPoint(x: px, y: py)
		if withAnimation {
			sprite.alpha = 0
		}

		nodesInWorld[cell] = sprite

		worldNode.addChild(sprite)

		if withAnimation {
			sprite.run(SKAction.fadeIn(withDuration: 0.2))
		}
	}

	func remove(cell: Cell, withAnimation: Bool = true) -> Void {
		if let node: SKSpriteNode = nodesInWorld[cell] {
			if withAnimation {
				let actions = SKAction.sequence([
					SKAction.fadeOut(withDuration: 0.2),
					SKAction.removeFromParent()
					])

				node.run(actions, completion: { [unowned self] in
					let _ = self.nodesInWorld.removeValue(forKey: cell)
				})
			} else {
				node.run(SKAction.removeFromParent(), completion: { [unowned self] in
					let _ = self.nodesInWorld.removeValue(forKey: cell)
				})
			}
		}
	}

	var lastUpdate: TimeInterval = 0
	override func update(_ currentTime: TimeInterval) {
		if lastUpdate == 0 {
			lastUpdate = currentTime
		}

		if isEditing {
			return
		}

		if currentTime - lastUpdate < 0.4 {
			return
		}

		lastUpdate = currentTime

		let cells = world.update()

		for dyingCell in cells.dyingCells {
			remove(cell: dyingCell)
		}

		for bornCell in cells.bornCells {
			add(cell: bornCell)
		}
	}
}

extension GameScene {
	func pinch(_ recognizer: UIPinchGestureRecognizer) -> Void {
		guard let camera = camera else {
			return
		}

		var cameraScaledTo = recognizer.scale < 0 ? 0 : recognizer.scale
		cameraScaledTo = cameraScaledTo < 0 ? 0 : cameraScaledTo
		camera.xScale = cameraScaledTo
		camera.yScale = cameraScaledTo
	}

	func rotate(_ recognizer: UIRotationGestureRecognizer) -> Void {
		guard let camera = camera else {
			return
		}

		let rotateAction = SKAction.rotate(toAngle: recognizer.rotation, duration: 0)
		camera.removeAllActions()
		camera.run(rotateAction)
	}

	func distanceSquared(p1: CGPoint, p2: CGPoint) -> Double {
		return Double(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
	}

	func vectorFromPoint(firstPoint: CGPoint, toPoint:CGPoint) -> CGPoint {
		return CGPoint(x: toPoint.x - firstPoint.x, y: toPoint.y - firstPoint.y)
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		isEditing = true
		//		if touches.count == 2 {
		//			guard let camera = camera,let view = self.view else {
		//				return
		//			}
		//
		//			let touchArray = Array(touches)
		//			let location1 = touchArray[0].location(in: self.view)
		//			let location2 = touchArray[1].location(in: self.view)
		//
		////			let x = (max(location1.x, location2.x) - min(location1.x, location2.x)) / 2 + min(location1.x, location2.x)
		////			let y = (max(location1.y, location2.y) - min(location1.y, location2.y)) / 2 + min(location1.y, location2.y)
		////
		////			camera.position = CGPoint(x: x, y: y)
		//
		//			previousDistance = distanceSquared(location1, p2: location2)
		//
		//			deltaAngle = atan2(location1.y - view.center.y, location1.x - view.center.x)
		//		} else if touches.count == 1 {
		//			previousPoint = (touches.first?.location(in: self))!
		//
		////			cameraNode.runAction(SKAction.moveTo(previousPoint, duration: 0.25))
		//		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if touches.count == 2 {
			// This is a zoom andor rotate
			//			guard let camera = camera, let view = self.view else {
			//				return
			//			}
			//
			//			let touchArray = Array(touches)
			//			let location1 = touchArray[0].location(in: view)
			//			let location2 = touchArray[1].location(in: view) // 0.02
			//
			//			let distanceNew = distanceSquared(location1, p2: location2)

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
			//			previousDistance = distanceNew
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

		for touch in touches {
			let location = touch.location(in: self)

			let xLoc: Double = Double(location.x)
			let yLoc: Double = Double(location.y)

			// The grid is zero based
			let x: Int = (Int)(xLoc / (cellSize + cellMargin)) - 1
			let y: Int = (Int)(yLoc / (cellSize + cellMargin)) - 1

			let cell = world.update(state: .alive, x: x, y: y)
			add(cell: cell)
		}
	}


	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		isEditing = false
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		isEditing = false
	}
}
