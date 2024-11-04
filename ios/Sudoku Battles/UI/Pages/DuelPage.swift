import SwiftUI
import FirebaseFirestore

struct DuelPage: View {
    @EnvironmentObject private var authState: AuthenticationState
    @EnvironmentObject private var navState: NavigationState
    @State private var error: Bool = false
    @State private var duelRepo: DuelRepo?
    @State private var timer: Timer?
    @State private var secondsSinceStart: Int?
    @State private var won: Bool?
    
    let user: AppUser
    let userData: UserData
    let gameId: String
    
    func startTimer() {
        guard let duelRepo else {return}
        self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(duelRepo.startTime.seconds)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(duelRepo.startTime.seconds)
        }
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
                
                if let secondsSinceStart {
                    let minutes = secondsSinceStart / 60
                    let seconds = secondsSinceStart % 60
                    
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
                }
                
                Spacer()
                ZStack {
                    Image("GearIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.black)
                }
                .frame(width: 40, height: 40)
                .circleButton {}
            }
            .padding(.horizontal, 16)
            if let duelRepo {
                ActiveGame(userData:userData, duelRepo: duelRepo)
                    .padding(.horizontal, 16)
            } else {
                Spacer()
                LoadingIndicator()
            }
            Spacer()
        }
        .onAppear {
            Task {
                do {
                    let duelRepo = try await DuelRepo(friendlyId: user.uid, duelId: gameId)
                    try await duelRepo.subscribe()
                    Main {
                        self.duelRepo = duelRepo
                        startTimer()
                    }
                } catch {
                    logger.error("Could not load game")
                }
            }
        }
        .onDisappear {
            duelRepo?.unsubscribe()
        }
    }
}

private struct ActiveGame: View {
    let userData: UserData
    @EnvironmentObject private var navState: NavigationState
    @ObservedObject private var duelRepo: DuelRepo
    @State private var notes: Bool = false
    @State private var friendlyProfilePicture: Image?
    @State private var enemyProfilePicture: Image?
    
    init(userData: UserData, duelRepo: DuelRepo) {
        self.userData = userData
        self._duelRepo = ObservedObject(wrappedValue: duelRepo)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 6) {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text(userData.username)
                            .font(.sora(13, .semibold))
                            .lineLimit(1)
                        HStack(spacing: 20) {
                            HStack(spacing: 3) {
                                Image("ErrorIcon")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.gray200)
                                Image("ErrorIcon")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.gray200)
                                Image("ErrorIcon")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.gray200)
                            }
                            Text("100")
                                .font(.sora(14, .semibold))
                                .frame(width: 44, height: 22)
                                .background(.blue400)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 11))
                        }
                    }
                    ZStack {
                        (friendlyProfilePicture ?? Image("UserProfile"))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                        CircluarProgress(progress: duelRepo.friendlyBoard.percentageComplete, color: .blue400, size: 52, lineWidth: 4)
                    }
                    .offset(x: -2)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background {
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .blue100]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 30, topTrailingRadius: 30))
                
                HStack {
                    ZStack {
                        (enemyProfilePicture ?? Image("UserProfile"))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                        CircluarProgress(progress: duelRepo.enemyBoard.percentageComplete, color: .pink400, size: 52, lineWidth: 4)
                    }
                    .offset(x: 2)
                    VStack(spacing: 4) {
                        Text(duelRepo.enemyData.username)
                            .lineLimit(1)
                            .font(.sora(13, .semibold))
                        HStack(spacing: 20) {
                            HStack(spacing: 3) {
                                Image("ErrorIcon")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.gray200)
                                Image("ErrorIcon")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.gray200)
                                Image("ErrorIcon")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundStyle(.gray200)
                            }
                            Text("100")
                                .font(.sora(14, .semibold))
                                .frame(width: 44, height: 22)
                                .background(.pink400)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 11))
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background {
                    LinearGradient(
                        gradient: Gradient(colors: [.pink100, .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 30))

            }
            let binding = Binding(get: {duelRepo.friendlyBoard}, set: {duelRepo.updateFriendlyBoard(board: $0)})
            SudokuBoard(model: binding)
                .overlay {
                    if Bundle.main.dev {
                        VStack {
                            Button(action: {
                                Task {
                                    guard let solution = try? await FirestoreDs.shared.getSolution(duelId: duelRepo.duelId),
                                          let board = SudokuBoardModel(given: duelRepo.friendlyBoard.givenString, board: solution)
                                    else { return }
                                    duelRepo.updateFriendlyBoard(board: board)
                                }
                            }) {
                                Text("Fill Board")
                            }
                            Spacer()
                        }
                        .offset(y: -20)
                    }
                }
        }
        .onAppear {
            Task {
                if let profilePicture = userData.profilePicture {
                    Task {
                        do {
                            let imageData = try await StorageDs.shared.data(from: profilePicture)
                            if let uiImage = UIImage(data: imageData) {
                                friendlyProfilePicture = Image(uiImage: uiImage)
                            } else {
                                friendlyProfilePicture = Image("UserProfile")
                            }
                        } catch {
                            friendlyProfilePicture = Image("UserProfile")
                        }
                    }
                } else {
                    friendlyProfilePicture = Image("UserProfile")
                }
                
                if let profilePicture = duelRepo.enemyData.profilePicture {
                    Task {
                        do {
                            let imageData = try await StorageDs.shared.data(from: profilePicture)
                            if let uiImage = UIImage(data: imageData) {
                                enemyProfilePicture = Image(uiImage: uiImage)
                            } else {
                                enemyProfilePicture = Image("UserProfile")
                            }
                        } catch {
                            logger.error("\(error)")
                            enemyProfilePicture = Image("UserProfile")
                        }
                    }
                } else {
                    enemyProfilePicture = Image("UserProfile")
                }

            }
        }
        .navigationBarBackButtonHidden()
//        .errorOverlay(
//            Binding(
//                get: {
//                    guard let won = duelRepo.won else { return nil }
//                    if won { return ErrorOverlayModel(title: "You Won!", body: "You beat \(duelRepo.enemyData.username)") }
//                    else { return ErrorOverlayModel(title: "You Suck!", body: "You lost to \(duelRepo.enemyData.username)") }
//                },
//                set: {
//                    if $0 == nil {
//                        navState.clear()
//                    }
//                }
//            )
//        )
    }
}

#Preview {
    DuelPage(user: Mock.appUser, userData: Mock.userData, gameId: "mockGameId")
}
