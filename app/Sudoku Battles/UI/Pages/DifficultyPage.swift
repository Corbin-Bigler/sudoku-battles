import SwiftUI

struct DifficultyPage: View {
    @EnvironmentObject private var navState: NavigationState
    @State private var index = 0
    @State private var savedGame: SoloGame?
    
    var difficulty: Difficulty { Difficulty.allCases[index] }
    var fileName: String { "sudoku-\(difficulty.title.lowercased())" }

    var body: some View {
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
                    navState.navigate(back: 1)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            VStack(spacing: 0) {
                Image("AloneIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                Spacer().frame(height: 40)
                
                let binding = Binding(
                    get: {index},
                    set: {
                        index = $0
                        savedGame = UserPreferencesDs.shared.getGame(difficulty: difficulty)
                    }
                )
                HorizontalSelector(options: Difficulty.allCases, index: binding)
                Spacer().frame(height: 30)
                
                VStack(spacing: 16) {
                    RoundedButton(label: "New Game", color: .white) {
                
                        let filename = "sudoku-\(difficulty.title.lowercased())"
                        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
                            print("could not find file \(filename)")
                            return
                        }
            
                        do {
                            let data = try Data(contentsOf: url)
            
                            let decoder = JSONDecoder()
                            let puzzles = try decoder.decode([SudokuData].self, from: data)
            
                            let puzzle = puzzles.randomElement()!
            
                            let model = SudokuBoardModel(given: puzzle.puzzle, board: puzzle.puzzle)!
                            navState.navigate {
                                SoloPage(difficulty: difficulty, game: SoloGame(model: model, solution: puzzle.solution, seconds: 0))
                            }
                        } catch {
                            print("could not decode")
                        }

                    }
                    RoundedButton(label: "Resume Game", color: .white, outlined: true) {
                        navState.navigate {
                            if let savedGame {SoloPage(difficulty: difficulty, game: savedGame)}
                        }
                    }
                    .opacity(savedGame == nil ? 0 : 1)
                    .disabled(savedGame == nil)
                }
            }
            .frame(width: 250)
            .frame(maxHeight: .infinity)
        }
        .background {
            ZStack {
                Color.green400
                Image("SquareNoise")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            savedGame = UserPreferencesDs.shared.getGame(difficulty: difficulty)
        }
    }
}

#Preview {
    DifficultyPage()
}
