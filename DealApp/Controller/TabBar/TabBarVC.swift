import UIKit
import SnapKit
import FirebaseAuth
import CoreLocation

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "tabbar"
        delegate = self
//        UITabBar.appearance().barTintColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
        UITabBar.appearance().barTintColor = .white
        AppUtility.lockOrientation(.portrait)

//        self.tabBar.isTranslucent = false
        configureTabs()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        tabBar.frame.size.height = 85
//        tabBar.frame.origin.y = view.frame.height - 85
        
    }
//    override func viewWillAppear(_ animated: Bool) {
//    }
    
    let photoHelper = MGPhotoHelper()
    var firstTabNavigationController : UINavigationController!
    var dealContentNav : UINavigationController!
    var middleTabNavigationController : UINavigationController!
    var profileNavBar: UINavigationController!
    var mapNavBar: UINavigationController!
    var tabBarNavi : UINavigationController!
    let deals = DealsData()
    var selectedImage: UIImage?
    
    func configureTabs(){
        
        // style:
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
//            appearance.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        } else {
            
        }
        
        let tab1 = StoresFeed()
        let tab2 = DealsContentVC()
        
        let middleButtonVC = UIViewController()
        let tab3 = Profile(senderUID: Auth.auth().currentUser?.uid ?? "")
        let tab4 = MapVC()
        
        middleButtonVC.title = "middleButton"
        tab1.delegate = tab4
        tab1.delegate2 = tab2
        
        //TABS

        let tab1bar = UITabBarItem(title: "", image: UIImage(named: "stores-tab-unselected"), selectedImage: UIImage(named: "stores-tab-unselected"))
                
        let tab2bar = UITabBarItem(title: "", image: UIImage(named: "deas-tab-unselected"), selectedImage: UIImage(named: "deas-tab-unselected"))
        
        let tab3bar = UITabBarItem(title: "", image: UIImage(named: "profile-tab-unselected"), selectedImage: UIImage(named: "profile-selected"))
        
        let tab4bar = UITabBarItem(title: "", image: UIImage(named: "map-tab-unselected"), selectedImage: UIImage(named: "map-tab-unselected"))
        
        let middleButtonTap = UITabBarItem(title: "", image: UIImage(named: "add-deal"), selectedImage: UIImage(named: "add-deal"))
//        let tab1bar = UITabBarItem()
//        let tab2bar = UITabBarItem()
//        let tab3bar = UITabBarItem()
//        let tab4bar = UITabBarItem()
//        let middleButtonTap = UITabBarItem()
        
        tab1.tabBarItem = tab1bar
        tab2.tabBarItem = tab2bar
        tab4.tabBarItem = tab4bar
        tab3.tabBarItem = tab3bar
        middleButtonVC.tabBarItem = middleButtonTap
        
//        tab1.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        tab2.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        middleButtonVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        tab3.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//        tab4.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        firstTabNavigationController = UINavigationController.init(rootViewController: tab1)
        dealContentNav = UINavigationController.init(rootViewController: tab2)
        middleTabNavigationController = UINavigationController.init(rootViewController: middleButtonVC)
        profileNavBar = UINavigationController.init(rootViewController: tab3)
        mapNavBar = UINavigationController.init(rootViewController: tab4)
        self.viewControllers = [firstTabNavigationController, dealContentNav, middleButtonVC, profileNavBar, mapNavBar]
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.title == "middleButton" {
//            photoHelper.presentActionSheet(from: self)
            let postDeal = PostDealVC()
            
            postDeal.postDeal.isEnabled = false
            postDeal.modalPresentationStyle = .fullScreen
            self.present(postDeal, animated: true, completion: nil)
            
            return false
        } else {
            return true
        }
   
    }

  
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}




