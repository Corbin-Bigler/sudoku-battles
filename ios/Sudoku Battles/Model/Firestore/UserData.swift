import Foundation

struct UserData: Codable {
    let username: String
    let profilePicture: String?
    
    init(username: String, profilePicture: String? = nil) {
        self.username = username
        self.profilePicture = profilePicture
    }
}
