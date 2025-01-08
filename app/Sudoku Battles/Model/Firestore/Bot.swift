import Foundation
import FirebaseFirestore

struct Bot: Codable {
    let username: String
    let ranking: Int
    let seconds: Int
}
