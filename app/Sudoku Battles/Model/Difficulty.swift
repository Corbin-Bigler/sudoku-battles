import SwiftUI

enum Difficulty: String, CaseIterable, Codable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    case extreme = "extreme"
    case inhuman = "inhuman"
    
    var title: String {
        rawValue.capitalized
    }
    
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
