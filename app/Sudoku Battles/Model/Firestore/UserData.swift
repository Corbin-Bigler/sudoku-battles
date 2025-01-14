import Foundation
import FirebaseFirestore

struct UserData: Codable {
    let username: String
    let usernameChangedAt: Timestamp?
    let ranking: Int
    
    init(username: String, ranking: Int) {
        self.username = username
        self.usernameChangedAt = nil
        self.ranking = ranking
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
