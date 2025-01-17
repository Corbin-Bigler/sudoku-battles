//
//  Pill.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/14/25.
//

import SwiftUI

struct Pill: View {
    let text: String
    let fontSize: CGFloat
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.sora(fontSize, .semibold))
            .padding(.horizontal, fontSize / 2)
            .padding(.vertical, fontSize / 6)
            .background(color)
            .cornerRadius(.infinity)
            .foregroundStyle(.white)
    }
}

#Preview {
    Pill(text: "1234", fontSize: 14, color: .blue400)
    Pill(text: "1234", fontSize: 34, color: .blue400)
    Pill(text: "Easy", fontSize: 20, color: .green400)
}
