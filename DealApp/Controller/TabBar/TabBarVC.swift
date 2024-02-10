import UIKit
import SnapKit
import FirebaseAuth
import CoreLocation

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "tabbar"
        delegate = self
        UITabBar.appearance().barTintColor = .white
        AppUtility.lockOrientation(.portrait)
        configureTabs()
    }
    
    let photoHelper = MGPhotoHelper()
    var stores : UINavigationController!
    var dealsVC : UINavigationController!
    var coupons : UINavigationController!
    var middleTabNavigationController : UINavigationController!
    var profileNavBar: UINavigationController!
    var mapNavBar: UINavigationController!
    var tabBarNavi : UINavigationController!
    let deals = DealsData()
    var selectedImage: UIImage?
    
    func configureTabs(){
        
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
        let tab2alt = CategoryView()
        
        let tab3 = Profile(senderUID: Auth.auth().currentUser?.uid ?? "")
        let tab4 = MapVC()
        
        tab1.delegate = tab4
        tab1.delegate2 = tab2
        
        //TABS
        let tabCouponsbar = UITabBarItem(title: "", image: UIImage(named: "icons8-coupon-100"), selectedImage: UIImage(named: "icons8-coupon-100"))
        
        let storesBar = UITabBarItem(title: "", image: UIImage(named: "stores-tab-unselected"), selectedImage: UIImage(named: "stores-tab-unselected"))
                
        let dealsBar = UITabBarItem(title: "", image: UIImage(named: "deas-tab-unselected"), selectedImage: UIImage(named: "deas-tab-unselected"))
        
        let profileBar = UITabBarItem(title: "", image: UIImage(named: "profile-tab-unselected"), selectedImage: UIImage(named: "profile-selected"))
        
        let mapBar = UITabBarItem(title: "", image: UIImage(named: "map-tab-unselected"), selectedImage: UIImage(named: "map-tab-unselected"))
        
        tab2alt.tabBarItem = tabCouponsbar
        tab1.tabBarItem = storesBar
        tab2.tabBarItem  = dealsBar
        tab3.tabBarItem = profileBar
        tab4.tabBarItem = mapBar
        
        stores = UINavigationController.init(rootViewController: tab1)
        dealsVC = UINavigationController.init(rootViewController: tab2)
        coupons = UINavigationController.init(rootViewController: tab2alt)
        profileNavBar = UINavigationController.init(rootViewController: tab3)
        mapNavBar = UINavigationController.init(rootViewController: tab4)
        self.viewControllers = [stores,
                                coupons,
                                dealsVC,
                                profileNavBar,
                                mapNavBar]
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if viewController.title == "middleButton" {
////            photoHelper.presentActionSheet(from: self)
//            let postDeal = PostDealVC()
//
//            postDeal.postDeal.isEnabled = false
//            postDeal.modalPresentationStyle = .fullScreen
//            self.present(postDeal, animated: true, completion: nil)
//
//            return false
//        } else {
//            return true
//        }
        return true
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




