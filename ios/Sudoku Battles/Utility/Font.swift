import SwiftUI

extension Font {
    static func sora(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        var name = "Sora-"
        switch weight {
        case .black: name += "ExtraBold"
        case .bold: name += "Bold"
        case .medium: name += "Medium"
        case .regular: name += "Regular"
        case .light: name += "Light"
        case .thin: name += "Thin"
        case .semibold: name += "SemiBold"
        case .ultraLight: name += "ExtraLight"
        default: name += "Medium"
        }
        
        return Font.custom(name, size: size)
    }
}
