import XCTest

@testable import Life

final class LifeTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        let _ = world.update()

        self.measure {
            let _ = world.update()
        }
    }

    func testPerformanceAlive() {
        let world = setUpWorld(width: 80, height: 80)
        let _ = world.update()

        self.measure {
            let _ = world.update()
        }
    }
    
    func testPerformanceAlive_200_200() {
        let world = setUpWorld(width: 200, height: 200)
        let _ = world.update()

        self.measure {
            let _ = world.update()
        }
    }
        
    func testPerformanceAlive_800_800() {
        let world = setUpWorld(width: 800, height: 800)
        let _ = world.update()
        
        self.measure {
            let _ = world.update()
        }
    }
    
    func testPerformanceAlive_82_147() {
        let world = setUpWorld(width: 82, height: 147)
        let _ = world.update()

        self.measure {
            let _ = world.update()
        }
    }
}
