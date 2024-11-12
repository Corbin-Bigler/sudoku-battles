struct SoloGame: Codable {
    let model: SudokuBoardModel
    let solution: String
    let seconds: Int
}
