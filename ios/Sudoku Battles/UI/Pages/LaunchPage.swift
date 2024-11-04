import SwiftUI

struct LaunchPage: View {
    @ObservedObject private var authState = AuthenticationState.shared

    var body: some View {
        StoryboardView()
            .ignoresSafeArea()
    }
}

private struct StoryboardView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "Main")
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


#Preview {
    LaunchPage()
}
