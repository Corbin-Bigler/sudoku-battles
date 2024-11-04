import Foundation
import FirebaseFirestore

struct DuelData: Codable {
    let firstPlayer: DocumentReference
    let secondPlayer: DocumentReference
    let firstPlayerBoard: String
    let secondPlayerBoard: String
    let given: String
    let startTime: Timestamp
    let sudoku: DocumentReference
    let winner: DocumentReference?
}
