import SwiftUI

struct UserSettingsPage: View {
    @State var showImagePicker: Bool = false
    @State var profileImage: UIImage?
    @State var error: String?
    
    let user: AppUser

    var body: some View {
        VStack {
            Text("User Settings Page")
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
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $profileImage)
//                .background(Color.black.offset(y: 100))
        }
    }
}

#Preview {
    UserSettingsPage(user: Mock.appUser)
}
