import SpriteKit
import SwiftUI

struct ContentView: View {
    var scene: SKScene {
        let size = CGSize(width: 600, height: 600)
        let scene = GameScene(size: size)
        scene.size = size
        scene.scaleMode = .fill
        
        return scene
    }

    var body: some View {
        SpriteView(
                scene: scene,
                options: [.shouldCullNonVisibleNodes, .ignoresSiblingOrder],
                debugOptions: [.showsDrawCount, .showsNodeCount]
            )
            .frame(width: 600, height: 600)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
