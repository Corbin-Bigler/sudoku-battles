import SwiftUI

struct MatchmakingPage: View {
    @EnvironmentObject var navRoute: NavigationState
    
    var user: AppUser
    
    var body: some View {
        VStack {
            Text("Matchmaking")
            Button(action: {
                MatchmakingRepo.shared.cancelMatchmaking(uid: user.uid)
                navRoute.clear()
            }) {
                Text("Cancel")
            }
        }
        .navigationBarBackButtonHidden()
        
    }
}

#Preview {
    MatchmakingPage(user: Mock.appUser)
}
