struct SoloGame: Codable {
    let model: SudokuBoard
    let solution: String
    let seconds: Int
}
