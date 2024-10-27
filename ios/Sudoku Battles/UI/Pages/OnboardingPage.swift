import SwiftUI
import FirebaseAuth

struct OnboardingPage: View {
    @EnvironmentObject private var authState: AuthenticationState
    @EnvironmentObject private var navState: NavigationState
    
    @State private var username = ""
    @State private var error: String?
    
    let user: AppUser
    
    var body: some View {
        VStack {
            Text("Onboarding Page")
            if let error { Text("Error: \(error)") }
            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
            Button(action: submit) {
                Text("Submit")
            }
        }
    }
    
    func submit() {
        Task {
            do {
                let response = try await FunctionsDs.shared.setUsername(username: username)
                switch response.status {
                case .success:
                    await authState.logIn(user: user)
                    navState.clear()
                case .serverError: Main { error = "Server Error" }
                case .unauthorized: Main { error = "Unauthorized" }
                case .usernameTaken: Main { error = "Username taken" }
                case .invalidRequest: Main { error = "Invalid Request" }
                }
            } catch {
                logger.error("\(error)")
                self.error = error.localizedDescription
            }
        }
    }
}

#Preview {
    OnboardingPage(user: AppUser(uid: "mockAppUserUid"))
}
