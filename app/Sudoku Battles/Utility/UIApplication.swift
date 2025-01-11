//
//  UIApplication.swift
//  Sudoku Battles
//
//  Created by Corbin Bigler on 1/8/25.
//

import UIKit

public extension UIApplication {
    func clearLaunchScreenCache() {
        do {
            let launchScreenPath = "\(NSHomeDirectory())/Library/SplashBoard"
            try FileManager.default.removeItem(atPath: launchScreenPath)
        } catch {
            print("Failed to delete launch screen cache - \(error)")
        }
    }
}
