//
//  CirclularProgress.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/26/24.
//

import SwiftUI

struct CircluarProgress: View {
    var progress: CGFloat
    var color: Color
    var size: CGFloat = 60
    var lineWidth: CGFloat = 5
    
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                )
            )
            .scale(x: -1)
            .rotationEffect(.degrees(270))
            .foregroundStyle(color)
            .frame(width: size, height: size)
    }
}

#Preview {
    CircluarProgress(progress: 0.6, color: .blue400)
}
