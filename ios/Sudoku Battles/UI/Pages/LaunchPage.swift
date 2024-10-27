import SwiftUI

struct LaunchPage: View {
    @ObservedObject private var authState = AuthenticationState.shared

    var body: some View {
        VStack {
            Text("Launch Page")
            LoadingIndicator(size: 50)
        }
    }
}

#Preview {
    LaunchPage()
}
