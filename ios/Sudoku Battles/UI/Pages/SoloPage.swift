import SwiftUI
 
struct SoloPage: View {
    
    @State private var model: SudokuBoardModel
    init(difficulty: Difficulty) {
        let filename = "sudoku-\(difficulty.rawValue.lowercased())"
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("could not find file \(filename)")
            self._model = State(wrappedValue: SudokuBoardModel.empty)
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            let decoder = JSONDecoder()
            let puzzles = try decoder.decode([SudokuData].self, from: data)
            
            let puzzle = puzzles.randomElement()!
            
            
            self._model = State(wrappedValue: SudokuBoardModel(given: puzzle.puzzle, board: puzzle.puzzle)!)
        } catch {
            print("could not decode")
            self._model = State(wrappedValue: SudokuBoardModel.empty)
        }
    }
    
    var body: some View {
        VStack {
            SudokuBoard(model: .constant(SudokuBoardModel.empty))
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    SoloPage(difficulty: .easy)
}
