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

        // With swizzling disabled you must let Messaging know about the message, for Analytics
         Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
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

        // With swizzling disabled you must let Messaging know about the message, for Analytics
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
//        Firebase Push Notifiactionの設定
        
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
      print("Firebase registration token: \(String(describing: fcmToken))")
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        print("uuid: \(uuid)")
        FireStore.shared.insert(colName: "tokens", UUID: uuid, token: fcmToken!)
        FireStore.shared.insert(colName: "tokens", UUID: uuid, update: "Yes")

      let dataDict:[String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification
      // With swizzling disabled you must let Messaging know about the message, for Analytics
       Messaging.messaging().appDidReceiveMessage(userInfo)
      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID1: \(messageID)")
      }

      // Print full message.
      print(userInfo)
    }
    
    var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification
      // With swizzling disabled you must let Messaging know about the message, for Analytics
       Messaging.messaging().appDidReceiveMessage(userInfo)
      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID2: \(messageID)")
      }
        if let value = userInfo["perform-fetch"] as? String {
            if value=="1" {
                // Perform the task on a background queue.
                   DispatchQueue.global().async {
                      // Request the task assertion and save the ID.
                      self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Perform Long Task") {
                         // End the task if time expires.
                        UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
                        self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
                      }
                             
                      // Run task synchronously.
                    let res = SakaiAPI.shared.fetchAssignmentsFromPandA()
                    if res.success {
                        let kadaiList = createKadaiList(rawKadaiList: res.rawKadaiList!, count: 999)
                        Saver.shared.mergeAndSaveKadaiListToStorage(newKadaiList: kadaiList)
                        Saver.shared.saveKadaiFetchedTimeToStorage()
                        WidgetCenter.shared.reloadAllTimelines()
                        
                    }else{
                        print("fetch error")
                    }
                    print("fetched")
                             
                      // End the task assertion.
                    UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
                    self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
                   }
                
            } else {
                print("not fetched")
            }
            UIApplication.shared.applicationIconBadgeNumber = BadgeCount.shared.badgeCount
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
        

      // With swizzling disabled you must set the APNs token here.
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
//        BGTask.shared.scheduleAppRefresh()
//        print("didEnterBackground")
//        UIApplication.shared.applicationIconBadgeNumber = 99
    }
    @objc func willTerminate() {
//        print("willTerminate")
        NotificationCenter.default.removeObserver(self)
    }
}
