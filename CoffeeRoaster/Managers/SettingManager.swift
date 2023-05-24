//
//  SettingManager.swift
//  CoffeeRoaster
//
//  Created by Алина Власенко on 21.05.2023.
//

import Foundation
import UIKit

final class SettingManager {
    
    static let shared = SettingManager()
    
    private init() {}
    
    public func checkTheme() {
        if UserDefaults.standard.bool(forKey: "flag") == true {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .dark
            print("dark")
            
        } else {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .light
            print("white")
        } 
    }
}
