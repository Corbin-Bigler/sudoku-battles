import SwiftUI

struct MatchmakingPage: View {
    @EnvironmentObject var navState: NavigationState

    @State private var duelRepo: DuelRepo?
    
    var user: AppUser
    var userData: UserData
    
    var body: some View {
        VStack {
            if let duelRepo {
                DuelStartPage(duelRepo: duelRepo, user: user, userData: userData)
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
            MatchmakingRepo.shared.startMatchmaking(uid: user.uid) { duelReference in
                Task {
                    if duelReference.parent.collectionID == FirestoreDs.botDuelsCollectionId {
                        do {
                            let duelStrategy = try await BotDuelStrategy(duelReference)
                            Main { self.duelRepo = DuelRepo(strategy: duelStrategy) }
                        } catch {
                            logger.error("\(error)")
                        }
                    } else if duelReference.parent.collectionID == FirestoreDs.playerDuelsCollectionId {
                        do {
                            let duelStrategy = try await PlayerDuelStrategy(duelReference, friendlyUid: user.uid)
                            Main { self.duelRepo = DuelRepo(strategy: duelStrategy) }
                        } catch {
                            logger.error("\(error)")
                        }
                    }
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

#Preview {
    MatchmakingPage(user: Mock.appUser, userData: Mock.userData)
}
