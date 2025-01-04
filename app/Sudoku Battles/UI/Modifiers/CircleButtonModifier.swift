//
//  CircleButton.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/26/24.
//

import SwiftUI

private struct CircleButtonModifier: ViewModifier {
    let outline: Color
    let background: Color
    let action: ()->()
    
    func body(content: Content) -> some View {
        Button(action: action) {
            content
                .background(background)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(lineWidth: 1)
                        .foregroundStyle(outline)
                }
        }
    }
}

extension View {
    func circleButton(outline: Color = .gray50, background: Color = .clear, action: @escaping ()->() = {}) -> some View {
        self.modifier(CircleButtonModifier(outline: outline, background: background, action: action))
    }
}

#Preview {
    Text("X")
        .font(.sora(26, .semibold))
        .frame(width: 100, height: 100)
        .circleButton()
}
