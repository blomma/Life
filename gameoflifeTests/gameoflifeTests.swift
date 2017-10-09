//
//  gameoflifeTests.swift
//  gameoflifeTests
//
//  Created by Mikael Hultgren on 19/06/16.
//  Copyright © 2016 Mikael Hultgren. All rights reserved.
//

import XCTest
@testable import gameoflife

class gameoflifeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func setUpWorld(width: Int, height: Int) -> World {
        let world: World = World(width: width, height: height)
        
        let _ = world.update(state: .dead, x: 19, y: 20)
        let _ = world.update(state: .alive, x: 20, y: 20)
        
        let _ = world.update(state: .dead, x: 19, y: 19)
        let _ = world.update(state: .dead, x: 20, y: 19)
        let _ = world.update(state: .alive, x: 21, y: 19)
        
        let _ = world.update(state: .alive, x: 19, y: 18)
        let _ = world.update(state: .alive, x: 20, y: 18)
        let _ = world.update(state: .alive, x: 21, y: 18)

        return world;
    }
    
    func testPerformance() {
		let world: World = World(width: 80, height: 80)
		
        self.measure {
            let _ = world.update()
        }
    }

	func testPerformanceAlive() {
		let world = setUpWorld(width: 80, height: 80)
		
        self.measure {
            let _ = world.update()
        }
	}
	
	func testPerformanceAlive_200_200() {
		let world = setUpWorld(width: 200, height: 200)
		
        self.measure {
            let _ = world.update()
        }
	}
		
	func testPerformanceAlive_82_147() {
		let world = setUpWorld(width: 82, height: 147)
		
        self.measure {
            let _ = world.update()
        }
	}
}
