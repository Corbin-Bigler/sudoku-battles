//
//  LinearProgress.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 11/11/24.
//

import SwiftUI

struct LinearProgress: View {
    let progress: CGFloat
    let color: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: .infinity)
                .fill(.gray100)
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(color)
                    .frame(width: progress * geometry.size.width)
            }
        }
        .frame(height: 10)
    }
}

#Preview {
    LinearProgress(progress: 0.5, color: .green400)
}