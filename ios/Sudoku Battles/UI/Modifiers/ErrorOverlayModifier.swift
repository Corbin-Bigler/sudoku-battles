//
//  ErrorOverlayModel.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/28/24.
//


//import SwiftUI
//
//struct ErrorOverlayModel {
//    var title: String
//    var body: String
//}
//
//struct ErrorOverlayModifier: ViewModifier {
//    @Binding var errorModel: ErrorOverlayModel?
//
//    private func overlayView(errorModel: ErrorOverlayModel) -> some View {
//        ZStack {
//            Color.black.opacity(0.6)
//                .ignoresSafeArea()
//            
//            VStack(spacing: 16) {
//                Text(errorModel.title)
//                    .font(.sora(20, .semibold))
//                    .foregroundStyle(Color.black)
//                
//                Text(errorModel.body)
//                    .font(.sora(16))
//                    .foregroundStyle(Color.black)
//                    .multilineTextAlignment(.center)
//                
//                RoundedButton(label: "OK", style: .outlined) {
//                    self.errorModel = nil
//                }
//                .frame(maxWidth: 100)
//            }
//            .padding(16)
//            .frame(minWidth: 250)
//            .background(Color.white)
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color.gray50, lineWidth: 1)
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//        }
//    
//    }
//
//    func body(content: Content) -> some View {
//        content
//            .overlay(
//                errorModel != nil ? overlayView(errorModel: errorModel!) : nil
//            )
//    }
//}
//
//extension View {
//    func errorOverlay(_ errorModel: Binding<ErrorOverlayModel?>) -> some View {
//        self.modifier(ErrorOverlayModifier(errorModel: errorModel))
//    }
//}
