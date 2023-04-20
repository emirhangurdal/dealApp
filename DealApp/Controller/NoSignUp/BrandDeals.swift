//
//import UIKit
//import SnapKit
//import LinkPresentation
//import CoreServices
//import GoogleMobileAds
//
//struct UrlIndexModel {
//    var index = Int()
//    var url = String()
//}
//
//@available(iOS 13.0, *)
//class BrandDeals: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureConst()
//        configurePageViewController()
//        view.backgroundColor = .white
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        AppUtility.lockOrientation(.portrait)
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        pageVC.dataSource = nil
//    }
//
//    lazy private var pageVC: UIPageViewController = {
//        var pgvc = UIPageViewController()
//
//        pgvc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//        return pgvc
//    }()
//
//    var vcArray = [UIViewController]()
//    var page = 0
//    let googleAds = GoogleAds()
////    var pageVC = UIPageViewController()
//    var indexInit = 0
//    var indexFin = 8
//    var pageX = 0
//    var navTitle = String()
//    var brandDeals = [ImpactDealModel]()
//    init(brandDeals: [ImpactDealModel], title: String) {
//        self.navTitle = title
//        self.brandDeals = brandDeals
//        super.init(nibName: nil, bundle: nil)
//        self.navigationItem.title = title
//    }
//    required init?(coder: NSCoder) {
//        fatalError("Invalid way of decoding this class")
//    }
//
//    func getVCs(){
//        let pageNumber = brandDeals.count/8
//
//        if brandDeals.count < 8 {
//           let vc = BrandDealsCollection(brandDeals: brandDeals)
//            vcArray.append(vc)
//
//        } else {
//
//            for i in 0..<brandDeals.count {
//                if  i % 8 == 0 {
//                    pageX += 1
//
//                    if i != 0 {
//                        indexInit += 8
//                        indexFin += 8
//                    }
//
//                    print("pageX = \(pageX)")
//                    if indexFin <= brandDeals.count {
//
//                        let data = Array(brandDeals[indexInit..<indexFin])
//                        let vc = BrandDealsCollection(brandDeals: data)
//
//                        vcArray.append(vc)
//                    } else {
//
//                        let data = Array(brandDeals[indexInit..<brandDeals.count])
//                        let vc = BrandDealsCollection(brandDeals: data)
//
//                        vcArray.append(vc)
//                    }
//
//                } else {
//                    let remainder = i%8
//
//                    if pageX == pageNumber {
//
//                    }
//
//                }
//            }
//        }
//    }
//
//    func configurePageViewController(){
//        getVCs()
//        guard let first = vcArray.first else {
//            return
//        }
//        pageVC.dataSource = self
//        pageVC.delegate = self
//        pageVC.setViewControllers([first],
//                                  direction: .forward, animated: true, completion: nil)
//    }
//    func configureConst(){
//        addChild(pageVC)
//        view.addSubview(pageVC.view)
//        googleAds.setUpGoogleAds(viewController: self)
//
//        pageVC.view.snp.makeConstraints { pageVC in
//            pageVC.top.equalTo(view.safeAreaLayoutGuide).offset(2)
//            pageVC.bottom.equalTo(googleAds.bannerView.snp.top).offset(-2)
//            pageVC.right.equalTo(view)
//            pageVC.left.equalTo(view)
//        }
//        pageVC.willMove(toParent: self)
//    }
//}
//
////MARK: - Collection View Delegates
//@available(iOS 13.0, *)
//extension BrandDeals: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        print("viewControllerBefore")
//
//        guard let index = vcArray.firstIndex(of: viewController), index > 0 else {return nil}
//        let before = index - 1
//        return vcArray[before]
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        print("viewControllerAfter")
//
//        guard let index = vcArray.firstIndex(of: viewController), index < vcArray.count - 1 else {return nil}
//        let after = index + 1
//        return vcArray[after]
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//
//        if finished == true {
//
//        }
//        if completed == true {
//
//        } else {
//
//        }
//    }
//
//    func removeSwipeGesture(bool: Bool){
//        for view in self.pageVC.view.subviews {
//            if let subView = view as? UIScrollView {
//                subView.isScrollEnabled = bool
//            }
//        }
//    }
//    func addSwipeGesture(){
//        for view in self.pageVC.view.subviews {
//            if let subView = view as? UIScrollView {
//                subView.isScrollEnabled = true
//            }
//        }
//    }
//}
//
////extension UIPageViewController {
////    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
////        if let currentViewController = viewControllers?[0] {
////            if let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) {
////                setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
////            }
////        }
////    }
////
////    func goToPreviousPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
////        if let currentViewController = viewControllers?[0] {
////            if let previousPage = dataSource?.pageViewController(self, viewControllerBefore: currentViewController){
////                setViewControllers([previousPage], direction: .reverse, animated: true, completion: completion)
////            }
////        }
////    }
////}
//
//
