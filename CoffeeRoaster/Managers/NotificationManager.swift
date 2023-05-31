//
//  NotificationManager.swift
//  CoffeeRoaster
//
//  Created by Oleksandr Smakhtin on 30.05.2023.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func orderedNotification() {
        
        let content = UNMutableNotificationContent()
        
        content.title = "CoffeeRoaster"
        content.body = "Thank you for your order, it was accepted. Our manager will reach out you soon."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "orderedNotification", content: content, trigger: trigger)
        
        notificationCenter.add(request) { [weak self] error in
            print(error?.localizedDescription)
        }
        
    }
    
}
