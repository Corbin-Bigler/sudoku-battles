import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Suppress gRPC logs
//        setenv("GRPC_VERBOSITY", "NONE", 1)
//        setenv("GRPC_TRACE", "", 1)  // Disable specific gRPC traces

        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        AuthenticationState.shared.initialize()
        
        return true
        
    }
}
