//
//  AppDelegate.swift
//  ValetParking
//
//  Created by Khushal on 12/10/18.
//  Copyright © 2018 fugenx. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import Firebase
import UserNotifications
import GoogleMobileAds
import GoogleSignIn
import FBSDKCoreKit
import AuthenticationServices
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PopUpViewDelegate,NotificationViewDelegate, CLLocationManagerDelegate {
  
    var window: UIWindow?
    var nVc = UINavigationController()
    var mPopUp : PopUpView!
    var mNotify : NotificationView!
    var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Constants.kMainViewController?.isLeftViewDisabled = true
        IQKeyboardManager.shared.enable = true
        window = UIWindow(frame: UIScreen.main.bounds)
    
        GMSServices.provideAPIKey("AIzaSyDNuJFHTBoAJeSsDdJhyuQrpkDo5_bl6As")
        GMSPlacesClient.provideAPIKey("AIzaSyDNuJFHTBoAJeSsDdJhyuQrpkDo5_bl6As")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        //Facebook Login
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions:
            launchOptions
        )
        //Google Login
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
              // Show the app's signed-out state.
            } else {
              // Show the app's signed-in state.
            }
          }
        
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
        firebasepushNotification()
        startLocation()
        launchScreen()
//        let isLoggedin =  UserDefaults.standard.string(forKey: "isLoggedin")
//        if Connectivity.isConnectedToInternet {
//            print("Connected AppDelegate")
//            if(isLoggedin == "1") {
//               moveToHome()
//            } else {
//               moveToLogin()
//            }
//        } else{
//            print("No internet connection AppDelegate")
//            moveToConnectionCheck()
//        }
        return true
    }
    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      var handled: Bool
//      GoogleSignIn
      handled = GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }

      // Handle other custom URL types.
      // If not handled by this app, return false.
//        FacebookSignIn
        ApplicationDelegate.shared.application(
                    app,
                    open: url,
                    sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                    annotation: options[UIApplication.OpenURLOptionsKey.annotation]
                )
      return false
    }
    
//    var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    func startLocation()  {
         locationManager = CLLocationManager()
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestWhenInUseAuthorization()
         locationManager.showsBackgroundLocationIndicator = false
         locationManager.allowsBackgroundLocationUpdates = true
         locationManager.delegate = self
         locationManager.startUpdatingLocation()
    }
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        UserDefaults.standard.setValue(String(locations[0].coordinate.latitude) , forKey: "CurrentLat")
        UserDefaults.standard.setValue(String(locations[0].coordinate.longitude) , forKey: "CurrentLong")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError0000 ------ \(error.localizedDescription)")
    }
    
    func firebasepushNotification() {
        Messaging.messaging().isAutoInitEnabled = true

        let fcmToken = Messaging.messaging().fcmToken
        UserDefaults.standard.setValue(fcmToken, forKey: "deviceToken")
        print("FCM token: \(fcmToken ?? "")")
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo["aps"] {
            print("Message ID: \(messageID)")
        }
        print("Remote Notification data -- \(userInfo)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        print("Remote Notification data -- \(userInfo)")

        // Print message ID.
        if let messageID = userInfo["aps"] as? [AnyHashable : Any]{
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        let state = UIApplication.shared.applicationState
        
        //        if state == .background {
        //            print("BACKGROUND STATE")
        //            self.moveToNotificationVC()
        //        }
        //        else if state == .active {
        //            print("ACTIVE STATE")
        //        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    func launchScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.nVc = (storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController)!
        nVc.viewControllers = [storyboard.instantiateViewController(withIdentifier: "LauchScreenVC")]
        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
        mainViewController?.rootViewController = nVc
        mainViewController?.setup(type: 1)
        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
        window?.rootViewController = mainViewController
        if window != nil {
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    func moveToLogin()
    {
        UserDefaults.standard.setValue("home", forKey: "SelectedTab")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.nVc = (storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController)!
        nVc.viewControllers = [storyboard.instantiateViewController(withIdentifier: "LoginVC")]
        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
        mainViewController?.rootViewController = nVc
        mainViewController?.setup(type: 1)
        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
        window?.rootViewController = mainViewController
        if window != nil {
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    func moveToConnectionCheck(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.nVc = (storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController)!
        nVc.viewControllers = [storyboard.instantiateViewController(withIdentifier: "ConnectionCheckVC")]
        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
        mainViewController?.rootViewController = nVc
        mainViewController?.setup(type: 1)
        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
        window?.rootViewController = mainViewController
        if window != nil {
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
//  MARK: - POPUPDELEGATE --
    func removePopUp(dict : Dictionary<AnyHashable, Any>){
        if self.mPopUp != nil {
            self.mPopUp.removeFromSuperview()
             UserDefaults.standard.setValue((dict["type"] as Any), forKey: "type")
            UserDefaults.standard.setValue((dict["ticket_id"] as Any), forKey: "ticketNo")
        }
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let nVc = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
//
//        nVc?.viewControllers = [storyboard.instantiateViewController(withIdentifier: "ParkedCarVC")]
//
//        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
//        mainViewController?.rootViewController = nVc
//        mainViewController?.setup(type: 1)
//        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
//        window?.rootViewController = mainViewController
//        if window != nil {
//            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
//        }
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ParkedCarVC") as! ParkedCarVC
//        self.nVc.pushViewController(nextViewController, animated: false)
    }
    
    //Notification
    func removenotification(dict : Dictionary<AnyHashable, Any>){
        self.mNotify.removeFromSuperview()
        UserDefaults.standard.setValue((dict["type"] as Any), forKey: "type")
        UserDefaults.standard.setValue((dict["ticket_id"] as Any), forKey: "ticketNo")
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ParkedCarVC") as! ParkedCarVC
//        self.nVc.pushViewController(nextViewController, animated: false)
    }
    
    func moveToVC(_ viewController: UIViewController) {
        //mPopUp.removeFromSuperview()
       //self.navigationController.pushViewController(viewController, animated: true)
    }
    func moveToHome()
    {
        // Override point for customization after application launch.
        //UIApplication.shared.statusBarView?.backgroundColor = UIColor(red:0.68, green:0.14, blue:0.23, alpha:1.0)
        UserDefaults.standard.setValue("home", forKey: "SelectedTab")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.nVc = (storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController)!
        nVc.viewControllers = [storyboard.instantiateViewController(withIdentifier: "HomeVC")]
        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
        mainViewController?.rootViewController = nVc
        mainViewController?.setup(type: 1)
        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
        window?.rootViewController = mainViewController
        if window != nil {
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    func homeButtonClicked() {
        //UserDefaults.standard.setValue("home", forKey: "SelectedTab")
//        for controller: UIViewController in (nVc.viewControllers) {
//            if (controller is HomeVC) {
//                nVc.popToViewController(controller, animated: false)
//                break
//            }
//        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.nVc.pushViewController(nextViewController, animated: false)

//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
//        navigationController?.viewControllers = [storyboard.instantiateViewController(withIdentifier: "HomeVC")]
//        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
//        mainViewController?.rootViewController = navigationController
//        mainViewController?.setup(type: 1)
//        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
//        window?.rootViewController = mainViewController
//        if window != nil {
//            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
//        }
    }
    
    func ticketsButtonClicked() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TicketsVC") as! TicketsVC
        self.nVc.pushViewController(nextViewController, animated: false)
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
//        navigationController?.viewControllers = [storyboard.instantiateViewController(withIdentifier: "TicketsVC")]
//        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
//        mainViewController?.rootViewController = navigationController
//        mainViewController?.setup(type: 1)
//        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
//        window?.rootViewController = mainViewController
//        if window != nil {
//            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
//        }
    }

    func myCarsButtonClicked() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MyCarsVC") as! MyCarsVC
        self.nVc.pushViewController(nextViewController, animated: false)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
//        navigationController?.viewControllers = [storyboard.instantiateViewController(withIdentifier: "MyCarsVC")]
//        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
//        mainViewController?.rootViewController = navigationController
//        mainViewController?.setup(type: 1)
//        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
//        window?.rootViewController = mainViewController
//        if window != nil {
//            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
//        }
    }
    func profileButtonClicked() {
        if #available(iOS 13.0, *) {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            self.nVc.pushViewController(nextViewController, animated: false)
        }else{}
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
//        navigationController?.viewControllers = [storyboard.instantiateViewController(withIdentifier: "ProfileVC")]
//        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
//        mainViewController?.rootViewController = navigationController
//        mainViewController?.setup(type: 1)
//        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
//        window?.rootViewController = mainViewController
//        if window != nil {
//            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
//        }
//
    }
    
    func settingsButtonClicked() {
      
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
        navigationController?.viewControllers = [storyboard.instantiateViewController(withIdentifier: "ChangePasswordVC")]
        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
        mainViewController?.rootViewController = navigationController
        mainViewController?.setup(type: 1)
        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
        window?.rootViewController = mainViewController
        if window != nil {
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    func ContactUsButtonClicked() {
      
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
        navigationController?.viewControllers = [storyboard.instantiateViewController(withIdentifier: "ContactUsVC")]
        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
        mainViewController?.rootViewController = navigationController
        mainViewController?.setup(type: 1)
        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
        window?.rootViewController = mainViewController
        if window != nil {
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    func AboutUsButtonClicked() {
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
        navigationController?.viewControllers = [storyboard.instantiateViewController(withIdentifier: "AboutUsVC")]
        let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController
        mainViewController?.rootViewController = navigationController
        mainViewController?.setup(type: 1)
        let window: UIWindow? = (UIApplication.shared.delegate?.window)!
        window?.rootViewController = mainViewController
        if window != nil {
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


//MARK: - Firebase Notifications -
extension AppDelegate : MessagingDelegate {
    // [START refresh_token]  same at line 87
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.setValue(fcmToken, forKey: "deviceToken")
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
    
    // upper se chaka gya
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        UserDefaults.standard.setValue(token, forKey: "deviceToken")
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

//MARK: - App Notifications -
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let userInfo = notification.request.content.userInfo
        print("Remote Notification data1 -- \(userInfo)")
        let userInfoaps = userInfo["aps"] as? [AnyHashable: Any]
        if let alert = userInfoaps?["alert"] as? [String: Any]{
            print("alert---\(alert)")
            print("Datata--\(alert["body"] as? String ?? "")")
            let NotificationBody = alert["body"] as? String ?? ""
            let FullBody = NotificationBody
            let Substring = FullBody.components(separatedBy: " ")
            let TicketId = Substring.last
            print("TicketId---\(TicketId ?? "")")
            UserDefaults.standard.setValue(TicketId ?? "", forKey: "TicketId")
        }
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Remote Notification data2 -- \(userInfo)")

        let userInfoaps = userInfo["aps"] as? [AnyHashable: Any]
        if let alert = userInfoaps?["alert"] as? [String: Any]{
            print("alert---\(alert)")
            print("Datata--\(alert["body"] as? String ?? "")")
            let NotificationBody = alert["body"] as? String ?? ""
            let FullBody = NotificationBody
            let Substring = FullBody.components(separatedBy: " ")
            let TicketId = Substring.last
            print("TicketId---\(TicketId ?? "")")
            UserDefaults.standard.setValue(TicketId ?? "", forKey: "TicketId")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let TicketVC = storyboard.instantiateViewController(withIdentifier: "TicketDetailsVC") as! TicketDetailsVC
            self.nVc.pushViewController(TicketVC, animated: false)
        }
        
//        if (userInfo["type"] as? String ?? "")! == "Car Parked" {
//            mPopUp = PopUpView(frame: CGRect(x: 0, y: 0, width: Constants.SCREEN_WIDTH, height: Constants.SCREEN_HEIGHT - 0))
//            mPopUp.delegate = self
//            self.window?.addSubview(mPopUp)
//            mPopUp.reloadUI(dict: userInfo)
//
//        } else if (userInfo["type"] as? String ?? "")! == "Car delivery request accepted" {
//
//            mNotify = NotificationView(frame: CGRect(x: 0, y: 0, width: Constants.SCREEN_WIDTH, height: Constants.SCREEN_HEIGHT - 0))
//            mNotify.delegate = self
//            self.window?.addSubview(mNotify)
//            mNotify.reloadUI(dict: userInfo)
//        }
//
//        print(userInfo["plate_no"] as Any)
//        print(userInfo["ticket_id"] as Any)
//
//        self.moveToNotificationVC()
        completionHandler()
    }
    
}

