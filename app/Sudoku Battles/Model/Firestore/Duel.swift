import Foundation
import FirebaseFirestore

struct Duel: Codable {
    let firstPlayer: DocumentReference
    let secondPlayer: DocumentReference
    let firstPlayerBoard: String
    let secondPlayerBoard: String
    let given: String
    let startTime: Timestamp
    let endTime: Timestamp?
    let difficulty: Difficulty
    let sudoku: DocumentReference
    let winner: DocumentReference?
    
    var enemyIsBot: Bool { secondPlayer.parent.collectionID == "bots" }
}
