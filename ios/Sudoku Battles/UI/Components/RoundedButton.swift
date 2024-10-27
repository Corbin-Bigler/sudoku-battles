import SwiftUI

struct RoundedButton: View {
    var icon: Image?
    var label: String
    var action: () -> ()
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                icon?
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                
                Text(label)
                    .font(.sora(16, .semibold))

            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1)
        }
        .foregroundStyle(.purple400)
    }
}

#Preview {
    RoundedButton(icon: Image("CircleArrowIcon"), label: "Preview") {}
}
