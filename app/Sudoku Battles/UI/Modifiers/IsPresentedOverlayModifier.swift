//
//  IsPresentedOverlayModifier.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/28/24.
//


import SwiftUI

struct IsPresentedOverlayModifier<OverlayContent : View>: ViewModifier {
    var isPresented: Bool
    let overlayContent: () -> OverlayContent
    
    init(isPresented: Bool, overlayContent: @escaping () -> OverlayContent) {
        self.isPresented = isPresented
        self.overlayContent = overlayContent
    }

    private func overlayView() -> some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                overlayContent()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }

    func body(content: Content) -> some View {
        content
            .overlay(overlayView())
    }
}

extension View {
    func overlay<V>(isPresented: Bool, @ViewBuilder content: @escaping () -> V) -> some View where V : View {
        self.modifier(IsPresentedOverlayModifier<V>(isPresented: isPresented, overlayContent: content))
    }
}
