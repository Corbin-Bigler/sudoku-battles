import SwiftUI

struct RoundedButton: View {
    var icon: Image?
    var label: String
    var outlined: Bool
    var action: () -> ()

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 11)
        let foregroundColor: Color = outlined ? .purple400 : .black
        let backgroundColor: Color = outlined ? .clear : .white
        let outlineColor: Color = outlined ? .purple400 : .gray50
        Button(action: action) {
            HStack(spacing: 6) {
                if outlined {
                    icon?
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                } else {
                    icon?
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
                
                Text(label)
                    .font(.sora(16, .semibold))

            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
        .background(backgroundColor)
        .clipShape(shape)
        .foregroundStyle(foregroundColor)
        .overlay {
            shape
                .stroke(lineWidth: 1)
                .foregroundStyle(outlineColor)
        }
    }
}

#Preview {
    RoundedButton(icon: Image("CircleArrowIcon"), label: "Preview", outlined: true) {}
    RoundedButton(icon: Image("GoogleLogo"), label: "Preview", outlined: false) {}
}
