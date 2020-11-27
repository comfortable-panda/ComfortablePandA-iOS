//
//  ComfortablePandAApp.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/10/02.
//

import SwiftUI
import BackgroundTasks
import Firebase
import FirebaseMessaging
import UserNotifications

@main
struct ComfortablePandAApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    @AppStorage("badgeCount", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var badgeCount: Int = 0
    
    var notificationGranted = true
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
            -> Void) {
        completionHandler([[.banner, .list, .sound]])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppEventHandler.shared.startObserving()
        
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        
//        Firebase Push Notifiactionの設定
        FirebaseApp.configure()
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound])
        {
            (granted, error) in
            self.notificationGranted = granted
            if let error = error {
                print("granted, but Error in notification permission:\(error.localizedDescription)")
            }}
        
        return true
    }
    
}

class PrintOperation: Operation {
    let id: Int

    init(id: Int) {
        self.id = id
    }

    override func main() {
        print("this operation id is \(self.id)")
//        setNotification(title: "📗定期実行2", body: "\(dispDate(date: Date()))")
    }
}



class AppEventHandler: NSObject {
    static let shared = AppEventHandler()
    
    override private init() {
        super.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startObserving(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishLaunch), name: UIApplication.didFinishLaunchingNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc func didFinishLaunch() {
//        print("didFinishLaunch")
    }
    @objc func willEnterForeground() {
//        print("willEnterForeground")
    }
    @objc func didEnterBackground() {
//        BGTask.shared.scheduleAppRefresh()
//        print("didEnterBackground")
//        UIApplication.shared.applicationIconBadgeNumber = 99
    }
    @objc func willTerminate() {
//        print("willTerminate")
        NotificationCenter.default.removeObserver(self)
    }
}
