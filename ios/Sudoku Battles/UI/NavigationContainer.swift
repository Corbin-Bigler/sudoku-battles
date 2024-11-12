import SwiftUI

struct NavigationContainer: View {
    @ObservedObject var authState = AuthenticationState.shared
    @ObservedObject var gamesState = GamesState.shared
    @StateObject private var navRoute: NavigationState
    init(navRoute: NavigationState = NavigationState()) {
        self._navRoute = StateObject(wrappedValue: navRoute)
    }

    var body: some View {
        VStack{
            NavigationStack(path: $navRoute.path) {
                Group {
                    if let user = authState.user, let userData = authState.userData, !gamesState.games.isEmpty {
                        HomePage(user: user, userData: userData)
                    } else if let user = authState.user, let userData = authState.userData {
                        PlayPage(user: user, userData: userData)
                    } else {
                        LandingPage()
                    }
                }
                .navigationDestination(for: NavigationState.Page.self) { page in
                    page.view
                }
            }
            .environmentObject(navRoute)
        }
    }
}

struct NavigationContainerPreview: View {
    @State private var navRoute: NavigationState
    @State private var authState = AuthenticationState.shared

    init(setup: ()->() = {}, @ViewBuilder content: ()->any View) {
        let navRoute = NavigationState()
        navRoute.navigate(content: content)
        self._navRoute = State(wrappedValue: navRoute)
        setup()
    }
    
    var body: some View {
        NavigationContainer(navRoute: navRoute)
            .environmentObject(authState)
    }
}
