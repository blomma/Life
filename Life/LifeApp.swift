import SwiftUI

@main
struct LifeApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            ContentView().frame(minWidth: 600, maxWidth: 600, minHeight: 600, maxHeight: 600, alignment: .center)
            #else
            ContentView()
            #endif
        }
    }
}
