import SwiftUI
import FirebaseFirestore

struct HomePage: View {
    @EnvironmentObject private var authState: AuthenticationState
    @EnvironmentObject private var navState: NavigationState
        
    let user: AppUser
    let userData: UserData
    
    var body: some View {
        VStack {
            Text("Home Page")
            Text("UID: \(user.uid)")
            Text("Username: \(userData.username)")
            
            Button(action: {
                Main { navState.navigate { MatchmakingPage(user: user) } }
                MatchmakingRepo.shared.startMatchmaking(uid: user.uid) { gameId in
                    Main {
                        navState.clear()
                        navState.navigate { GamePage(user: user, userData: userData, gameId: gameId) }
                    }
                }
            }) {
                Text("Start Matchmaking")
            }
            Button(action: {authState.logOut()}) {
                Text("Sign Out")
            }
        }
    }
}

#Preview {
    HomePage(user: Mock.appUser, userData: Mock.userData)
}
