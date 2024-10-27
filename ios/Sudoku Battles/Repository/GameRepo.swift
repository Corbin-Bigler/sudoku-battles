//
//  FirebaseRepo.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/25/24.
//
import FirebaseFirestore

class GameRepo: ObservableObject {
    
    let gameId: String
    let firstIsFirendly: Bool
    
    let startTime: Timestamp
    
    @Published private(set) var friendlyBoard: SudokuBoardModel
    @Published private(set) var enemyBoard: SudokuBoardModel
    @Published private(set) var enemyData: UserData
    @Published private(set) var secondsSinceStart: Int
    
    init(gameId: String, firstIsFirendly: Bool, friendlyBoard: SudokuBoardModel, enemyBoard: SudokuBoardModel, enemyData: UserData, startTime: Timestamp) {
        self.gameId = gameId
        self.firstIsFirendly = firstIsFirendly
        self.friendlyBoard = friendlyBoard
        self.enemyBoard = enemyBoard
        self.enemyData = enemyData
        self.startTime = startTime
        self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(self.startTime.seconds)
    }
    init(friendlyId: String, gameId: String) async throws {
        self.gameId = gameId
        guard let game = try await FirestoreDs.shared.getGame(id: gameId) else { throw AppError.invalidResponse }
        
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
                try? await FirestoreDs.shared.updateGameBoard(gameId: gameId, firstPlayer: firstIsFirendly, board: board.boardString)
            }
        }
    }
    
    var gameListener: ListenerRegistration?
//    var timer: Timer?
    func subscribe() async throws {
        gameListener?.remove()
        gameListener = try await FirestoreDs.shared.subscribeToGame(id: gameId) { [weak self] game in
            guard let self else {return}
            logger.trace("\("received subscribed data of \(game)")")
            
            let enemyBoardString = firstIsFirendly ? game.secondPlayerBoard : game.firstPlayerBoard
            if let enemyBoard = SudokuBoardModel(given: game.given, board: enemyBoardString) {
                self.enemyBoard = enemyBoard
            }
        }
//        Main {
//            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] _ in
//                guard let self else { return }
//                self.secondsSinceStart = Int(Date().timeIntervalSince1970) - Int(self.startTime.seconds)
//            }
//        }
    }
    func unsubscribe() {
        gameListener?.remove()
        gameListener = nil
//        timer?.invalidate()
//        timer = nil
    }
    
}
