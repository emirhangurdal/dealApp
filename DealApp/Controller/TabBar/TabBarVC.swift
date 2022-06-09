import UIKit
import SnapKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    override func viewDidLoad() {
        print("I am TabBar ViewDidLoad")
        delegate = self
        middleButtonVC.title = "middleButton"
        UITabBar.appearance().barTintColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
//        self.tabBar.isTranslucent = false
        configureTabs()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.frame.size.height = 85
        tabBar.frame.origin.y = view.frame.height - 85
    }
    let photoHelper = MGPhotoHelper()
    var firstTabNavigationController : UINavigationController!
    var dealContentNav : UINavigationController!
    var middleTabNavigationController : UINavigationController!
    var profileNavBar: UINavigationController!
    var mapNavBar: UINavigationController!
    var tabBarNavi : UINavigationController!
    let tab1 = StoresFeed()
    let tab2 = DealsContentVC()
    let tab3 = Profile()
    let tab4 = MapVC()  
    let deals = DealsData()
    let postDeal = PostDealVC()
    let middleButtonVC = UIViewController()
    func configureTabs(){
        tab1.delegate = tab4
        tab1.delegate2 = tab2
       
        // style:
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        } else {
           
        }
        //TABS
        let tab1bar = UITabBarItem(title: "", image: resizeImage(image: UIImage(named: "icons8-shop-local-100")!, targetSize: CGSize(width: 40, height:  40)).withRenderingMode(.alwaysOriginal), selectedImage: resizeImage(image: UIImage(named: "icons8-shop-local-100-selected")!, targetSize: CGSize(width: 40, height:  40)).withRenderingMode(.alwaysOriginal))
        tab1.tabBarItem = tab1bar
        let tab2bar = UITabBarItem(title: "", image: resizeImage(image: UIImage(named: "icons8-discount-100")!, targetSize: CGSize(width: 40, height:  40)).withRenderingMode(.alwaysOriginal), selectedImage: resizeImage(image: UIImage(named: "icons8-discount-100-selected")!, targetSize: CGSize(width: 40, height:  40)).withRenderingMode(.alwaysOriginal))
        tab2.tabBarItem = tab2bar
        let middleButtonTap = UITabBarItem(title: "", image: resizeImage(image: UIImage(named: "icons8-add-100")!, targetSize: CGSize(width: 40, height: 40)).withRenderingMode(.alwaysOriginal), selectedImage: resizeImage(image: UIImage(named: "icons8-add-100")!, targetSize: CGSize(width: 40, height: 40)).withRenderingMode(.alwaysOriginal))
        let tab3bar = UITabBarItem(title: "", image: resizeImage(image: UIImage(named: "icons8-profile-not-selected-50")!, targetSize: CGSize(width: 40, height: 40)), selectedImage: resizeImage(image: UIImage(named: "selected-profile-tab-50")!, targetSize: CGSize(width: 40, height: 40)))
        let tab4bar = UITabBarItem(title: "", image: resizeImage(image: UIImage(named: "icons8-map-48")!, targetSize: CGSize(width: 40, height: 40)), selectedImage: resizeImage(image: UIImage(named: "icons8-map-48-selected")!, targetSize: CGSize(width: 40, height: 40)))
        tab4.tabBarItem = tab4bar
        tab3.tabBarItem = tab3bar

        middleButtonVC.tabBarItem = middleButtonTap
        firstTabNavigationController = UINavigationController.init(rootViewController: tab1)
        dealContentNav = UINavigationController.init(rootViewController: tab2)
        middleTabNavigationController = UINavigationController.init(rootViewController: middleButtonVC)
        profileNavBar = UINavigationController.init(rootViewController: tab3)
        mapNavBar = UINavigationController.init(rootViewController: tab4)
        self.viewControllers = [firstTabNavigationController, dealContentNav, middleButtonVC, profileNavBar, mapNavBar]
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.title == "DealsContentVC" {
            print("DealsData.shared.dealsArray = \(DealsData.shared.dealsArray)")
        }
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.title == "middleButton" {
            photoHelper.presentActionSheet(from: self)
            return false
        } else {
            return true
        }
    }
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true)
//        guard let image = info[.editedImage] as? UIImage else {return }
//        print("No image found")
//        let postDeal = PostDealVC()
//        postDeal.dealImage.image = image
//        self.present(postDeal, animated: true, completion: nil)
//    }
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




