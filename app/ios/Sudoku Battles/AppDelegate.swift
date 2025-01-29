import UIKit
import UserNotifications

import FirebaseCore
import FirebaseMessaging
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        var plistData: [String: Any]
        if Bundle.main.dev {
            let path = Bundle.main.path(forResource: "GoogleService-Info-Development", ofType: "plist")!
            plistData = NSDictionary(contentsOfFile: path) as! [String: Any]
        } else {
            let path = Bundle.main.path(forResource: "GoogleService-Info-Production", ofType: "plist")!
            plistData = NSDictionary(contentsOfFile: path) as! [String: Any]
        }
        
        let options = FirebaseOptions(googleAppID: plistData["GOOGLE_APP_ID"]! as! String, gcmSenderID: plistData["GCM_SENDER_ID"]! as! String)
        options.clientID = plistData["CLIENT_ID"]! as? String
        options.projectID = plistData["PROJECT_ID"]! as? String
        options.apiKey = plistData["API_KEY"]! as? String
        options.storageBucket = plistData["STORAGE_BUCKET"]! as? String
        options.bundleID = plistData["BUNDLE_ID"]! as! String
        options.googleAppID = plistData["GOOGLE_APP_ID"]! as! String
        
        FirebaseApp.configure(options: options)

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        AuthenticationState.shared.initialize()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
    }
    
//    TODO: Implement to handle loading data before user taps on notification
//    func application(_ application: UIApplication,
//                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
//      -> UIBackgroundFetchResult {
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }
//
//      print(userInfo)
//
//      return UIBackgroundFetchResult.newData
//    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
    }


}


extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            logger.info("\("Message ID: \(messageID)")")
        }
        print(userInfo)

        return [[.banner, .sound]]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            logger.info("\("Message ID: \(messageID)")")
        }
        
        if let invitePath = userInfo["invitePath"] as? String {
            let response = try? await FunctionsDs.shared.acceptInvite(invitePath: invitePath)
            guard let response,
                  response.status == .success,
                  let duelPath = response.data?.duelPath
            else { return }

            if AuthenticationState.shared.validating {
                await AuthenticationState.shared.$validating.awaitFalse()
            }
            
            if let user = AuthenticationState.shared.user,
               let userData = AuthenticationState.shared.userData,
               let duelStrategy = try? await PlayerDuelStrategy(FirestoreDs.shared.reference(of: duelPath), friendlyUid: user.uid) {
                
                print(duelStrategy)
                NavigationState.shared.navigate {
                    InvitePage(user: user, userData: userData, duelRepo: DuelRepo(strategy: duelStrategy))
                }
            } else {
                logger.debug("NO USER DATA FOUND")
            }
        }
    }
}

extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        print("fcmToken: \(String(describing: fcmToken))")
        if let fcmToken {
            AuthenticationState.shared.setFcmToken(fcmToken)
            if let user = AuthenticationState.shared.user, let deviceId = UIDevice.current.identifierForVendor {
                Task {
                    try? await FirestoreDs.shared.updateFcmToken(uid: user.uid, fcmToken: fcmToken, deviceId: deviceId)
                }
            }
        }
     }
    
}

private extension Published.Publisher where Output == Bool {
    func awaitFalse() async {
        for await value in self.values {
            if !value {
                return
            }
        }
    }
}
