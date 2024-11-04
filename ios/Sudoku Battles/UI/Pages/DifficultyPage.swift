import SwiftUI

struct DifficultyPage: View {
    @EnvironmentObject private var navState: NavigationState
    @State private var index = 0
    @State private var savedGame: SudokuBoardModel?
    
    var difficulty: Difficulty { Difficulty.allCases[index] }
    var fileName: String { "sudoku-\(difficulty.rawValue.lowercased())" }
    
    init() {
        savedGame = UserPreferencesDs.shared.getSudokuBoard()
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("AloneIcon")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
            Spacer().frame(height: 40)
            HorizontalSelector(options: Difficulty.allCases, index: $index)
            Spacer().frame(height: 30)
            
            VStack(spacing: 16) {
                RoundedButton(label: "New Game", color: .white) {
                    navState.navigate {
                        SoloPage(difficulty: difficulty)
                    }
                }
                if let savedGame {
                    RoundedButton(label: "Resume Game", color: .white, outlined: true) {
                        
                    }
                }
            }
        }
        .frame(width: 250)
        .frame(maxHeight: .infinity)
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
    }
}

#Preview {
    DifficultyPage()
}
