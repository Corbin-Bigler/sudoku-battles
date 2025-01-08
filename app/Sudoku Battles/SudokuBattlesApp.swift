import SwiftUI

@main
struct SudokuBattlesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject private var authState = AuthenticationState.shared
    @ObservedObject private var preferencesState = PreferencesState.shared
    
    var body: some Scene {
        WindowGroup {
            let finalColorScheme = preferencesState.darkMode.flatMap { $0 ? .dark : .light } ?? colorScheme
            if !authState.validating && !authState.unableToContactFirebase {
                NavigationContainer()
                    .environmentObject(authState)
                    .preferredColorScheme(finalColorScheme)
            } else {
                LaunchPage()
                    .alert("Network Error", isPresented: $authState.unableToContactFirebase) {
                        Button("Retry", role: .cancel) {
                            authState.initialize()
                        }
                    } message: {
                        Text("Unable to connect to server.")
                    }
                    .preferredColorScheme(finalColorScheme)
            }
        }
    }
}
