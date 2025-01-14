import UIKit
import FirebaseStorage

class StorageDs {
    static let shared = StorageDs()
    
    private var storage: Storage
    private var storageReference: StorageReference

    init() {
        storage = Storage.storage()
        if ProcessInfo.dev {
            storage.useEmulator(withHost: "\(ProcessInfo.firebaseHost)", port: 9199)
        }
        storageReference = storage.reference()
    }
}
