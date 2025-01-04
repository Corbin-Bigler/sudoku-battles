import SwiftUI
import FirebaseFirestore

struct DuelPage: View {
    @EnvironmentObject private var authState: AuthenticationState
    @EnvironmentObject private var navState: NavigationState
    @ObservedObject private var duelRepo: DuelRepo
    @State private var error: Bool = false
    @State private var timer: Timer?
    @State private var won: Bool?
    
    let user: AppUser
    let userData: UserData
    
    init(duelRepo: DuelRepo, user: AppUser, userData: UserData) {
        self._duelRepo = ObservedObject(wrappedValue: duelRepo)
        self.user = user
        self.userData = userData
    }
        
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                ZStack {
                    Image("ChevronIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                        .foregroundStyle(Color.black)
                }
                .frame(width: 40, height: 40)
                .circleButton {
                    navState.clear()
                }
                Spacer()
                
                let minutes = duelRepo.secondsSinceStart / 60
                let seconds = duelRepo.secondsSinceStart % 60
                
                HStack(spacing: 6) {
                    Image("AlarmIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("\(minutes)M \(seconds)S")
                        .font(.sora(16, .semibold))
                }
                .frame(height: 36)
                .padding(.horizontal, 16)
                .foregroundStyle(.red400)
                .background(.red50)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onTapGesture(count: 2) {
                    if(Bundle.main.dev) {
                        Task {
                            guard let solution = try? await FirestoreDs.shared.getSolution(duelId: duelRepo.duelId),
                                  let board = SudokuBoardModel(given: duelRepo.friendlyBoard.givenString, board: solution)
                            else { return }
                            duelRepo.updateFriendlyBoard(board: board)
                        }
                    }
                }
                
                Spacer()
                Spacer()
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            VStack(spacing: 20) {
                HStack(spacing: 11) {
                    VStack {
                        HStack {
                            Text(userData.username)
                                .font(.sora(13, .semibold))
                                .lineLimit(1)
                            Text("100")
                                .font(.sora(14, .semibold))
                                .frame(width: 44, height: 22)
                                .background(.blue400)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 11))
                        }
                        LinearProgress(progress: duelRepo.friendlyBoard.percentageComplete, color: .green400)
                    }
                    .padding(10)
                    .background(.green400.opacity(0.15))
                    .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 14, topTrailingRadius: 14))
                    Text("vs")
                        .font(.sora(13, .semibold))
                    VStack {
                        HStack {
                            Text(duelRepo.enemyData.username)
                                .font(.sora(13, .semibold))
                                .lineLimit(1)
                            Text("100")
                                .font(.sora(14, .semibold))
                                .frame(width: 44, height: 22)
                                .background(.blue400)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 11))
                        }
                        LinearProgress(progress: duelRepo.enemyBoard.percentageComplete, color: .yellow400)
                    }
                    .padding(10)
                    .background(.yellow400.opacity(0.15))
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 14))
                }
//                HStack(spacing: 6) {
//                    HStack {
//                        Spacer()
//                        VStack(spacing: 4) {
//                            Text(userData.username)
//                                .font(.sora(13, .semibold))
//                                .lineLimit(1)
//                            HStack(spacing: 20) {
//                                HStack(spacing: 3) {
//                                    Image("ErrorIcon")
//                                        .renderingMode(.template)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 15, height: 15)
//                                        .foregroundStyle(.gray200)
//                                    Image("ErrorIcon")
//                                        .renderingMode(.template)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 15, height: 15)
//                                        .foregroundStyle(.gray200)
//                                    Image("ErrorIcon")
//                                        .renderingMode(.template)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 15, height: 15)
//                                        .foregroundStyle(.gray200)
//                                }
//                                Text("100")
//                                    .font(.sora(14, .semibold))
//                                    .frame(width: 44, height: 22)
//                                    .background(.blue400)
//                                    .foregroundStyle(.white)
//                                    .clipShape(RoundedRectangle(cornerRadius: 11))
//                            }
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 60)
//                    .background(.green400.opacity(0.1))
//                    .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 30, topTrailingRadius: 30))
//                    
//                    HStack {
//                        ZStack {
//                            Image("UserProfile")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 56, height: 56)
//                                .clipShape(Circle())
//                            CircluarProgress(progress: duelRepo.enemyBoard.percentageComplete, color: .pink400, size: 52, lineWidth: 4)
//                        }
//                        .offset(x: 2)
//                        VStack(spacing: 4) {
//                            Text(duelRepo.enemyData.username)
//                                .lineLimit(1)
//                                .font(.sora(13, .semibold))
//                            HStack(spacing: 20) {
//                                HStack(spacing: 3) {
//                                    Image("ErrorIcon")
//                                        .renderingMode(.template)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 15, height: 15)
//                                        .foregroundStyle(.gray200)
//                                    Image("ErrorIcon")
//                                        .renderingMode(.template)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 15, height: 15)
//                                        .foregroundStyle(.gray200)
//                                    Image("ErrorIcon")
//                                        .renderingMode(.template)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 15, height: 15)
//                                        .foregroundStyle(.gray200)
//                                }
//                                Text("100")
//                                    .font(.sora(14, .semibold))
//                                    .frame(width: 44, height: 22)
//                                    .background(.pink400)
//                                    .foregroundStyle(.white)
//                                    .clipShape(RoundedRectangle(cornerRadius: 11))
//                            }
//                        }
//                        Spacer()
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 60)
//                    .background(.yellow400.opacity(0.1))
//                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 30))

//                }
                let binding = Binding(get: {duelRepo.friendlyBoard}, set: {duelRepo.updateFriendlyBoard(board: $0)})
                SudokuBoard(model: binding)
            }

        }
        .foregroundStyle(.black)
        .navigationBarBackButtonHidden()

            
//            startTimer()
//            Task {
//                do {
//                    let duelRepo = try await DuelRepo(friendlyId: user.uid, duelId: gameId)
//                    try await duelRepo.subscribe()
//                    Main {
//                        self.duelRepo = duelRepo
//                        startTimer()
//                    }
//                } catch {
//                    logger.error("Could not load game")
//                }
//            }
        .onDisappear {
            duelRepo.unsubscribe()
        }
    }
}

//private struct ActiveGame: View {
//    let userData: UserData
//    @EnvironmentObject private var navState: NavigationState
//    @ObservedObject private var duelRepo: DuelRepo
//    @State private var notes: Bool = false
//    @State private var friendlyProfilePicture: Image?
//    @State private var enemyProfilePicture: Image?
//    
//    init(userData: UserData, duelRepo: DuelRepo) {
//        self.userData = userData
//        self._duelRepo = ObservedObject(wrappedValue: duelRepo)
//    }
//    
//    var body: some View {
////        .errorOverlay(
////            Binding(
////                get: {
////                    guard let won = duelRepo.won else { return nil }
////                    if won { return ErrorOverlayModel(title: "You Won!", body: "You beat \(duelRepo.enemyData.username)") }
////                    else { return ErrorOverlayModel(title: "You Suck!", body: "You lost to \(duelRepo.enemyData.username)") }
////                },
////                set: {
////                    if $0 == nil {
////                        navState.clear()
////                    }
////                }
////            )
////        )
//    }
//}
