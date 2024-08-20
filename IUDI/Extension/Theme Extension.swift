//
//  Theme Extension.swift
//  IUDI
//
//  Created by LinhMAC on 23/02/2024.
//

import Foundation
import UIKit

//
enum Theme: String {
   case light, dark, system

   var uiInterfaceStyle: UIUserInterfaceStyle {
       switch self {
       case .light:
           return .light
       case .dark:
           return .dark
       case .system:
           return .unspecified
       }
   }
}
class ThemeManager {
    static let shared = ThemeManager()
    var currentTheme: Theme = .system
    
    private init() {}
    
    func applyTheme(_ theme: Theme, to window: UIWindow?) {
        currentTheme = theme
        switch theme {
        case .light:
            window?.overrideUserInterfaceStyle = .light
            // Customize other light theme colors if needed
        case .dark:
            window?.overrideUserInterfaceStyle = .dark
            // Customize dark theme colors
        case .system:
            window?.overrideUserInterfaceStyle = .unspecified
            // Customize other system theme colors if needed
        }
        // Save the theme to UserDefaults
        UserDefaults.standard.selectedTheme = theme
    }
}
