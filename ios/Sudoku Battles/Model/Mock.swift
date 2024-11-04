import FirebaseFirestore

struct Mock {
    static let appUser = AppUser(uid: "mockUid")
    static let userData = UserData(username: "mockUsername")
    static let sudokuBoard = SudokuBoardModel(
        given: "530070000600195000098000060800060003400803001700020006060000280000419005000080079",
        board: "530070000600195000098000060800060003400803001700020006060000280000419005000080079"
    )!
    static let duelRepo = DuelRepo(friendlyId: "mockUid", duelId: "mockGameId", firstIsFirendly: true, friendlyBoard: sudokuBoard, enemyBoard: sudokuBoard, enemyData: userData, startTime: Timestamp.init())
}
