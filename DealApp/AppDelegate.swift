
import UIKit
import CoreData
import FirebaseAuth
import Firebase
import RxSwift
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import GoogleSignIn


@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "d6b5af80e8456a0c728ed96bcbaf9a86" ]
//        ApplicationDelegate.shared.application(
//                    application,
//                    didFinishLaunchingWithOptions: launchOptions
//                )
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    
                    switch status {
                    case .authorized:
                        print("enable tracking")
                        GADMobileAds.sharedInstance().start(completionHandler: nil)
//                        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ GADSimulatorID ]
                    case .denied:
                        print("disable tracking")
                        GADMobileAds.sharedInstance().start(completionHandler: nil)
//                        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ GADSimulatorID ]
                    default:
                        print("disable tracking default")
                        GADMobileAds.sharedInstance().start(completionHandler: nil)
//                        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ GADSimulatorID ]
                    }
                }
            }
        } else {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
        
        
        if #available(iOS 13, *) {
            // do only pure app launch stuff, not interface stuff
        } else {
            print("it is below ios 13")
            //                        self.window = UIWindow(frame: UIScreen.main.bounds)
            window = UIWindow(frame: UIScreen.main.bounds)
            let mainView = SignUp()
            let navController = UINavigationController(rootViewController: mainView)
            window?.rootViewController = navController
            window?.makeKeyAndVisible()
        }
        return true
    }
  

    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        
        // change the root view controller to your specific view controller
        window.rootViewController = vc
    }
    
    //     MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }
    
    //MARK: - Sign In With Gmail or Facebook with url through their apps or in-app browser.
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
        print("url in app delegate = \(url) ")
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DealApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


