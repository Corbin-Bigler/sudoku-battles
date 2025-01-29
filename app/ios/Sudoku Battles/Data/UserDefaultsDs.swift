import SwiftUI

class UserDefaultsDs {
    static let shared = UserDefaultsDs()
    
    let userDefaults = UserDefaults.standard
    let savedGameKey = "solo_game_key"
    let darkModeKey = "dark_mode_key"
    let recentInvitesKey = "recent_invites_key"

    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    func save(game: SoloGame, difficulty: Difficulty) {
        let encoded = try? jsonEncoder.encode(game)
        userDefaults.set(encoded, forKey: savedGameKey + "_\(difficulty.title)")
    }
    func deleteGame(difficulty: Difficulty) {
        userDefaults.removeObject(forKey: savedGameKey + "_\(difficulty.title)")
    }
    func getGame(difficulty: Difficulty) -> SoloGame? {
        if let boardModel = userDefaults.data(forKey: savedGameKey + "_\(difficulty.title)") {
            return try? jsonDecoder.decode(SoloGame.self, from: boardModel)
        }
        return nil
    }
    
    func save(darkMode: Bool) {
        userDefaults.set(String(darkMode), forKey: darkModeKey)
    }
    func getDarkMode() -> Bool? {
        return userDefaults.string(forKey: darkModeKey).flatMap { Bool($0) }
    }
    func deleteDarkMode() {
        userDefaults.removeObject(forKey: recentInvitesKey)
    }
    
    func addRecentInvite(uid: String) {
        var currentList = UserDefaults.standard.stringArray(forKey: recentInvitesKey) ?? []
        currentList.append(uid)
        if currentList.count > 5 {
            currentList.removeFirst()
        }
        UserDefaults.standard.set(currentList, forKey: recentInvitesKey)
    }
    func getRecentInvites() -> [String] {
        return UserDefaults.standard.stringArray(forKey: recentInvitesKey) ?? []
    }
}
