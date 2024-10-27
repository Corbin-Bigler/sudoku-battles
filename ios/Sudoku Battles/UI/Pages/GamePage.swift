import SwiftUI
import FirebaseFirestore

struct GamePage: View {
    @EnvironmentObject private var authState: AuthenticationState
    @EnvironmentObject private var navState: NavigationState
    @State private var error: Bool = false
    @State private var gameRepo: GameRepo?
    @State private var timer: Timer?
    @State private var secondsSinceStart: Int?
    
    let user: AppUser
    let userData: UserData
    let gameId: String
    
    func startTimer() {
        guard let gameRepo else {return}
        self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(gameRepo.startTime.seconds)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(gameRepo.startTime.seconds)
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
            if let gameRepo {
                ActiveGame(userData:userData, gameRepo: gameRepo)
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
                    let gameRepo = try await GameRepo(friendlyId: user.uid, gameId: gameId)
                    try await gameRepo.subscribe()
                    Main {
                        self.gameRepo = gameRepo
                        startTimer()
                    }
                } catch {
                    logger.error("Could not load game")
                }
            }
        }
        .onDisappear {
            gameRepo?.unsubscribe()
        }
    }
}

private struct ActiveGame: View {
    let userData: UserData
    @ObservedObject private var gameRepo: GameRepo
    @State private var notes: Bool = false
    
    init(userData: UserData, gameRepo: GameRepo) {
        self.userData = userData
        self._gameRepo = ObservedObject(wrappedValue: gameRepo)
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
                        Image("UserProfile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                        CircluarProgress(progress: gameRepo.friendlyBoard.percentageComplete, color: .blue400, size: 52, lineWidth: 4)
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
                        Image("UserProfile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                        CircluarProgress(progress: gameRepo.enemyBoard.percentageComplete, color: .pink400, size: 52, lineWidth: 4)
                    }
                    .offset(x: 2)
                    VStack(spacing: 4) {
                        Text(gameRepo.enemyData.username)
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
            let binding = Binding(get: {gameRepo.friendlyBoard}, set: {gameRepo.updateFriendlyBoard(board: $0)})
            SudokuBoard(model: binding)
        }
        .navigationBarBackButtonHidden()
    }
}

struct CustomToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(isOn ? Color.purple400 : Color.purple50)
                .animation(.easeInOut(duration: 0.3), value: isOn)
                .frame(width: 60, height: 30)

            HStack {
                if isOn { Spacer() }
                Circle()
                    .frame(width: 26, height: 26)
                    .foregroundColor(Color.white)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isOn)
                if !isOn { Spacer() }
            }
            .padding(2)
        }
        .frame(width: 60, height: 30)
    }
}


#Preview {
    GamePage(user: Mock.appUser, userData: Mock.userData, gameId: "mockGameId")
}
