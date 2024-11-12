import SwiftUI

enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case extreme = "Extreme"
    case inhuman = "Inhuman"
    
    var color: Color {
        switch self {
        case .easy: return .green400
        case .medium: return .blue400
        case .hard: return .purple400
        case .extreme: return .yellow400
        case .inhuman: return .red400
        }
    }
}
