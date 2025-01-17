import Foundation
import SwiftUI


struct InputField: View {
    @Binding var text: String
    
    var placeholder: String
    var color = Color.white
    var error: String?
    var leftIcon: Image?
    
    var fieldColor: Color {
        error == nil ? color : .red400
    }
    var placeholderColor: Color {
        fieldColor.opacity(0.8)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                if let leftIcon {
                    leftIcon
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(placeholderColor)
                }
                TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(placeholderColor))
                    .font(.sora(16, .medium))
                    .tint(fieldColor)
            }
            .padding(.horizontal, 10)
            .frame(height: 50)
            .background(fieldColor.opacity(0.15))
            .cornerRadius(11)
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(lineWidth: 1)
            )
            
            if let error {
                Text(error)
                    .font(.sora(14))
            }
        }
        .foregroundStyle(fieldColor)
    }
}

private struct InputFieldPreview: View {
    @State var picker = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                InputField(text: $picker, placeholder: "Value", leftIcon: Image("search-outline"))
            }
            .padding()
            .background(Color.blue400.edgesIgnoringSafeArea(.all))
            VStack(spacing: 16) {
                InputField(text: $picker, placeholder: "Value", error: "Error message")
            }
            .padding()
        }
    }
}

#Preview {
    InputFieldPreview()
}
