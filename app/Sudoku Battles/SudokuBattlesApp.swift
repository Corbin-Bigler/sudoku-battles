import SwiftUI

@main
struct SudokuBattlesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject private var authState = AuthenticationState.shared
    @ObservedObject private var preferencesState = PreferencesState.shared
    
    var body: some Scene {
        WindowGroup {
            let finalColorScheme: ColorScheme? = preferencesState.darkMode.flatMap { $0 ? .dark : .light }
            if !authState.validating {
                NavigationContainer()
                    .environmentObject(authState)
                    .preferredColorScheme(finalColorScheme)
            } else {
                LaunchPage()
                    .preferredColorScheme(finalColorScheme)
            }
        }
    }
}
