import FirebaseFirestore

struct Mock {
    static let appUser = AppUser(uid: "mockUid")
    static let userData = UserData(username: "mockUsername", ranking: 1234)
    static let sudokuBoard = SudokuBoardModel(
        given: "060008040004306020001900050000203000000000789605809200000090300000000600276400000",
        board: "060008040004306020001900050000203000000000789605809200000090300000000600276400000"
    )!
    static let correctSudokuBoard = SudokuBoardModel(
        given: "500970000090080720480000000004600050006401900010005800000000047042010030000047002",
        board: "521973486693184725487256319374698251856421973219735864935862147742519638168347592"
    )!
    static let duelRepo = DuelRepo(friendlyId: "mockUid", duelId: "mockGameId", firstIsFirendly: true, friendlyBoard: sudokuBoard, enemyBoard: sudokuBoard, enemyData: userData, startTime: Timestamp.init(), won: nil)
}
