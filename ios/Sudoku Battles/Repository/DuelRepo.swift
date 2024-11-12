//
//  FirebaseRepo.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/25/24.
//
import FirebaseFirestore

class DuelRepo: ObservableObject {
    
    let friendlyId: String
    let duelId: String
    let firstIsFirendly: Bool
    
    private var timer: Timer?
    let startTime: Timestamp
    
    @Published private(set) var won: Bool?
    @Published private(set) var friendlyBoard: SudokuBoardModel
    @Published private(set) var enemyBoard: SudokuBoardModel
    @Published private(set) var enemyData: UserData
    @Published private(set) var secondsSinceStart: Int
    

    init(friendlyId: String, duelId: String, firstIsFirendly: Bool, friendlyBoard: SudokuBoardModel, enemyBoard: SudokuBoardModel, enemyData: UserData, startTime: Timestamp) {
        self.friendlyId = friendlyId
        self.duelId = duelId
        self.firstIsFirendly = firstIsFirendly
        self.friendlyBoard = friendlyBoard
        self.enemyBoard = enemyBoard
        self.enemyData = enemyData
        self.startTime = startTime
        self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(self.startTime.seconds)
    }
    init(friendlyId: String, duelId: String) async throws {
        self.friendlyId = friendlyId
        self.duelId = duelId
        guard let game = try await FirestoreDs.shared.getDuel(id: duelId) else { throw AppError.invalidResponse }
        
        if friendlyId == game.firstPlayer.documentID { firstIsFirendly = true }
        else if (friendlyId == game.secondPlayer.documentID) { firstIsFirendly = false }
        else { throw AppError.invalidResponse }
        
        let enemyUid = firstIsFirendly ? game.secondPlayer.documentID : game.firstPlayer.documentID
        guard let enemyData = try await FirestoreDs.shared.getUserData(uid: enemyUid) else { throw AppError.invalidResponse }
        self.enemyData = enemyData
        
        let enemyBoardString = firstIsFirendly ? game.secondPlayerBoard : game.firstPlayerBoard
        guard let enemyBoard = SudokuBoardModel(given: game.given, board: enemyBoardString) else { throw AppError.invalidResponse}
        self.enemyBoard = enemyBoard
        
        let friendlyBoardString = firstIsFirendly ? game.firstPlayerBoard : game.secondPlayerBoard
        guard let friendlyBoard = SudokuBoardModel(given: game.given, board: friendlyBoardString) else { throw AppError.invalidResponse}
        self.friendlyBoard = friendlyBoard
        
        self.startTime = game.startTime
        self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(self.startTime.seconds)
    }
    
    func updateFriendlyBoard(board: SudokuBoardModel) {
        let oldBoardString = friendlyBoard.boardString
        friendlyBoard = board
        let newBoardString = board.boardString
        
        if oldBoardString != newBoardString {
            Task {
                try? await FirestoreDs.shared.updateGameBoard(duelId: duelId, firstPlayer: firstIsFirendly, board: board.boardString)
                if(friendlyBoard.percentageComplete == 1.0) {
                    let _ = try? await FunctionsDs.shared.verifyDuelBoard(duelId: duelId)
                }
            }
        }
    }
    
    var gameListener: ListenerRegistration?
    func subscribe() async throws {
        
        Main {
            self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(self.startTime.seconds)
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(self.startTime.seconds)
            }
        }
        gameListener?.remove()
        gameListener = try await FirestoreDs.shared.subscribeToDuel(id: duelId) { [weak self] game in
            guard let self else {return}
            logger.trace("\("received subscribed data of \(game)")")
            
            let enemyBoardString = firstIsFirendly ? game.secondPlayerBoard : game.firstPlayerBoard
            if let enemyBoard = SudokuBoardModel(given: game.given, board: enemyBoardString) {
                Main { self.enemyBoard = enemyBoard }
            }
            
            if let winner = game.winner {
                won = winner.documentID == friendlyId
            }
        }
    }
    func unsubscribe() {
        print("unsubscribe")
        gameListener?.remove()
        gameListener = nil
        timer?.invalidate()
        timer = nil
    }
    
}
