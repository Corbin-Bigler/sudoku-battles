import Foundation
import SwiftUI


struct InputField: View {
    @Binding var text: String
    
    var placeholder: String
        
    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.8)))
            .font(.sora(16, .medium))
            .tint(Color.white)
            .frame(height: 50)
            .padding(.horizontal, 10)
            .background(.white.opacity(0.2))
            .cornerRadius(11)
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(lineWidth: 1)  // Change the border color dynamically
            )
            .foregroundStyle(.white)
    }
}

private struct InputFieldPreview: View {
    @State var picker = ""
    
    var body: some View {
        VStack(spacing: 16) {
            InputField(text: $picker, placeholder: "Value")
        }
        .padding()
        .background(Color.purple400.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    InputFieldPreview()
}
