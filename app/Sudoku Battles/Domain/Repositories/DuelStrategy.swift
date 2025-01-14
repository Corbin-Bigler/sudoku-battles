import Firebase

protocol DuelStrategy {
    var startTime: Timestamp { get }
    var endTime: Timestamp? { get }

    var difficulty: Difficulty { get }
    var friendlyBoard: SudokuBoard { get }
    var enemyName: String { get }
    var enemyRanking: Int { get }
    var enemyPercentage: Double { get }
    
    func getSolution() async throws -> String
    func updateBoard(_ board: SudokuBoard) async throws
    func verifyBoard() async throws -> VerifyDuelBoardStatus
    func subscribe(onWinner: @escaping ((won: Bool, endTime: Timestamp))->(), onEnemyPercentage: @escaping (Double)->()) async throws
    func unsubscribe()
}
