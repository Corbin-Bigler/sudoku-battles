import SwiftUI
import FirebaseFirestore

struct DuelPage: View {
    @EnvironmentObject private var authState: AuthenticationState
    @EnvironmentObject private var navState: NavigationState
    @ObservedObject private var duelRepo: DuelRepo
    
    @State private var showExit = false
    @State private var error = false
    @State private var timer: Timer?
    
    let user: AppUser
    let userData: UserData
    
    init(duelRepo: DuelRepo, user: AppUser, userData: UserData) {
        self._duelRepo = ObservedObject(wrappedValue: duelRepo)
        self.user = user
        self.userData = userData
    }
       
    func formatedTime(seconds totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        var text = ""
        if hours > 0 { text += hours > 9 ? "\(hours):" : "0\(hours):" }
        text += minutes > 9 ? "\(minutes):" : "0\(minutes):"
        text += seconds > 9 ? "\(seconds)" : "0\(seconds)"
        return text
    }
    
    var timerText: String {
        let totalSeconds = duelRepo.endTime.flatMap { $0.seconds - duelRepo.startTime.seconds } ?? Int64(duelRepo.secondsSinceStart)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return (hours > 0 ? "\(hours)H " : "") + "\(minutes)M \(seconds)S"
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
                    showExit = true
                }
                Spacer()
                
                HStack(spacing: 6) {
                    Image("AlarmIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text(timerText)
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
                            .frame(height: 10)
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
                            .frame(height: 10)
                    }
                    .padding(10)
                    .background(.yellow400.opacity(0.15))
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 14))
                }

                let binding = Binding(get: {duelRepo.friendlyBoard}, set: {duelRepo.updateFriendlyBoard(board: $0)})
                SudokuBoard(model: binding)
            }

        }
        .foregroundStyle(.black)
        .overlay(isPresented: showExit) {
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                        .frame(width: 12)
                    Spacer()
                    Text("Duel in Progress")
                        .font(.sora(20, .semibold))
                    Spacer()
                    Image("CloseIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12)
                }
                
                Text("Please be aware that the duel will not stop if you leave. Would you like to forfeit instead?")
                    .font(.sora(16))
                    .multilineTextAlignment(.center)
                       
                HStack {
                    RoundedButton(label: "Forfeit", color: .red400, outlined: true) {
                        navState.clear()
                    }
                    RoundedButton(label: "Cancel", color: .blue400) {
                        showExit = false
                    }
                }
            }
            .frame(maxWidth: 335)
            .padding(16)
            .background(Color.white)
            .cornerRadius(11)
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(.gray100, lineWidth: 1)
            }
            .padding(16)
        }
        .overlay(isPresented: duelRepo.won != nil) {
            let won = duelRepo.won!
            
            VStack(spacing: 12) {
                ZStack {
                    Text(won ? "You Won!" : "You Lost!")
                        .font(.sora(20, .semibold))
                    HStack {
                        Spacer()
                        
                        Text("\(duelRepo.difficulty.title)")
                            .font(.sora(14.85, .semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(duelRepo.difficulty.color)
                            .cornerRadius(.infinity)
                            .foregroundStyle(.white)
                    }
                }
                
                
                VStack {
                    let totalSeconds = duelRepo.endTime!.seconds - duelRepo.startTime.seconds

                    Text(formatedTime(seconds: Int(totalSeconds)))
                        .font(.sora(18, .semibold))
                    
                    HStack(spacing: 5) {
                        VStack(spacing: 5) {
                            Text("You")
                                .font(.sora(14, .semibold))
                            LinearProgress(progress: duelRepo.friendlyBoard.percentageComplete, color: .green400)
                                .frame(height: 12)
                            Text("100")
                                .font(.sora(14, .semibold))
                                .padding(.horizontal, 7.5)
                                .padding(.vertical, 2)
                                .background(.blue400)
                                .cornerRadius(.infinity)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(5)
                        .background(Color.green400.opacity(0.15))
                        .cornerRadius(9)
                        .overlay {
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color.green400.opacity(0.6))
                        }
                        VStack(spacing: 5) {
                            Text(duelRepo.enemyData.username)
                                .font(.sora(14, .semibold))
                            LinearProgress(progress: duelRepo.enemyBoard.percentageComplete, color: .yellow400)
                                .frame(height: 12)
                            Text("100")
                                .font(.sora(14, .semibold))
                                .padding(.horizontal, 7.5)
                                .padding(.vertical, 2)
                                .background(.blue400)
                                .cornerRadius(.infinity)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(5)
                        .background(Color.yellow400.opacity(0.15))
                        .cornerRadius(9)
                        .overlay {
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color.yellow400.opacity(0.6))
                        }
                    }
                }
                
                RoundedButton(label: "OK", color: .blue400) {
                    navState.clear()
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(11)
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(.gray100, lineWidth: 1)
            }
            .padding(16)
        }
        .navigationBarBackButtonHidden()
        .onDisappear {
            duelRepo.unsubscribe()
        }
        
    }
}

private struct DuelPagePreview: View {
    var body: some View {
        DuelPage(
            duelRepo: DuelRepo(
                friendlyId: "mockUid",
                duelId: "mockGameId",
                firstIsFirendly: true,
                friendlyBoard: Mock.sudokuBoard,
                enemyBoard: Mock.correctSudokuBoard,
                enemyData: Mock.userData,
                startTime: Timestamp.init(),
                won: true
            ),
            user: Mock.appUser,
            userData: Mock.userData
        )
    }
}
#Preview {
    DuelPagePreview()
}
