import UIKit
import FirebaseStorage

class StorageDs {
    static let shared = StorageDs()
    
    private var storage: Storage
    private var storageReference: StorageReference

    init() {
        storage = Storage.storage()
        if Bundle.main.dev {
            storage.useEmulator(withHost: "\(DevEnvironment.emulatorHost)", port: 9199)
        }
        storageReference = storage.reference()
    }
}
