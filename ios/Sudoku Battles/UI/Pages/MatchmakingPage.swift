import SwiftUI

struct MatchmakingPage: View {
    @EnvironmentObject var navState: NavigationState

    @State private var duelRepo: DuelRepo?
    
    var user: AppUser
    var userData: UserData
    
    var body: some View {
        VStack {
            if let duelRepo {
                DuelView(duelRepo: duelRepo, user: user, userData: userData)
            } else {
                VStack {
                    HStack(spacing: 0) {
                        ZStack {
                            Image("ChevronIcon")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 12)
                                .foregroundStyle(Color.white)
                        }
                        .frame(width: 40, height: 40)
                        .circleButton(outline: .white) {
                            MatchmakingRepo.shared.cancelMatchmaking(uid: user.uid)
                            navState.navigate(back: 1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    Spacer()
                    VStack(spacing: 20) {
                        Image("DuelIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                        
                        Text("MATCHMAKING...")
                            .font(.sora(14, .semibold))
                            .kerning(1.4)
                    }
                    Spacer()
                }
                .foregroundStyle(.white)
            }
        }
        .onAppear {
            MatchmakingRepo.shared.startMatchmaking(uid: user.uid) { duelId in
                Task {
                    let duelRepo = try? await DuelRepo(friendlyId: user.uid, duelId: duelId)
                    Main { self.duelRepo = duelRepo }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background {
            ZStack {
                Color.purple400
                Image("SquareNoise")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden()
    }
}

private struct DuelView: View {
    @ObservedObject var duelRepo: DuelRepo
    @State var subscribing: Bool = true
    
    var user: AppUser
    var userData: UserData

    var body: some View {
        if subscribing {
            Text("FOUND A DUEL")
                .foregroundStyle(.white)
                .font(.sora(14, .semibold))
                .kerning(1.4)
                .onAppear {
                    Task {
                        try? await duelRepo.subscribe()
                        Main {subscribing = false}
                    }
                }
        } else if duelRepo.secondsSinceStart >= 0 {
            DuelPage(duelRepo: duelRepo, user: user, userData: userData)
                .frame(maxHeight: .infinity)
                .background(.white)
        } else {
            VStack {
                Text("STARTING IN")
                    .font(.sora(14, .semibold))
                    .kerning(1.4)
                let startingIn = abs(duelRepo.secondsSinceStart)
                Spacer()
                    .frame(height: 20)
                ZStack {
                    let transition = AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))

                    Text("\(startingIn)")
                        .frame(maxWidth: .infinity)
                        .font(.sora(96, .semibold))
                        .id(startingIn)
                        .transition(transition)
                        .animation(.easeInOut(duration: 0.5), value: startingIn)
                }
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    MatchmakingPage(user: Mock.appUser, userData: Mock.userData)
}
