import SwiftUI

struct SoloPage: View {
    @EnvironmentObject var navState: NavigationState

    @State private var model: SudokuBoardModel
    private let savedSeconds: Int
    private let solution: String
    private let difficulty: Difficulty

    @State private var startTime = Date()
    @State private var secondsSinceStart: Int = 0
    @State private var timer: Timer?
    @State private var changed = false

    var seconds: Int { savedSeconds + secondsSinceStart }
    var minutesText: String { "\(seconds / 60)" }
    var secondsText: String { "\(seconds % 60)" }
    var isSolved: Bool { model.boardString == solution }
    
    init(difficulty: Difficulty, game: SoloGame) {
        self.solution = game.solution
        self._model = State(wrappedValue: game.model)
        self.difficulty = difficulty
        self.savedSeconds = game.seconds
    }
    
    func updateModel(_ model: SudokuBoardModel) {
        self.changed = true
        self.model = model
        UserPreferencesDs.shared.save(game: SoloGame(
            model: model,
            solution: solution,
            seconds: seconds
        ), difficulty: difficulty)
        
        if isSolved {timer?.invalidate()}
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ZStack {
                    Image("ChevronIcon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                        .foregroundStyle(Color.black)
                }
                .frame(width: 40, height: 40)
                .circleButton(outline: .black) {
                    navState.navigate(back: 1)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            HStack(spacing: 6) {
                Image("AlarmIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                
                Text("\(minutesText)M \(secondsText)S")
                    .font(.sora(16, .semibold))
            }
            .frame(height: 36)
            .padding(.horizontal, 16)
            .foregroundStyle(.red400)
            .background(.red50)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onTapGesture(count: 2) {
                if Bundle.main.dev {
                    updateModel(SudokuBoardModel(given: model.givenString, board: solution)!)
                }
            }
            
            Spacer()

            let binding = Binding(get: {model}, set: {updateModel($0)})
            SudokuBoard(model: binding)
                .padding(.horizontal, 3)

        }
        .overlay(isPresented: isSolved) {
            VStack(spacing: 16) {
                Text("Congratulations")
                    .font(.sora(20, .semibold))
                
                VStack {
                    let formattedSeconds = secondsText.count == 1 ? "0\(secondsText)" : secondsText
                    Text("\(minutesText):\(formattedSeconds)")
                        .font(.sora(32, .semibold))
                    Text("\(difficulty.rawValue)")
                        .font(.sora(14.5, .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(difficulty.color)
                        .cornerRadius(.infinity)
                        .foregroundStyle(.white)
                }
                
                RoundedButton(label: "OK", color: .blue400) {
                    UserPreferencesDs.shared.deleteGame(difficulty: difficulty)
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
        .onAppear {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(startTime.timeIntervalSince1970)
                if changed || savedSeconds > 0 {updateModel(model)}
            }
        }
        .onDisappear {
            self.timer?.invalidate()
        }
    }
}

#Preview {
    SoloPage(difficulty: .easy, game: SoloGame(model: Mock.sudokuBoard, solution: Mock.sudokuBoard.boardString, seconds: 0))
}
