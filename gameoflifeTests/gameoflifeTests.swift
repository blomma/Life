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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformance() {
        // This is an example of a performance test case.
		let world: World = World(width: 80, height: 80)
		
        self.measure {
			for _ in 0...20 {
				let _ = world.update()
			}
        }
    }
    
}
