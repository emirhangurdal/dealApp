
import UIKit
import RxSwift
import SnapKit
import RxCocoa
import RxDataSources
import CoreLocation
import Firebase
import MapKit
import FirebaseAuth
import Segmentio
import FirebaseFirestore
import SafariServices
import GoogleMobileAds



protocol StoresFeedDelegate: class {
    func createAnnotations(mainData: [StoresFeedModel])
}
protocol StoresFeedDelegate2: class {
    func getStoreTitles(mainData: [StoresFeedModel])
}
protocol StoresFeedDelegate3: class {
    func getStoreTitles(mainData: [StoresFeedModel])
}

protocol RemoveDeleteButton: class {
    func removeButton()
}

class StoresFeed: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UpdateCustomCell, CLLocationManagerDelegate, UpdateButtonImage, URLSessionDataDelegate, UpdateFavorites, OpenLink, GADBannerViewDelegate {
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        tableView.register(StoresTabCell.self, forCellReuseIdentifier: storesFeedCellId)
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        googleAds.setUpGoogleAds(viewController: self)
        configureConstr()
        bindTableViewMain()
        selectedCell()
        checkLocAuthorization()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    //MARK: AD Request
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("error receving ad = \(error.localizedDescription)")
    }
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("succesfully received ad")
    }
    

    override func viewWillLayoutSubviews() {
        print("viewWillLayoutSubviews")
       
    }
    override func viewWillAppear(_ animated: Bool) {
        print("storesfeed viewwillappear")
        AppUtility.lockOrientation(.portrait)
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewdidappear")
        
    }
    //MARK: Do When Location Not Authorized
    func locationNotAuthorized() {
        let alert = UIAlertController(title: "You can't see local stores if you don't authorize Depple to get location since the data is location based. But you can see the deals from major deals. If you wanna see them, you need to allow Depple to get location in your settings.".localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
//                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//                    return
//                }
//                if UIApplication.shared.canOpenURL(settingsUrl) {
//
//                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
//
//                        print("Settings opened: \(success)") // Prints true
//                    })
//                }
            
        }))
        self.present(alert, animated: true, completion: nil)
        if #available(iOS 13, *) {
            alert.addAction(UIAlertAction(title: "Go to Brand Deals".localized(), style: .default, handler: { action in
                let allDeals = AllDealsVC()
                self.navigationController?.pushViewController(allDeals, animated: true)
            }))
        }
    }
    
    func checkLocAuthorization(){
            if
                CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                print("authorization has been given")
            } else {
                print("authorization has not been given")
                locationNotAuthorized()
            }
    }

    //MARK: - Properties
    var searchKeyword = String()
    var CACHE_KEY = String()
    var indexIcon = Int()
    var tableView = UITableView()
    let googleAds = GoogleAds()
    var segmentioView: Segmentio!
    var topView = UIView()
    lazy var logOut = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutTapped))
    @objc func logOutTapped(){
        let signUp = SignUp()
        let navController = UINavigationController(rootViewController: signUp)
        guard let window = self.view.window else {
            return
        }
        
        if #available(iOS 13.0, *) {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(navController)
            self.dismiss(animated: true, completion: nil)
            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil, completion: nil)
            //            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil, completion: nil)
            
        } else {
            // Fallback on earlier versions
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = navController
            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }

//        window.rootViewController = navController
//        window.makeKeyAndVisible()
//        window.rootViewController?.dismiss(animated: false, completion: nil)
//        self.dismiss(animated: false, completion: nil)
        
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    weak var delegate: StoresFeedDelegate?
    weak var delegate2: StoresFeedDelegate2?
    weak var delegate3: StoresFeedDelegate3?
    weak var delegate4: RemoveDeleteButton?
    let firebaseAuth = Auth.auth()
    let cache = NSCache<NSString, DataStructHolder>()
    let db = Firestore.firestore()
    let locationManager = CLLocationManager()
    private let storesFeedCellId = "StoresFeedCellID"
    private let disposeBag = DisposeBag()
    private var newFavData = [StoresFeedModel]()
    private let refreshControlFavs = UIRefreshControl()
    private let refreshControlMain = UIRefreshControl()
    var spinner = SpinnerViewController()
    var storesData = StoresData()
    private let noValueImage = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/no%20value.jpg?alt=media&token=df6afb68-402f-4681-ad9b-5a30532376a1"
    
    //MARK: - Segments
    let supermarket = SegmentioItem(
        title: "Supermarket".localized(),
        image: nil
    )
    let pharmacy = SegmentioItem(
        title: "Pharmacy".localized(),
        image: nil
    )
    let restaurant = SegmentioItem(
        title: "Restaurant".localized(),
        image: nil
    )
    
    let store = SegmentioItem(
        title: "Store".localized(),
        image: nil
    )
    let clothing = SegmentioItem(
        title: "Clothing".localized(),
        image: nil
    )
    let imagesC = Images()
    func setupSegmentio(){
        
//        let segmentioViewRect = CGRect(x: 0, y: 0, width: topView.frame.width, height: 50)
        segmentioView = Segmentio()
        let content: [SegmentioItem] = [supermarket, pharmacy, restaurant, store, clothing]
        let indicatorOptions = SegmentioIndicatorOptions(
            type: .bottom,
            ratio: 1,
            height: 5,
            color: UIColor(red: 153/255, green: 219/255, blue: 246/255, alpha: 1.0)
        )
        
        var horizontalSeparatorOptions = SegmentioHorizontalSeparatorOptions()
        var verticalSeperatorOptions = SegmentioVerticalSeparatorOptions(ratio: 0.1, color: .white)
        var states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            ),
            selectedState: SegmentioState(
                backgroundColor: .white,
                titleFont: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                titleTextColor: .black
            ),
            highlightedState: SegmentioState(
                backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                titleFont: UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            )
        )

        let options = SegmentioOptions(
            backgroundColor: .white,
            segmentPosition: .dynamic,
            scrollEnabled: true,
            indicatorOptions: indicatorOptions,
            horizontalSeparatorOptions: nil,
            verticalSeparatorOptions: nil,
            imageContentMode: .center,
            labelTextAlignment: .center,
            segmentStates: states
        )
        segmentioView.setup(content: content, style: .onlyLabel, options: options)
        segmentioView.selectedSegmentioIndex = 0
        
        if segmentioView.selectedSegmentioIndex == 0 {
            let key = self.segmentioView.segmentioItems[0].title
            self.getDataFromMapKit(searchFor: key ?? "", cacheKey: key ?? "", index: 0)
        }
        
        segmentioView.valueDidChange = { segmentio, segmentIndex in
            let key = self.segmentioView.segmentioItems[segmentIndex].title
            self.getDataFromMapKit(searchFor: key ?? "", cacheKey: key ?? "", index: segmentIndex)
//            if segmentIndex == 0 {
//                self.getDataFromMapKit(searchFor: key ?? "", cacheKey: key ?? "")
//
//            } else if segmentIndex == 1 {
//                self.getDataFromMapKit(searchFor: key ?? "", cacheKey: key ?? "")
//            }
        }
    }
    //MARK: - Favorites Segment Change Handling Methods 
    func favoritesData(){
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            tableView.isHidden = false
            
        } else {
            tableView.isHidden = true
        }
    }
    // recall api for favorite stores when segment selected == 1
    func reCallApi(){
        topView.isUserInteractionEnabled = false
        if storesData.businessDataFav.count == 0 {
            addSpinner()
            topView.isUserInteractionEnabled = true
            stopSpinner()
        }
        
        if let cachedVersion = self.cache.object(forKey: "FavoriteStoresCached") {
            print("normandy")
            print("cachedVersion.thing reCallApi = \(cachedVersion.thing)")
            storesData.businesses.accept(cachedVersion.thing)
            
            topView.isUserInteractionEnabled = true
        } else {
            
            storesData.getFavDataFromFirebase { favData in
                self.addSpinner()
                print("foobar")
                print("favData in closure = \(favData)")
                self.storesData.businessDataFav = favData
                
                self.cache.setObject(DataStructHolder(thing: favData), forKey: "FavoriteStoresCached")
                
                DispatchQueue.main.async {
                    self.storesData.businesses.accept(self.storesData.businessDataFav)
                    self.stopSpinner()
                    self.topView.isUserInteractionEnabled = true
                }
            }
        }
    }
    func updateFavorites() {
        print("updateFavorites")
        self.topView.isUserInteractionEnabled = false
        self.segmentioView.selectedSegmentioIndex = 1
        addSpinner()
        storesData.businessDataFav.removeAll()
        self.cache.setObject(DataStructHolder(thing: storesData.businessDataFav), forKey: "FavoriteStoresCached")
        
        storesData.getFavDataFromFirebase { favData in
            print("monument")
            print("favData in closure = \(favData)")
            self.storesData.businessDataFav = favData
            self.cache.setObject(DataStructHolder(thing: self.storesData.businessDataFav), forKey: "FavoriteStoresCached")
            
            DispatchQueue.main.async {
                self.storesData.businesses.accept(self.storesData.businessDataFav)
            }
            self.stopSpinner()
            self.topView.isUserInteractionEnabled = true
        }
        
        if let cachedVersion = self.cache.object(forKey: "FavoriteStoresCached") {
            self.stopSpinner()
            self.topView.isUserInteractionEnabled = true
        }
    }
    
    //MARK: - Refresh Control
    func configureRefreshControlMain(searchFor: String) {
        refreshControlMain.attributedTitle = NSAttributedString(string: "Pull to refresh".localized())
        refreshControlMain.addTarget(self, action: #selector(refreshMain(_:)), for: .valueChanged)
        tableView.addSubview(refreshControlMain) // not required when using UITableViewController
    }
    @objc func refreshMain(_ sender: AnyObject) {
        print("refreshmain working")
        cache.removeObject(forKey: CACHE_KEY as NSString)
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        getDataFromMapKit(searchFor: searchKeyword, cacheKey: CACHE_KEY, index: indexIcon)
//        getMainData()
        refreshControlMain.endRefreshing()
    }
    func configureRefreshControlFav() {
        refreshControlFavs.attributedTitle = NSAttributedString(string: "Pull to refresh".localized())
        refreshControlFavs.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControlFavs) // not required when using UITableViewController
    }
    @objc func refresh(_ sender: AnyObject) {
        print("refresh working")
        reCallApi()
        refreshControlFavs.endRefreshing()
    }
    //MARK: - Get Data
    var currentLocation: CLLocation!  
    
    func getDataFromMapKit(searchFor: String, cacheKey: String, index: Int){
        print("getDataFromMapKit")
        searchKeyword = searchFor
        CACHE_KEY = cacheKey
        indexIcon = index
        let imageSet = [imagesC.supermarket, imagesC.pharmacy, imagesC.restaurant, imagesC.store, imagesC.clothing]

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            configureRefreshControlMain(searchFor: searchFor)
            let oldKeyForCache = "StoresFeedCached"
            currentLocation = locationManager.location
            StoresData.shared.lat = 25.765485799334368
            StoresData.shared.lon = -80.20719713710085
            
            if let cachedVersion = self.cache.object(forKey: cacheKey as NSString) {
                
                    storesData.businesses.accept(cachedVersion.thing)
                    delegate?.createAnnotations(mainData: cachedVersion.thing)
                    delegate2?.getStoreTitles(mainData: cachedVersion.thing)
                    delegate3?.getStoreTitles(mainData: cachedVersion.thing)
                    StoresData.shared.chooseStoreData = cachedVersion.thing

            } else {
                addSpinner()
                storesData.businessDataMain.removeAll()
                uMKlocaksearch(searchFor: searchFor) { dataFromRequest in
                    for mapItem in dataFromRequest {
                        let genID = "\(mapItem.placemark.coordinate.latitude).\(mapItem.placemark.coordinate.longitude)"
                     
                        self.storesData.businessDataMain.append(StoresFeedModel(title: mapItem.name ?? "",
                                                                                image: imageSet[index]!,
                                                                                id: genID,
                                                                                distance: 0.00,
                                                                                latitude: mapItem.placemark.coordinate.latitude,
                                                                                longitude: mapItem.placemark.coordinate.longitude,
                                                                                address1: mapItem.placemark.title ?? "",
                                                                                address2: "",
                                                                                url: mapItem.url?.absoluteString ?? "url not found",
                                                                                phoneNumber: mapItem.phoneNumber ?? "phone not found"))
                    }
                    self.cache.setObject(DataStructHolder(thing: self.storesData.businessDataMain), forKey: cacheKey as NSString)
                    self.storesData.businesses.accept(self.storesData.businessDataMain)
                    
                    //delegated:
                    self.delegate?.createAnnotations(mainData: self.storesData.businessDataMain)
                    self.delegate2?.getStoreTitles(mainData: self.storesData.businessDataMain)
                    self.delegate3?.getStoreTitles(mainData: self.storesData.businessDataMain)
                    StoresData.shared.chooseStoreData = self.storesData.businessDataMain
                }
                self.stopSpinner()

            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableRefresh"), object: nil, userInfo: nil)
        }
    }
    func uMKlocaksearch(searchFor: String, completionHandler: @escaping ([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = searchFor.localized()
        let center = CLLocationCoordinate2D(latitude: StoresData.shared.lat, longitude: StoresData.shared.lon)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        request.region = region
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if let error = error {
                print("error MKLocal Search = \(error.localizedDescription)")
                return
            } else {
                if response != nil {
                    completionHandler(response?.mapItems ?? [])
                } else {
                    return
                }
                
            }
        }
    }
    
    //MARK: - Data From Google API - Optional
    func getMainData() {
        print("getMaindata")
        topView.isUserInteractionEnabled = false

        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
//            locationManager.startUpdatingLocation()
            currentLocation = locationManager.location
            
            StoresData.shared.lat = currentLocation.coordinate.latitude
            StoresData.shared.lon = currentLocation.coordinate.longitude
            
            if let cachedVersion = self.cache.object(forKey: "StoresFeedCached") {
                self.storesData.businesses.accept(cachedVersion.thing)
                self.delegate?.createAnnotations(mainData: cachedVersion.thing)
                self.delegate2?.getStoreTitles(mainData: cachedVersion.thing)
                self.delegate3?.getStoreTitles(mainData: cachedVersion.thing)
                StoresData.shared.chooseStoreData = cachedVersion.thing
                tableView.isHidden = false
                topView.isUserInteractionEnabled = true
                
                print("cached data?")
            } else {
                print("not cached starting spinner")
                addSpinner()
//                GoogleApiManager.shared.getPlaceInfo(latitude: StoresData.shared.lat, longitude: StoresData.shared.lon) { dataFromRequest in
//                    self.storesData.businessDataMain.removeAll()
//                    DispatchQueue.main.async {
//                        self.storesData.businessDataMain = dataFromRequest
//                        self.cache.setObject(DataStructHolder(thing: self.storesData.businessDataMain), forKey: "StoresFeedCached")
//                        self.storesData.businesses.accept(self.storesData.businessDataMain)
//
//                        //delegated:
//                        self.delegate?.createAnnotations(mainData: self.storesData.businessDataMain)
//                        self.delegate2?.getStoreTitles(mainData: self.storesData.businessDataMain)
//                        self.delegate3?.getStoreTitles(mainData: self.storesData.businessDataMain)
//                        StoresData.shared.chooseStoreData = self.storesData.businessDataMain
//                    }
//                    self.topView.isUserInteractionEnabled = true
//                    self.stopSpinner()
//                }
            }
        } else {
            print("authorization problem")
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("urlSessionDidFinishEvents")
    }
    
    //MARK: - Fading Message

    func labelfade() { // this works in delete button on StoresTabCell.swift where id of the selected store is removed from firebase.
        fadingLabelConfig(message: "Store Removed From Favorites".localized(), color: UIColor.gray, finalAlpha: 0.0)
    }
    func updateButton() {
        fadingLabelConfig(message: "Store Added To Favorites".localized(), color: UIColor.gray, finalAlpha: 0.0)
    }
    func fadingLabelConfig(message: String, color: UIColor, finalAlpha: CGFloat){
        var fadingLabel: UILabel!
        fadingLabel = UILabel()
        fadingLabel.text = "Text"
        view.addSubview(fadingLabel)
        fadingLabel.isHidden = true
        fadingLabel.snp.makeConstraints { fadingLabel in
            fadingLabel.height.equalTo(100)
            fadingLabel.width.equalTo(300)
            fadingLabel.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            fadingLabel.centerY.equalTo(self.view.safeAreaLayoutGuide.snp.centerY).offset(150)
        }
        fadeMessage()
        func fadeMessage() {
            fadingLabel.text          = message
            fadingLabel.alpha         = 0.8
            fadingLabel.isHidden      = false
            fadingLabel.textAlignment = .center
            fadingLabel.backgroundColor     = color
            fadingLabel.layer.cornerRadius  = 5
            fadingLabel.layer.masksToBounds = true
            fadingLabel.font = UIFont.systemFont(ofSize: 20)
            UIView.animate(withDuration: 2.0, animations: { () -> Void in
                fadingLabel.alpha = finalAlpha
            })
        }
    }
    //MARK: - Spinner
    func addSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
        topView.isUserInteractionEnabled = false
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
    }
    func stopSpinner(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
            self.topView.isUserInteractionEnabled = true
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
        }
    }
    //MARK: - Phone the Supermarket
    func openLink(url: String) {
        let alert = UIAlertController(title: "You are leaving Depple?".localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { action in
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let url = URL(string: url)
            let googleMapsURL = URL(string: "https://www.google.com/")
            let vc = SFSafariViewController(url: url ?? googleMapsURL!, configuration: config)
            self.present(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)

//        let webV = TermsVC(myURL: url)
//        self.navigationController?.pushViewController(webV, animated: true)
    }
    //MARK: - Constraints.
    func configureConstr() {
        
        title = "StoresFeed"
        tabBarItem.title = ""
        view.addSubview(topView)
        setupSegmentio()
        topView.addSubview(segmentioView)
        view.addSubview(tableView)
        
        tableView.bounces = true
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
//        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
      
        
        topView.snp.makeConstraints { topView in
            topView.top.equalTo(view.safeAreaLayoutGuide)
            topView.width.equalTo(view.safeAreaLayoutGuide)
            topView.height.equalTo(50)
            topView.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        segmentioView.snp.makeConstraints { segmentioView in
            segmentioView.width.equalTo(topView)
            segmentioView.height.equalTo(topView)
        }
        
        
        
        tableView.snp.makeConstraints { tableView in
            tableView.top.equalTo(topView.snp.bottom).offset(1)
            tableView.bottom.equalTo(googleAds.bannerView.snp.top).offset(-1)
            tableView.right.equalTo(view.safeAreaLayoutGuide)
            tableView.left.equalTo(view.safeAreaLayoutGuide)
        }
        configureNavBar()
    }
    func configureNavBar() {
        self.navigationController?.navigationBar.backgroundColor = C.shared.navColor
        self.navigationItem.title = "Stores Near You".localized()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        self.navigationController?.navigationBar.isTranslucent = true
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = C.shared.navColor
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            // Customizing our navigation bar
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    //MARK: - RxSwift TableViewbind
    func bindTableViewMain() {
        storesData.businesses.asObservable()
            .bind(to: tableView
                    .rx
                    .items(cellIdentifier: storesFeedCellId, cellType: StoresTabCell.self)
            )
        {
           [unowned self] row, businessData, cell in
            
            cell.delegate = self
            cell.delegate2 = self
            cell.delegate3 = self
            cell.delegate4 = self
            self.delegate4 = cell
            
            cell.storeid = businessData.id
            print("cell.storeid = \(cell.storeid)")
            print("businessData.id = \(businessData.id)")
            
            // this is to show the correct images for corresponding titles:
            let imageView = UIImageView()
            cell.storeImage.image = nil
            if cell.storeid == businessData.id {
                cell.phoneNumber = businessData.phoneNumber
                cell.urlLabel.text = businessData.url
                cell.distance = 0.0
                cell.storeName.text = businessData.title
                
//                cell.storeImage.loadImageAsync(with: businessData.image, placeholder: UIImage(named: "no-image"))
                cell.storeImage.image = UIImage(data: businessData.image)
            }
            // buttons to be hidden:
//            if self.segmentioView.selectedSegmentioIndex == 1 {
//                cell.addFavButton.isHidden = true
//                cell.deleteFromFavsButton.isHidden = false
//                self.refreshControlMain.removeFromSuperview()
//            } else if self.segmentioView.selectedSegmentioIndex == 0 {
//                self.refreshControlFavs.removeFromSuperview()
//                cell.addFavButton.isHidden = false
//                cell.deleteFromFavsButton.isHidden = true
//            }
        }
        .disposed(by: disposeBag)
    }
    func selectedCell() {
        print("selected cell")
        tableView.rx
            .modelSelected(StoresFeedModel.self)
            .subscribe(onNext:  { [unowned self] store in
                self.storesData.storeIDSelected = store.id
                print("store.lat = \(store.latitude)")
                print("store long = \(store.longitude)")
                let storeDeals = StoreDeals(storeDetail: store)
                self.navigationController?.pushViewController(storeDeals, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 5
        let maskLayer = CALayer()
//        maskLayer.cornerRadius = 10
        //if you want round edges
        maskLayer.backgroundColor = UIColor.blue.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("didUpdateLocations")
//        StoresData.shared.lat = locValue.latitude
//        StoresData.shared.lon = locValue.longitude
        //        latitude = locValue.latitude
        //        longitude = locValue.longitude
        //        getMainData()
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager, status: CLAuthorizationStatus) {
        print("locationManagerDidChangeAuthorization")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError = \(error.localizedDescription)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization")
        switch status {
        case .denied:
            tableView.isHidden = true
            locationNotAuthorized()
          
        case .notDetermined:
            manager.requestLocation()
            
            print("authorization not determined")
        case .authorizedAlways, .authorizedWhenInUse:
            // Do your thing here
            tableView.isHidden = false
//            getMainData()
            getDataFromMapKit(searchFor: searchKeyword, cacheKey: CACHE_KEY, index: indexIcon)
            
        default:
            // Permission denied, create alertview here.
            
            print("Permission denied, do something else")
        }
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidPauseLocationUpdates")
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidResumeLocationUpdates")
    }
    
    //MARK: - Resize
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
//MARK: - Extensions for Fonts
extension UISegmentedControl
{
    func defaultConfiguration(font: UIFont = UIFont.systemFont(ofSize: 12), color: UIColor = UIColor.white)
    {
        let defaultAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(defaultAttributes, for: .normal)
    }
    
    func selectedConfiguration(font: UIFont = UIFont.boldSystemFont(ofSize: 12), color: UIColor = UIColor.red)
    {
        let selectedAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
        setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}


