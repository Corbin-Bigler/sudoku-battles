import Foundation
import FirebaseFirestore

struct GameData: Codable {
    let firstPlayer: DocumentReference
    let secondPlayer: DocumentReference
    let firstPlayerBoard: String
    let secondPlayerBoard: String
    let given: String
    let startTime: Timestamp
}
