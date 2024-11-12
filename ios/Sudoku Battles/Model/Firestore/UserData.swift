import Foundation
import FirebaseFirestore

struct UserData: Codable {
    let username: String
    let profilePicture: String?
    let usernameChangedAt: Timestamp?
    
    init(username: String, profilePicture: String? = nil) {
        self.username = username
        self.profilePicture = profilePicture
        self.usernameChangedAt = nil
    }
  
    var oneMonthSinceUsernameChange: Bool {
        guard let usernameChangedAt = usernameChangedAt else { return true }
        
        let lastChangedDate = usernameChangedAt.dateValue()
        let currentDate = Date()
        
        let calendar = Calendar.current
        if let differenceInMonths = calendar.dateComponents([.month], from: lastChangedDate, to: currentDate).month {return differenceInMonths >= 1}
        
        return true

    }
}
