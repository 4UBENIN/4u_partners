import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import GoogleMaps
import flutter_local_notifications
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Configure Firebase
    FirebaseApp.configure()
    
    // Configure Google Maps
    GMSServices.provideAPIKey("AIzaSyAVtrvygnbsdnL6VMEJS_DB0JfEa0piHqM")
    
    // Notifications iOS 10+
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if let error = error {
          print("❌ Erreur permission notifications : \(error)")
        } else {
          print("✅ Permission notifications accordée : \(granted)")
        }
      }
    } else {
      let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    // S'enregistrer pour recevoir les notifications
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Token APNs reçu
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("📱 APNs Token (raw) : \(token)")
    
    // Envoyer le token APNs à Firebase
    Messaging.messaging().apnsToken = deviceToken
    print("✅ APNs Token transmis à Firebase")
  }
  
  // Erreur lors de l’enregistrement APNs
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Erreur enregistrement APNs : \(error.localizedDescription)")
  }
}