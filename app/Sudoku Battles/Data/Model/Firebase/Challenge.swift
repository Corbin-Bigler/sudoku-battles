import Foundation
import FirebaseFirestore

struct Challenge: Codable {
    let inviter: DocumentReference
    let invitee: DocumentReference
    let createdAt: Timestamp
    let inviterScore: Int
    let winner: DocumentReference?
}
