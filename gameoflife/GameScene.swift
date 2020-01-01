import SpriteKit
import Darwin

class GameScene: SKScene {
	private struct Action {
		static let pinch = #selector(GameScene.pinch(_:))
	}

	var nodesInWorld = Dictionary<Int, SKSpriteNode>()

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

	var pinch: UIPinchGestureRecognizer?
	var previousScale: CGFloat = 0

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

		let _ = world.update(state: .alive, x: 20, y: 20)
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

//        let pinch = UIPinchGestureRecognizer(target: self, action: Action.pinch)
//        self.pinch = pinch
//        self.view?.addGestureRecognizer(pinch)

		worldNode.position.x += CGFloat(xOffset)
		worldNode.position.y += CGFloat(yOffset)
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

		let node = SKSpriteNode()
		node.color = UIColor.orange
		node.size = CGSize(width: cellSize, height: cellSize)
		node.position = CGPoint(x: px, y: py)
		if withAnimation {
			node.alpha = 0
		}

		nodesInWorld[cell.x * 1000 + cell.y] = node

		worldNode.addChild(node)

        if withAnimation {
            node.removeAllActions()
            node.run(SKAction.fadeIn(withDuration: 0.2))
        }
	}

	func remove(cell: Cell, withAnimation: Bool = true) -> Void {
		if let node: SKSpriteNode = nodesInWorld[cell.x * 1000 + cell.y] {
            if withAnimation {
                node.removeAllActions()
                let actions = SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent()
                    ])

                node.run(actions, completion: { [unowned self] in
                    let _ = self.nodesInWorld.removeValue(forKey: cell.x * 1000 + cell.y)
                })
            } else {
                node.removeAllActions()
				node.run(SKAction.removeFromParent(), completion: { [unowned self] in
					let _ = self.nodesInWorld.removeValue(forKey: cell.x * 1000 + cell.y)
				})
            }
		}
	}

	var lastUpdate: TimeInterval = 0
	override func update(_ currentTime: TimeInterval) {
		if lastUpdate == 0 {
			lastUpdate = currentTime
		}

//        if isEditing {
//            return
//        }

		if currentTime - lastUpdate < 1 {
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

// MARK: - Touches
extension GameScene {
	func CGPointAdd(point1: CGPoint, point2: CGPoint) -> CGPoint {
		return CGPoint(x: point1.x + point2.x, y: point1.y + point2.y)
	}

	func CGPointSubtract(point1: CGPoint, point2: CGPoint) -> CGPoint {
		return CGPoint(x: point1.x - point2.x, y: point1.y - point2.y)
	}

	@objc func pinch(_ recognizer: UIPinchGestureRecognizer) -> Void {
		switch recognizer.state {
		case .began:
			previousScale = recognizer.scale
		case .changed:
			var p = recognizer.location(in: self.view)
			p = convertPoint(fromView: p)

			var scaleTo: CGFloat = 0
			let d = abs(previousScale - recognizer.scale)
			if recognizer.scale < previousScale {
				scaleTo = worldNode.xScale - d
			} else {
				scaleTo = worldNode.xScale + d
			}

			previousScale = recognizer.scale

			scaleTo = scaleTo < 1 ? 1 : scaleTo

			let anchorPointInScene = convert(p, from: worldNode)
			let translationOfAnchorInScene = CGPointSubtract(point1: p, point2: anchorPointInScene)

			worldNode.setScale(scaleTo)
			worldNode.position = CGPointAdd(point1: worldNode.position, point2: translationOfAnchorInScene)
		default:
			break
		}
	}

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isEditing = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            let xLoc: Double = Double(location.x)
            let yLoc: Double = Double(location.y)

            // The grid is zero based
            let x: Int = (Int)(xLoc / (cellSize + cellMargin))
            let y: Int = (Int)(yLoc / (cellSize + cellMargin))

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
