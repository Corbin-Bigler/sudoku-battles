import SwiftUI

struct UserSettingsPage: View {
    @EnvironmentObject var authState: AuthenticationState
    @EnvironmentObject var navState: NavigationState

    @State var showImagePicker: Bool = false
    @State var profileImage: UIImage?
    @State var error: String?
    
    let user: AppUser
    let userData: UserData

    var body: some View {
        VStack {
            Text("User Settings Page")
            Text("UID: \(user.uid)")
            Text("Username: \(userData.username)")

            if let error { Text("Error: \(error)") }
            
            if let profileImage {
                Button(action: {
                    Task {
                        do {
                            let path = try await StorageDs.shared.upload(profile: profileImage, uid: user.uid)
                            try await FirestoreDs.shared.setUserDataProfile(path: path, uid: user.uid)
                        } catch {
                            Main {
                                self.error = "Could not upload image"
                                self.profileImage = nil
                            }
                        }
                    }
                }) {
                    Text("Upload Image")
                }
            } else {
                Button(action: {showImagePicker = true}) {
                    Text("Select Image")
                }
            }
            Button(action: {
                authState.logOut()
                navState.clear()
            }) {
                Text("Sign Out")
            }
            Button(action: {
                Task {
                    do {
                        let response = try await FunctionsDs.shared.deleteAccount()
                        print(response)
                        authState.logOut()
                        navState.clear()
                    } catch {
                        
                    }
                }
            }) {
                Text("Delete Account")
            }
            
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $profileImage)
//                .background(Color.black.offset(y: 100))
        }
    }
}

#Preview {
    UserSettingsPage(user: Mock.appUser, userData: Mock.userData)
}
