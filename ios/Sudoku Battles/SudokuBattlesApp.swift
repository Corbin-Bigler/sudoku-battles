import SwiftUI

@main
struct SudokuBattlesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @ObservedObject private var authState = AuthenticationState.shared

    var body: some Scene {
        WindowGroup {
            if !authState.validating {
                NavigationContainer()
                    .environmentObject(authState)
                    .preferredColorScheme(.light)
            } else {
                LaunchPage()
            }
        }
    }
}
