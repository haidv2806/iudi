//
//  UserDefault.swift
//  IUDI
//
//  Created by LinhMAC on 23/02/2024.
//


import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case hasOnboarded
        case didLogin
        case didOnMain
        case hasLogout
        case willUploadImage
    }
    var hasOnboarded : Bool {
        get {
            bool(forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
        set {
            setValue(newValue, forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
    }
    var didOnMain: Bool {
        get {
            bool(forKey: UserDefaultsKeys.didOnMain.rawValue)
        }
        set {
            setValue(newValue, forKey: UserDefaultsKeys.didOnMain.rawValue)
        }
    }
    var didLogin: Bool {
        get {
            bool(forKey: UserDefaultsKeys.didLogin.rawValue)
        }
        set {
            setValue(newValue, forKey: UserDefaultsKeys.didLogin.rawValue)
        }
    }
    var willUploadImage: Bool {
        get {
            bool(forKey: UserDefaultsKeys.willUploadImage.rawValue)
        }
        set {
            setValue(newValue, forKey: UserDefaultsKeys.willUploadImage.rawValue)
        }
    }
    
    private enum ThemeKey: String {
            case selectedTheme
        }
        var selectedTheme: Theme? {
            get {
                if let rawValue = string(forKey: ThemeKey.selectedTheme.rawValue) {
                    return Theme(rawValue: rawValue)
                }
                return nil
            }
            set {
                set(newValue?.rawValue, forKey: ThemeKey.selectedTheme.rawValue)
            }
        }
}


