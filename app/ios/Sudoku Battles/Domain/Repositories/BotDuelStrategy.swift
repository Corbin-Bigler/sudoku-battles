//
//  BotDuelStrategy.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/13/25.
//

import Firebase
import Foundation

class BotDuelStrategy: DuelStrategy {
    private let reference: DocumentReference
    private var listener: ListenerRegistration?
    
    var timer: Timer?
    let duel: BotDuel
    var sudoku: DocumentReference { duel.sudoku }
    var startTime: Timestamp { duel.startTime }
    var difficulty: Difficulty { duel.difficulty }
    var enemyName: String { "Bot" }
    var enemyPercentage: Double {
        return min(1, max(0, 1 - ((Double(duel.botEndTime.seconds) - Date().timeIntervalSince1970) / Double(duel.botEndTime.seconds - duel.startTime.seconds))))
    }
    var enemyRanking: Int { duel.botRanking }
    
    private(set) var endTime: Timestamp?
    private(set) var friendlyBoard: SudokuBoard

    required init(_ reference: DocumentReference) async throws {
        guard let duel: BotDuel = try await FirestoreDs.shared.getDocument(reference) else { throw AppError.invalidResponse }
                
        guard let friendlyBoard = SudokuBoard(given: duel.given, board: duel.playerBoard) else { throw AppError.invalidResponse}
                
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
        try await FirestoreDs.shared.updateDocument(reference, fields: ["playerBoard": board.boardString])
    }
    func verifyBoard() async throws -> VerifyDuelBoardStatus {
        return (try await FunctionsDs.shared.verifyDuelBoard(duelPath: reference.path)).status
    }
    func subscribe(onWinner: @escaping ((won: Bool, endTime: Timestamp)) -> (), onEnemyPercentage: @escaping (Double) -> ()) async throws {
        let botEndTime = self.duel.botEndTime
        let endDate = Date(timeIntervalSince1970: Double(botEndTime.seconds))
        Main {
            self.timer = Timer.scheduledTimer(withTimeInterval: endDate.timeIntervalSinceNow, repeats: false) { _ in
                onEnemyPercentage(1)
                onWinner((won: false, endTime: botEndTime))
            }
        }
        
        self.listener = try await FirestoreDs.shared.subscribeToDocument(reference) { (botDuel: BotDuel) in
            if let endTime = botDuel.endTime {
                if endTime.seconds < botDuel.botEndTime.seconds {
                    onEnemyPercentage(self.enemyPercentage)
                    onWinner((won: true, endTime: endTime))
                } else {
                    onEnemyPercentage(self.enemyPercentage)
                    onWinner((won: false, endTime: endTime))
                }
            }
        }
    }
    func unsubscribe() {
        timer?.invalidate()
        timer = nil
        listener?.remove()
        listener = nil
    }
}
