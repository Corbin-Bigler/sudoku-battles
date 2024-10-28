import UIKit
import FirebaseStorage

class StorageDs {
    static let shared = StorageDs()
    
    private var storage: Storage
    private var images: StorageReference

    init() {
        storage = Storage.storage()
        images = storage.reference().child("images")
    }
    
    func upload(profile: UIImage, uid: String) async throws -> String {
        if profile.size.width > 1 {
            let data = profile.compress(to: 1024)
            
            let imageReference = images.child(uid).child("profile.jpg")
            if let data {
                _ = try await imageReference.putDataAsync(data)
                return "\(uid)/profile.jpg"
            } else {
                throw AppError.firebaseConnectionError
            }
        } else {
            throw AppError.imageTooSmall
        }
    }
}
