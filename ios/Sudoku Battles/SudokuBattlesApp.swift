import SwiftUI

@main
struct SudokuBattlesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @ObservedObject private var authState = AuthenticationState.shared

    var body: some Scene {
        WindowGroup {
            if !authState.validating && !authState.unableToContactFirebase {
                NavigationContainer()
                    .environmentObject(authState)
                    .preferredColorScheme(.light)
            } else {
                LaunchPage()
                    .alert("Network Error", isPresented: $authState.unableToContactFirebase) {
                        Button("Retry", role: .cancel) {
                            authState.initialize()
                        }
                    } message: {
                        Text("Unable to connect to server.")
                    }
            }
        }
    }
}
