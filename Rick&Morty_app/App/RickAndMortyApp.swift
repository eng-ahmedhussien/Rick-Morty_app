import SwiftUI

@main
struct RickAndMortyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Temporary shell. Replaced by the characters list navigation stack in a later step.
struct RootView: View {
    var body: some View {
        VStack{
            Text("test")
        }
    }
}

#Preview {
    RootView()
}
