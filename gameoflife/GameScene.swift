//
//  GameScene.swift
//  gameoflife
//
//  Created by Mikael Hultgren on 01/06/16.
//  Copyright (c) 2016 Mikael Hultgren. All rights reserved.
//

import SpriteKit
import Darwin

class GameScene: SKScene {
    var world: World
    let cellSize: Double = 2
    let cellMargin: Double = 1

    override init(size: CGSize) {
        let width: Int = Int(Double(size.width)/(cellSize + 2 * cellMargin))
        let height: Int = Int(Double(size.height)/(cellSize + 2 * cellMargin))

        world = World(width: width, height: height)
//        world.updateWorld()

        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    }

    override func update(currentTime: CFTimeInterval) {
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
