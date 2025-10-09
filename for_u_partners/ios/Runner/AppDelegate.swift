import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configuration Firebase
    FirebaseApp.configure()
    
    // Configuration Google Maps
    // TODO: Replace 'YOUR_GOOGLE_MAPS_IOS_API_KEY' with your actual Google Maps iOS API key
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_IOS_API_KEY")
    
    // Configuration des notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          if granted {
            print("✅ Permissions accordées")
          } else if let error = error {
            print("❌ Erreur permissions: \(error)")
          }
        }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    application.registerForRemoteNotifications()
    
    // Définir le delegate FCM
    Messaging.messaging().delegate = self
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Gestion du token APNS
  override func application(_ application: UIApplication, 
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("📱 Token APNS reçu")
    Messaging.messaging().apnsToken = deviceToken
  }
  
  override func application(_ application: UIApplication, 
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Échec enregistrement APNS: \(error)")
  }
  
  // Gestion des notifications en premier plan
  override func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                       willPresent notification: UNNotification, 
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    print("📬 Notification en premier plan: \(userInfo)")
    
    // Afficher la notification même en premier plan
    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .badge, .sound]])
    } else {
      completionHandler([[.alert, .badge, .sound]])
    }
  }
  
  // Gestion du tap sur notification
  override func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                       didReceive response: UNNotificationResponse, 
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    print("👆 Notification tappée: \(userInfo)")
    
    completionHandler()
  }
}

// Extension pour gérer les tokens FCM
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔑 Token FCM reçu: \(fcmToken ?? "nil")")
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"), 
      object: nil, 
      userInfo: dataDict
    )
  }
}