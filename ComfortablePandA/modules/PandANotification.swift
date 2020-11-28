//
//  Notification.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/10/19.
//

import Foundation
import UIKit
import UserNotifications

struct PandANotification {
    var id: String
    var title: String
    var body: String
}

class LocalNotificationManager {
    var notifications = [PandANotification]()
    
    func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted == true && error == nil {
                    // We have permission!
                }
        }
    }
    
    func addNotification(title: String, body: String) -> Void {
        notifications.append(PandANotification(id: UUID().uuidString, title: title, body: body))
    }
    
    func scheduleNotifications() -> Void {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Scheduling notification with id: \(notification.id)")
            }
        }
    }
}

func setNotification(title: String, body: String) -> Void {
    let manager = LocalNotificationManager()
    manager.requestPermission()
    manager.addNotification(title: title, body: body)
    manager.scheduleNotifications()
}
