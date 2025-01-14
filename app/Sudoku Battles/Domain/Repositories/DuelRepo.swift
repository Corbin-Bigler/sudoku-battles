import Firebase

class DuelRepo: ObservableObject {
    let strategy: DuelStrategy
    
    @Published private(set) var won: Bool?
    @Published private(set) var endTime: Timestamp?
    @Published private(set) var friendlyBoard: SudokuBoard
    @Published private(set) var enemyPercentage: Double?

    var difficulty: Difficulty { strategy.difficulty }
    var startTime: Timestamp { strategy.startTime }
    var enemyName: String { strategy.enemyName }
    var enemyRanking: Int { strategy.enemyRanking }

    init(strategy: DuelStrategy) {
        self._endTime = Published(wrappedValue: strategy.endTime)
        self._friendlyBoard = Published(wrappedValue: strategy.friendlyBoard)
        self.strategy = strategy
    }
    
    func updateBoard(_ board: SudokuBoard) {
        let oldBoardString = friendlyBoard.boardString
        friendlyBoard = board
        let newBoardString = board.boardString
        
        if oldBoardString != newBoardString {
            Task {
                try? await strategy.updateBoard(board)
                if(friendlyBoard.correct) {
                    let _ = try? await strategy.verifyBoard()
                }
            }
        }
    }
    func subscribe() async throws {
        try await strategy.subscribe(
            onWinner: { won, endTime in
                Main {
                    self.won = won
                    self.endTime = endTime
                }
            },
            onEnemyPercentage: { enemyPercentage in
                Main { self.enemyPercentage = enemyPercentage }
            }
        )
    }
    func unsubscribe() {
        strategy.unsubscribe()
    }
}
