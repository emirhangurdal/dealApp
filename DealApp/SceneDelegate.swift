
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let userDefaults = UserDefaults.standard
    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            window = UIWindow(frame: windowScene.coordinateSpace.bounds)
//            window = UIWindow(frame: windowScene.screen.bounds)
//            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            window?.windowScene = windowScene
            let mainView = SignUp()
            
            let navController = UINavigationController(rootViewController: mainView)
            window?.rootViewController = navController
            window?.makeKeyAndVisible()
        }
    }
    
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        
        // change the root view controller to your specific view controller
        window.rootViewController = vc
    }
    
    // this function for Facebook Login via Facebook's app after iOS13.
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        print("url in FB or Gmail login scene delegate = \(url)")
//        ApplicationDelegate.shared.application(
//            UIApplication.shared,
//            open: url,
//            sourceApplication: nil,
//            annotation: [UIApplication.OpenURLOptionsKey.annotation]
//        )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneDidBecomeActive")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("sceneWillEnterForeground")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "savedTime"), object: nil, userInfo: nil)

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        
        userDefaults.set(Date().timeIntervalSince1970, forKey: "startTime")

        print("sceneDidEnterBackground")
        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stopTimer"), object: nil, userInfo: nil)
        
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

