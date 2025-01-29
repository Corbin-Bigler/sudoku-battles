//
//  PushNotificationsUtility.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 10/27/24.
//

import UIKit

struct PushNotificationsUtility {
    private init() {}

    static func requestPermissions() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                        continuation.resume(returning: granted)
                    }
                }
            )
        }
    }
}
