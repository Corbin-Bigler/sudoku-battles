//
//  StaticBackground.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/28/24.
//
import SwiftUI

struct NoiseBackground: View {
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: [.purple400, .purple500]),
                startPoint: .top,
                endPoint: .bottom
            )
            Image("GridNoise")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
            LinearGradient(
                gradient: Gradient(stops: [
                    Gradient.Stop(color: .purple400.opacity(0), location: 0.0),
                    Gradient.Stop(color: .purple400, location: 0.73)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            Image("StaticNoise")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .opacity(0.1)
        }
    }
}

#Preview {
    NoiseBackground()
}


