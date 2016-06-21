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
    
    func testPerformance() {
		let world: World = World(width: 80, height: 80)
		
        self.measure {
			for _ in 0...20 {
				let _ = world.update()
			}
        }
    }

	func testPerformanceAlive() {
		let world: World = World(width: 80, height: 80)
		
		for y in 0..<80 {
			for x in 0..<80 {
				let _ = world.update(state: .alive, x: x, y: y)
			}
		}
		
		self.measure {
			for _ in 0...20 {
				let _ = world.update()
			}
		}
	}
	
	func testPerformance_200_200() {
		let world: World = World(width: 200, height: 200)
		
		self.measure {
			for _ in 0...20 {
				let _ = world.update()
			}
		}
	}
	
	func testPerformanceAlive_200_200() {
		let world: World = World(width: 200, height: 200)
		
		for y in 0..<200 {
			for x in 0..<200 {
				let _ = world.update(state: .alive, x: x, y: y)
			}
		}
		
		self.measure {
			for _ in 0...20 {
				let _ = world.update()
			}
		}
	}
	
	func testPerformance_82_147() {
		let world: World = World(width: 82, height: 147)
		
		self.measure {
			for _ in 0...20 {
				let _ = world.update()
			}
		}
	}
	
	func testPerformanceAlive_82_147() {
		let world: World = World(width: 82, height: 147)
		
		for y in 0..<147 {
			for x in 0..<82 {
				let _ = world.update(state: .alive, x: x, y: y)
			}
		}
		
		self.measure {
			for _ in 0...20 {
				let _ = world.update()
			}
		}
	}
}
