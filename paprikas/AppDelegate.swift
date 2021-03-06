//
//  AppDelegate.swift
//  paprikas
//
//  Created by 박소현 on 2020/12/30.
//

import UIKit
import UserNotifications
import FirebaseMessaging
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let gcmMessageIDKey = "gcm.message_id"

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    FirebaseApp.configure()

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

  // [START receive_message]
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
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
    // Messaging.messaging().apnsToken = deviceToken
  }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
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
    // Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print full message.
    print("====")
    print(userInfo)
//    if let userid = userInfo["userid"] {
//        print(type(of: userid))
//        if userid as! String != "nil" {
//            print("user id ~ : \(userid)")
////            let mainTab = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: CONSTANT_VC.MAIN_TAB_BAR) as? MainTabBarController
////            UIApplication.shared.windows.first?.rootViewController = mainTab
////            UIApplication.shared.windows.first?.makeKeyAndVisible()
////            mainTab?.selectedIndex = 0
////            let feedVC = mainTab?.presentedViewController as! FeedViewController
//
//        }
//    }
    guard let type = userInfo["type"] as? String else { return }
    switch type {
    case "user":
        if let user_id = (userInfo["value"] as? NSString)?.doubleValue {
            let topVC = UIApplication.topViewController()
            let ProfileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: CONSTANT_VC.PROFILE) as! ProfileViewController
            ProfileVC.presenter.setProfileConfig(userId: Int(user_id))
            topVC?.navigationController?.pushViewController(ProfileVC, animated: true)
        }
    case "content":
        if let content_id = (userInfo["value"] as? NSString)?.doubleValue {
            let topVC = UIApplication.topViewController()
            let ContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: CONSTANT_VC.CONTENT_DETAIL) as! ContentDetailViewController
            ContentVC.presenter.setContentConfig(contentId: Int(content_id))
            topVC?.navigationController?.pushViewController(ContentVC, animated: true)
        }
    case "comment":
        if let content_id = (userInfo["value"] as? NSString)?.doubleValue {
            print("contentid : \(content_id)")
            let topVC = UIApplication.topViewController()
            let CommentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: CONSTANT_VC.COMMENT_DETAIL) as! CommentViewController
            CommentVC.presenter.setContentConfig(contentId: Int(content_id), isWrite: false)
            topVC?.navigationController?.pushViewController(CommentVC, animated: true)
        }
    default:
        break
    }
    completionHandler()
  }
}
// [END ios_10_message_handling]

extension AppDelegate: MessagingDelegate {
  // [START refresh_token]
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")

    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    UserDefaults.standard.set(fcmToken, forKey: "devicetoken")
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
  // [END refresh_token]
}
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
