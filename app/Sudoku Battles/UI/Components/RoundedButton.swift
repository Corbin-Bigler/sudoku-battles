import SwiftUI

struct RoundedButton: View {
    var icon: Image?
    var label: String
    var color: Color
    var outlined: Bool = false
    var loading: Bool = false
    var action: () -> ()
    
    var foregroundColor: Color {
        if outlined { return color }
        else { return color == .white ? .black : .white }
    }
    
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 25)
        Button(action: {
            if !loading { action() }
        }) {
            HStack(spacing: 6) {
                if loading {
                    LoadingIndicator(size: 26, lineWidth: 4, color: foregroundColor)
                } else {
                    if !outlined {
                        icon?
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    } else {
                        icon?
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                    
                    Text(label)
                        .font(.sora(16, .semibold))

                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
        .background(outlined ? .clear : color)
        .clipShape(shape)
        .foregroundStyle(foregroundColor)
        .overlay {
            shape
                .stroke(lineWidth: 1)
                .foregroundStyle(outlined ? foregroundColor : color)
        }
    }
}

#Preview {
    VStack{
        RoundedButton(icon: Image("CircleArrowIcon"), label: "Preview", color: .blue400, outlined: true) {}
        RoundedButton(icon: Image("GoogleLogo"), label: "Preview", color: .white, outlined: false) {}
        RoundedButton(icon: Image("CircleArrowIcon"), label: "Preview", color: .blue400, outlined: false) {}
        RoundedButton(icon: Image("CircleArrowIcon"), label: "Preview", color: .blue400, outlined: true) {}
        RoundedButton(icon: Image("GoogleLogo"), label: "Preview", color: .white, outlined: false, loading: true) {}
        RoundedButton(icon: Image("CircleArrowIcon"), label: "Preview", color: .red400, outlined: false, loading: true) {}
    }
    .background(.blue900)
}
