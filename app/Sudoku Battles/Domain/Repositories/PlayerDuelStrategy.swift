//
//  PlayerDuelStrategy.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/14/25.
//

import Firebase
import Foundation

class PlayerDuelStrategy: DuelStrategy {
    private let reference: DocumentReference
    private var listener: ListenerRegistration?
    private var firstIsFirendly: Bool
    private var friendlyUid: String

    let duel: PlayerDuel
    let enemyData: UserData
    var sudoku: DocumentReference { duel.sudoku }
    var startTime: Timestamp { duel.startTime }
    var difficulty: Difficulty { duel.difficulty }
    var enemyName: String { enemyData.username }
    var enemyPercentage: Double
    var enemyRanking: Int { enemyData.ranking }
    
    private(set) var endTime: Timestamp?
    private(set) var friendlyBoard: SudokuBoard

    required init(_ reference: DocumentReference, friendlyUid: String) async throws {
        guard let duel: PlayerDuel = try await FirestoreDs.shared.getDocument(reference) else { throw AppError.invalidResponse }
        
        if friendlyUid == duel.firstPlayer.documentID { firstIsFirendly = true }
        else if (friendlyUid == duel.secondPlayer.documentID) { firstIsFirendly = false }
        else { throw AppError.invalidResponse }

        guard let enemyData: UserData = try await FirestoreDs.shared.getDocument(firstIsFirendly ? duel.secondPlayer : duel.firstPlayer) else { throw AppError.invalidResponse }
        guard let friendlyBoard = SudokuBoard(given: duel.given, board: firstIsFirendly ? duel.firstPlayerBoard : duel.secondPlayerBoard) else { throw AppError.invalidResponse}
        
        guard let enemyBoard = SudokuBoard(given: duel.given, board: firstIsFirendly ? duel.secondPlayerBoard : duel.firstPlayerBoard) else { throw AppError.invalidResponse}
        
        self.friendlyUid = friendlyUid
        self.enemyData = enemyData
        self.enemyPercentage = enemyBoard.percentageComplete
        self.reference = reference
        self.friendlyBoard = friendlyBoard
        self.duel = duel
    }
    
    func getSolution() async throws -> String {
        let sudoku: Sudoku? = try await FirestoreDs.shared.getDocument(self.sudoku)
        guard let sudoku else { throw AppError.invalidResponse }
        return sudoku.solution
    }
    func updateBoard(_ board: SudokuBoard) async throws {
        let field = firstIsFirendly ? "firstPlayerBoard" : "secondPlayerBoard"
        try await FirestoreDs.shared.updateDocument(reference, fields: [field: board.boardString])
    }
    func verifyBoard() async throws -> VerifyDuelBoardStatus {
        return (try await FunctionsDs.shared.verifyDuelBoard(duelPath: reference.path)).status
    }
    func subscribe(onWinner: @escaping ((won: Bool, endTime: Timestamp)) -> (), onEnemyPercentage: @escaping (Double) -> ()) async throws {
        self.listener = try await FirestoreDs.shared.subscribeToDocument(reference) { [weak self] (playerDuel: PlayerDuel) in
            guard let self else {return}
            logger.trace("\("received subscribed data of \(playerDuel)")")

            let enemyBoardString = firstIsFirendly ? playerDuel.secondPlayerBoard : playerDuel.firstPlayerBoard
            if let enemyBoard = SudokuBoard(given: playerDuel.given, board: enemyBoardString) {
                onEnemyPercentage(enemyBoard.percentageComplete)
            }

            if let winner = playerDuel.winner {
                onWinner((won: winner.documentID == self.friendlyUid, endTime: playerDuel.endTime!))
            }
        }
    }
    func unsubscribe() {
        listener?.remove()
        listener = nil
    }
}
