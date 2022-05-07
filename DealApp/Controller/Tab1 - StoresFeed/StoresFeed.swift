
import UIKit
import RxSwift
import SnapKit
import RxCocoa
import RxDataSources
import CoreLocation
import CoreData
import Firebase
import FirebaseAuth

protocol StoresFeedDelegate: class {
    func createAnnotations(mainData: [StoresFeedModel])
}


class StoresFeed: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UpdateCustomCell, CLLocationManagerDelegate, UpdateButtonImage {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("storesfeed viewdidload")
        locationManager.delegate = self
        tableView.register(StoresTabCell.self, forCellReuseIdentifier: storesFeedCellId)
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        bindTableViewMain()
        configureConstr()
        configureNavBar()
        selectedCell()
        print("UserUID = \(Auth.auth().currentUser?.uid)")
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        self.navigationItem.rightBarButtonItem = logOut
    }
    override func viewWillAppear(_ animated: Bool) {
        print("storesfeed viewwillappear")
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("viewdidappear")
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        if
            CLLocationManager.authorizationStatus() != .authorizedWhenInUse || CLLocationManager.authorizationStatus() != .authorizedAlways {
            
          
            print("authorization not granted")
        }
    }
    //MARK: - Properties
    lazy var tableView = UITableView()
    lazy var logOut = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutTapped)) //
    @objc func logOutTapped(){
        print("logOut")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    weak var delegate: StoresFeedDelegate?
    let db = Firestore.firestore()
    let apiDispatchGroup = DispatchGroup()
    let locationManager = CLLocationManager()
    private let storesFeedCellId = "StoresFeedCellID"
    var selectedID = String()
    private let disposeBag = DisposeBag()
    private var longitude = Double()
    private var latitude = Double()
    private var newFavData = [StoresFeedModel]()
    private let refreshControlFavs = UIRefreshControl()
    private let refreshControlMain = UIRefreshControl()
    var spinner = SpinnerViewController()
    var storesData = StoresData()
    private let noValueImage = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/no%20value.jpg?alt=media&token=df6afb68-402f-4681-ad9b-5a30532376a1"
    enum SegmentType: String {
        case allStores = "All Stores"
        case favorites = "Favorites"
    }
    
    //MARK: - Segments
    let segments: [SegmentType] = [.allStores, .favorites]
    lazy var segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: segments.map({ $0.rawValue }))
        sc.layer.cornerRadius = 5
        sc.backgroundColor = .black
        sc.tintColor = .white
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(actionofSC), for: .valueChanged)
        return sc
    }()
    @objc func actionofSC() {
        let type = segments[segmentControl.selectedSegmentIndex]
        switch type {
        case .allStores:
            //            addSpinner()
            configureRefreshControlMain()
            getMainData()
            //            stopSpinner()
        case .favorites:
            self.configureRefreshControlFav()
            reCallApi()
        }
    }
    func reCallApi(){
        self.storesData.getFavDataFromFirebase { favData in
            self.addSpinner()
            print("favData in closure = \(favData)")
            self.storesData.businessDataFav = favData
            self.storesData.businesses.accept(self.storesData.businessDataFav.removingDuplicates())
            self.stopSpinner()
            favData.map { favData in
                print("favData.title = \(favData.title)")
            }
        }
    }
    func configureRefreshControlMain() {
        refreshControlMain.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlMain.addTarget(self, action: #selector(self.refreshMain(_:)), for: .valueChanged)
        tableView.addSubview(refreshControlMain) // not required when using UITableViewController
    }
    @objc func refreshMain(_ sender: AnyObject) {
        print("refreshmain working")
        getMainData()
        refreshControlMain.endRefreshing()
    }
    func configureRefreshControlFav() {
        refreshControlFavs.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControlFavs.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControlFavs) // not required when using UITableViewController
    }
    @objc func refresh(_ sender: AnyObject) {
        print("refresh working")
        reCallApi()
        refreshControlFavs.endRefreshing()
    }
    //MARK: - Get Favorites via core data - and main data
    func getMainData() {
        // Ask for Authorisation from the User.
        // For use in foreground
        var currentLocation: CLLocation!
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            currentLocation = locationManager.location
            StoresData.shared.lat = currentLocation.coordinate.latitude
            StoresData.shared.lon = currentLocation.coordinate.longitude
            YelpAPIManager.shared.getPlaceInfo(latitude: StoresData.shared.lat, longitude: StoresData.shared.lon) { dataFromRequest in
                self.storesData.businessDataMain = dataFromRequest
                DispatchQueue.main.async {
                    self.storesData.businesses.accept(self.storesData.businessDataMain)
                    self.delegate?.createAnnotations(mainData: self.storesData.businessDataMain)
                }
               
                //self.segmentControl.isUserInteractionEnabled = true
                
                // location manager location is cached
            }

        } else {
            print("authorization problem")
            
        }
    }
    func updateTableView() { // this works in delete button on StoresTabCell.swift where id of the selected store is removed from firebase.
        fadingLabelConfig(message: "Store Removed From Favorites", color: UIColor.gray, finalAlpha: 0.0)
        reCallApi()
    }
    func updateButton() {
        fadingLabelConfig(message: "Store Added To Favorites", color: UIColor.gray, finalAlpha: 0.0)
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
            fadingLabel.centerX.equalTo(self.view.snp.centerX)
            fadingLabel.centerY.equalTo(self.view.snp.centerY).offset(300)
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
        self.tableView.isHidden = true
    }
    func stopSpinner(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
            self.tableView.isHidden = false
        }
    }
    //MARK: - Constraints.
    func configureConstr() {
        self.title = "StoresFeed"
        self.tabBarItem.title = ""
        self.view.addSubview(tableView)
        self.view.addSubview(segmentControl)
        
//        tableView.backgroundColor = UIColor(red: 58/255, green: 67/255, blue: 86/255, alpha: 1.0) - 179, 178, 184
        tableView.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.delegate = self
        tableView.snp.makeConstraints { tableView in
            tableView.left.equalTo(view)
            tableView.right.equalTo(view)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
            tableView.top.equalTo(self.view.safeAreaLayoutGuide).offset(100)
        }
        segmentControl.snp.makeConstraints { sagmentedControl in
            sagmentedControl.left.equalTo(view).offset(10)
            sagmentedControl.right.equalTo(view).offset(-10)
            sagmentedControl.bottom.equalTo(self.tableView.snp.top).offset(-5)
            sagmentedControl.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(50)
        }
    }
    func configureNavBar() {
        self.view.backgroundColor = .white
        self.navigationItem.title = "Stores Near You"
        self.navigationController?.navigationBar.isTranslucent = true
    }
    //MARK: - RxSwift TableViewbind
    func bindTableViewMain() {
        storesData.businesses.asObservable()
            .bind(to: tableView
                    .rx
                    .items(cellIdentifier: storesFeedCellId, cellType: StoresTabCell.self)
            )
        {
            row, businessData, cell in
            cell.delegate = self
            cell.delegate2 = self
            cell.configureWithData(dataModel: businessData)
            
            if self.segmentControl.selectedSegmentIndex == 1 {
                cell.addFavButton.isHidden = true
                cell.deleteFromFavsButton.isHidden = false
                self.refreshControlMain.removeFromSuperview()
            } else if self.segmentControl.selectedSegmentIndex == 0 {
                self.refreshControlFavs.removeFromSuperview()
                cell.addFavButton.isHidden = false
                cell.deleteFromFavsButton.isHidden = true
            }
        }
        .disposed(by: disposeBag)
    }
    func selectedCell() {
        tableView.rx
            .modelSelected(StoresFeedModel.self)
            .subscribe(onNext:  { store in
                self.storesData.storeIDSelected = store.id
                print("store.lat = \(store.latitude)")
                print("store long = \(store.longitude)")
                print(".distance = \(store.distance)")
                let storeDeals = StoreDeals(storeDetail: store)
                self.navigationController?.pushViewController(storeDeals, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 10
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 10    //if you want round edges
        maskLayer.backgroundColor = UIColor.blue.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            print("didUpdateLocations")
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
            
            let alert = UIAlertController(title: "Please Authorize The App To Get Your Location", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings", style: .cancel, handler: { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
            }))
            self.present(alert, animated: true, completion: nil)
        case .notDetermined:
            manager.requestLocation()
          
            print("authorization not determined")
        case .authorizedAlways, .authorizedWhenInUse:
            // Do your thing here
            getMainData()
            print("authorized")
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




