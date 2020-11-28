//
//  ComfortablePandAApp.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/10/02.
//

import SwiftUI
import BackgroundTasks
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import WidgetKit


@main
struct ComfortablePandAApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    @AppStorage("badgeCount", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var badgeCount: Int = 0
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppEventHandler.shared.startObserving()
        
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        
        FirebaseApp.configure()
        //        Firestore の初期化
        let db = Firestore.firestore()
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        // [END register_for_notifications]
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // 新しいFCMトークンが生成されたときにFirestoreに保存
        
        print("Firebase registration token: \(String(describing: fcmToken))")
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        print("uuid: \(uuid)")
        FireStore.shared.insert(colName: "tokens", UUID: uuid, token: fcmToken!)
        
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID1: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID2: \(messageID)")
        }
        if let value = userInfo["perform-fetch"] as? String {
            if value=="1" {
                let res = SakaiAPI.shared.fetchAssignmentsFromPandA()
                if res.success {
                    let kadaiList = createKadaiList(rawKadaiList: res.rawKadaiList!, count: 999)
                    Saver.shared.mergeAndSaveKadaiListToStorage(newKadaiList: kadaiList)
                    Saver.shared.saveKadaiFetchedTimeToStorage()
                    WidgetCenter.shared.reloadAllTimelines()
                    UIApplication.shared.applicationIconBadgeNumber = BadgeCount.shared.badgeCount
                }else{
                    print("fetch error")
                }
                print("fetched")
            } else {
                print("not fetched")
            }
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        Messaging.messaging().apnsToken = deviceToken
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
        //        print("didEnterBackground")
    }
    @objc func willTerminate() {
        //        print("willTerminate")
        NotificationCenter.default.removeObserver(self)
    }
}

