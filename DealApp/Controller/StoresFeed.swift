// Programatiically created tableView.

import UIKit
import RxSwift
import SnapKit
import RxCocoa
import RxDataSources
import CoreLocation
import CoreData




class StoresFeed: UIViewController, UIScrollViewDelegate, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        configureNavBar()
        tableView.register(StoresTabCell.self, forCellReuseIdentifier: storesFeedCellId)
        configureConstr()
        tableView.backgroundColor = .gray
        bindTableViewMain()
        getMainData()
       
        subscribeTo()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    //MARK: - Properties
    static let shared = StoresFeed()
    lazy var tableView = UITableView()
    var locationManager = CLLocationManager()
    let storesFeedCellId = "StoresFeedCellID"
    private let disposeBag = DisposeBag()
    private let businesses: BehaviorRelay<[StoresFeedModel]> = BehaviorRelay(value: [])
//    private let businesses = PublishSubject<[StoresFeedModel]>()
    var businessDataMain = [StoresFeedModel]()
    var businessDataFav = [StoresFeedModel]()
    var selectedIndexPathRow = Int()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static var longtitude = Double()
    static var latitude = Double()
    let noValueImage = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/no%20value.jpg?alt=media&token=df6afb68-402f-4681-ad9b-5a30532376a1"
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
        getMainData()
   
        case .favorites:
        getFavDataforFavSegment()
          
        }
    }
//MARK: - Get Favorites via core data - and main data
    func getFavDataforFavSegment() {
        var fetchedIDs = [StoreIDs]()
        fetchStoreIdCoreData()
        for i in 0..<fetchedIDs.count {
            print(fetchedIDs[i].favoriteStoreID)
        }
        
        print(businessDataFav)
        
        func fetchStoreIdCoreData() {
            let request: NSFetchRequest<StoreIDs> = StoreIDs.fetchRequest()
            do {
                 fetchedIDs = try context.fetch(request).removingDuplicates()
                
            } catch {
                print("Error fetching data from CoreData \(error)")
            }
        }
    }
    func getMainData() {
        YelpAPIManager.shared.getPlaceInfo { dataFromRequest in
            self.businessDataMain = dataFromRequest
            self.businesses.accept(self.businessDataMain)
        }
    }
    func getValue(data: [StoresFeedModel]) {
    
        businesses.accept(data)
    }

//MARK: - Constraints.
    func configureConstr() {
        self.view.addSubview(tableView)
        self.view.addSubview(segmentControl)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.delegate = self
        tableView.snp.makeConstraints { tableView in
            tableView.left.equalTo(view)
            tableView.right.equalTo(view)
            tableView.bottom.equalTo(view)
            tableView.top.equalTo(self.view.safeAreaLayoutGuide).offset(100)
        }
        segmentControl.snp.makeConstraints { sagmentedControl in
            sagmentedControl.left.equalTo(view).offset(10)
            sagmentedControl.right.equalTo(view).offset(10)
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
        businesses.asObservable()
            .bind(to: tableView
                    .rx
                    .items(cellIdentifier: storesFeedCellId, cellType: StoresTabCell.self)
            )
        {
            row, businessData, cell in

            cell.configureWithData(dataModel: businessData)
        }
            .disposed(by: disposeBag)
    }

    func subscribeTo() {
        businesses.asObservable()
          .subscribe(onNext: {
            [weak self] businessData in
              
          }) .disposed(by: disposeBag) //3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    

//MARK: - Location
    func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        var currentLocation: CLLocation!

        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            currentLocation = locationManager.location
           
            print("location long: \(currentLocation.coordinate.longitude)")
            print("location lat: \(currentLocation.coordinate.latitude)")
            
            if currentLocation.coordinate.longitude != nil, currentLocation.coordinate.latitude != nil {
                StoresFeed.longtitude = currentLocation.coordinate.longitude // these params might change and it should be responsive in network side, too.
                StoresFeed.latitude = currentLocation.coordinate.latitude
            }
        }
    }
    }

