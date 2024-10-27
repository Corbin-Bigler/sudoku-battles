import SwiftUI

struct LoadingIndicator: View {
    var size: CGFloat = 50
    var lineWidth: CGFloat = 8
    var color: Color = .purple400

    @State private var isAnimating = false
    private let sweep = 0.67

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: sweep)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            Gradient.Stop(color: color.opacity(0.0), location: 0.0),
                            Gradient.Stop(color: color, location: sweep),
                            Gradient.Stop(color: color, location: sweep + 0.01),
                            Gradient.Stop(color: color.opacity(0.0), location: sweep + 0.1)
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 2.0)
                            .repeatForever(autoreverses: false)
                    ) {
                        isAnimating = true
                    }
                }
        }
    }
}

#Preview {
    LoadingIndicator()
}
