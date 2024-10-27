import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        

        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        AuthenticationState.shared.initialize()
        
        return true
        
    }
}
