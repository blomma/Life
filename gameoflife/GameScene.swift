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
    let cellSize: Double = 10
    let cellMargin: Double = 2
    
    override init(size: CGSize) {
        var cells: [Cell] = [Cell]()
        
        let noX: Int = Int(Double(size.width)/(cellSize + 2 * cellMargin))
        let noY: Int = Int(Double(size.height)/(cellSize + 2 * cellMargin))

        for x in 1...noX {
            for y in 1...noY {
                cells.append(Cell(x: x, y: y, state: .Alive))
            }
        }
        
//        cells.append(Cell(x: 21, y: 21, state: .Alive))
//        cells.append(Cell(x: 22, y: 22, state: .Alive))
//        cells.append(Cell(x: 20, y: 23, state: .Alive))
//        cells.append(Cell(x: 21, y: 23, state: .Alive))
//        cells.append(Cell(x: 22, y: 23, state: .Alive))
//
//        cells.append(Cell(x: 30, y: 13, state: .Alive))
//        cells.append(Cell(x: 30, y: 14, state: .Alive))
//        cells.append(Cell(x: 30, y: 15, state: .Alive))
        
        world = World(cells: cells)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    }
    
    override func update(currentTime: CFTimeInterval) {
        world = world.updateWorld()
        
        self.removeAllChildren()
        
        let aliveCells: [Cell] = world.cells.filter{ $0.state == CellState.Alive }
        
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
