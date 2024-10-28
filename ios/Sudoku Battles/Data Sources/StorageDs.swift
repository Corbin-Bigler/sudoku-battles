import UIKit
import FirebaseStorage

class StorageDs {
    static let shared = StorageDs()
    
    private var storage: Storage
    private var storageReference: StorageReference

    init() {
        storage = Storage.storage()
        if Bundle.main.dev {
            storage.useEmulator(withHost: "localhost", port: 9199)
        }
        storageReference = storage.reference()
    }
    
    func upload(profile: UIImage, uid: String) async throws -> String {
        if profile.size.width > 1, let square = profile.cropToSquare() {
            let data = square.compress(to: 1024)
            
            let imageReference = storageReference.child(uid).child("profile.jpg")
            if let data {
                do {
                    _ = try await imageReference.putDataAsync(data)
                    return "\(uid)/profile.jpg"
                } catch {
                    logger.error("\(error)")
                    throw AppError.firebaseConnectionError
                }
            } else {
                throw AppError.firebaseConnectionError
            }
        } else {
            throw AppError.imageTooSmall
        }
    }
    
    func data(from path: String) async throws -> Data {
        let sizeLimit: Int64 = 10 * 1024 * 1024
        return try await storage.reference(withPath: path).data(maxSize: sizeLimit)
    }
    
    
}
