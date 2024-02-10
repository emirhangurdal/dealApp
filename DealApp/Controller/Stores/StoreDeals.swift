import UIKit
import SnapKit
import RxCocoa
import RxSwift
import FirebaseAuth
import Firebase
import FirebaseFirestore
import CoreLocation
import MapKit

// the place user goes when they tap on a cell on the StoreSfeed.
class StoreDeals: UIViewController, UIScrollViewDelegate, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        mapView.delegate = self
        configureMapView()
        configureConstraints()
        configureTV()
        bindTV()
        dealSelected()
    }

    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    //MARK: - Properties
    let mapView = MKMapView()
    var currentLocation: CLLocation!
    let locationManager = CLLocationManager()

    let detailView = UIView()
    var strDeals = StrDeals()
    private let storage = Storage.storage()
    let db = Firestore.firestore()
    lazy var tableView = UITableView()
    var storeDetail = StoresFeedModel()
    
    var detailLabel: UILabel = {
        var lbl = UILabel()
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.backgroundColor = .white
        lbl.numberOfLines = 0
        return lbl
    }()
    var tableViewTitle: UILabel = {
        var lbl = UILabel()
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.backgroundColor = .white
        lbl.numberOfLines = 0
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        lbl.text = "Store's Deals".localized()
        return lbl
    }()
    let storeImage : UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = .clear
        return imgView
    }()
    var dealCellID = "DealCellID"
    private let disposeBag = DisposeBag()
    
    init(storeDetail: StoresFeedModel) {
        self.storeDetail = storeDetail
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    //MARK: - ConfigureMap
    
    func configureMapView() {
        mapView.register(customAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        let center = CLLocationCoordinate2D(latitude: storeDetail.latitude, longitude: storeDetail.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        createAnnotations()
    }
    func createAnnotations() {
        print("createAnnotations")
        self.mapView.annotations.forEach {
          if !($0 is MKUserLocation) {
            self.mapView.removeAnnotation($0)
          }
        }
        mapView.addAnnotation(Place(title: storeDetail.title, coordinate: CLLocationCoordinate2D(latitude: storeDetail.latitude, longitude: storeDetail.longitude), info: "Info", id: storeDetail.id, image: UIImage(data: storeDetail.image)!, address: storeDetail.address1))
    }
    
    //MARK: - Tableview Configure and Rx Bind and Firebase Data
    func configureTV(){
        tableView.register(DealTabCell.self, forCellReuseIdentifier: dealCellID)
        tableView.separatorStyle = .none
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        view.addSubview(tableViewTitle)
        tableView.snp.makeConstraints { tableView in
            tableView.top.equalTo(detailView.snp.bottom).offset(40)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
            tableView.right.equalTo(view.safeAreaLayoutGuide)
            tableView.left.equalTo(view.safeAreaLayoutGuide)
        }
        tableViewTitle.snp.makeConstraints { tableViewTitle in
            tableViewTitle.bottom.equalTo(tableView.snp.top)
            tableViewTitle.top.equalTo(detailView.snp.bottom)
            tableViewTitle.right.equalTo(view.safeAreaLayoutGuide).offset(-5)
            tableViewTitle.left.equalTo(view.safeAreaLayoutGuide).offset(5)
        }
    }
    func bindTV(){
        strDeals.strDealsRelay.asObservable()
            .bind(to: tableView
                    .rx
                    .items(cellIdentifier: dealCellID, cellType: DealTabCell.self)
            )
        {
            row, storeDealsData, cell in
            cell.configureStoreDeals(dataModel: storeDealsData)
            cell.deleteDealFromFirebase.isHidden = true
            cell.timerLabel.isHidden = true
            cell.sender.text = storeDealsData.userName
            cell.senderUID = storeDealsData.senderUID
            cell.block.isHidden = true
            cell.btnTapClosure = { [weak self] cell in
                // safely unwrap weak self and optional indexPath
                guard let self = self,
                      let indexPath = self.tableView.indexPath(for: cell)
                else { return }
                
                let activityItem: AnyObject = cell.dealImage.image!
                
                // present the share screen
                let objectsToShare = [activityItem]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
            
       
        }
        .disposed(by: disposeBag)
            fetchDataFireBase()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 5
        let maskLayer = CALayer()
           //if you want round edges
        maskLayer.backgroundColor = UIColor.blue.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
    func dealSelected(){
        let dealDetail = DealDetail()
        tableView.rx
            .modelSelected(DealModel.self)
            .subscribe(onNext:  { deal in
                dealDetail.dealImage.image = deal.dealImage
                dealDetail.labelTitle.text = deal.dealTitle
                dealDetail.labelContent.text = deal.dealDesc
                dealDetail.storeTitle = deal.storeTitle ?? ""
                dealDetail.seeAllDealsButton.isHidden = true
                dealDetail.labelMessage.isHidden = true
                self.navigationController?.pushViewController(dealDetail, animated: true)
            })
            .disposed(by: disposeBag)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    
    //MARK: - Retrieve Deals of the Store from Firebase
    func fetchDataFireBase(){
        let query = db.collection("dealsCollection").document(storeDetail.id).collection("deals").whereField("StoreID", isEqualTo: storeDetail.id)
        query.addSnapshotListener { querySnapShot, error in
            
            if let err = error {
                print("error storeDeals FB = \(err.localizedDescription)")
            } else {
                querySnapShot?.documentChanges.enumerated().forEach { indexD, documentChange in
                    print(documentChange.document.documentID)
                    if (documentChange.type == .added) {
                        let data = documentChange.document.data()
                        if let sender = data["Sender"] as? String,
//                           let image = data["ImagePath"] as? String,
                           let dealTitle = data["DealTitle"] as? String,
                           let dealDesc = data["DealDesc"] as? String,
                           let storeID = data["StoreID"] as? String,
                           let storeTitle = data["StoreTitle"] as? String,
                           let dealID = data["DealID"] as? String,
                           let userName = data["UserName"] as? String,
                           let distance = data["Distance"] as? Double,
                           let senderUID = data["SenderUID"] as? String,
                           let date = data["Date"] as? Double {
                            if ProfileDeals.shared.blockedUsersIDs.contains(where: {$0.id == senderUID}) == false {
                                if Date().timeIntervalSince1970 - date < 86400 {
                                    self.getDeals(dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, dealID: dealID, sender: sender, userName: userName, distance: distance, senderUID: senderUID, countDown: Int(Date().timeIntervalSince1970 - date))
                                }
                                
                                } else {
                                print("something wrong with if let in added.")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getDeals(dealTitle: String, dealDesc: String, storeTitle: String, storeID: String, dealID: String, sender: String, userName: String, distance: Double, senderUID: String, countDown: Int) {
        self.strDeals.strDeals.append(DealModel(storeID: storeID, dealImage: UIImage(named: "user-deal"), dealTitle: dealTitle, dealDesc: dealDesc, dealID: dealID, storeTitle: storeTitle, sender: sender, userName: userName, distance: distance, senderUID: senderUID, countDown: countDown))
        DispatchQueue.main.async {
            self.strDeals.strDealsRelay.accept(self.strDeals.strDeals)
        }
    }
    //MARK: - Old Function to get deals from Firebase
    func getImageFromURLfromFirebase(path: String, dealTitle: String, dealDesc: String, storeTitle: String, storeID: String, dealID: String, sender: String, userName: String, distance: Double, senderUID: String, countDown: Int) {
        print("getimagefromURL")
        let storageRef = storage.reference()
        let dealImageRef = storageRef.child(path)
        dealImageRef.downloadURL { url, error in
            guard error == nil else {
                print("error downloading image = \(error)")
                return
            }
            downloadImageWithURL(url: url!)
        }
        func downloadImageWithURL(url: URL) {
            let dealImageView = UIImageView()
            dealImageView.downloadImage(from: "\(url)") { response in
                print("downloadImageWithURL")
                self.strDeals.strDeals.append(DealModel(storeID: storeID, dealImage: response.image, dealTitle: dealTitle, dealDesc: dealDesc, dealID: dealID, storeTitle: storeTitle, sender: sender, userName: userName, distance: distance, senderUID: senderUID, countDown: countDown))
                DispatchQueue.main.async {
                    self.strDeals.strDealsRelay.accept(self.strDeals.strDeals)
                }
            }
        }
    }
    //MARK: - Ask for Direction
    func openMapsAppWithDirections(to coordinate: CLLocationCoordinate2D, destinationName name: String) {
      let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
      let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = name // Provide the name of the destination in the To: field
        mapItem.openInMaps(launchOptions: options)
    }
    
    //MARK: - Constraint and Content of Labels/Units.
    func addGestureToView(){
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(addressTapped))
        detailView.addGestureRecognizer(tapViewGesture)
    }
    @objc func addressTapped(){
        print("address Tapped")
        print("storeDetail.latitude = \(storeDetail.latitude)")
        print("storeDetail.latitude = \(storeDetail.longitude)")
        openMapsAppWithDirections(to: CLLocationCoordinate2D(latitude: storeDetail.latitude, longitude: storeDetail.longitude), destinationName: storeDetail.title)
    }
    func configureConstraints(){
        // configure content
//        storeImage.downloaded(from: storeDetail.image)
        addGestureToView()
        self.navigationItem.title = storeDetail.title
        
        detailLabel.attributedText = NSMutableAttributedString()
            .bold("\(storeDetail.title)\n")
            .normal("\(storeDetail.address1)\(storeDetail.address2)")
        
        //configure constraints.
        view.addSubview(detailView)
        view.addSubview(mapView)
        detailView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
//        detailView.addSubview(storeImage)
        detailView.addSubview(detailLabel)
        detailView.layer.masksToBounds = true
        
        detailView.snp.makeConstraints { detailView in
            detailView.top.equalTo(view.safeAreaLayoutGuide)
            detailView.bottom.equalTo(view.safeAreaLayoutGuide).offset(-350)
            detailView.right.equalTo(view.safeAreaLayoutGuide).offset(-2)
            detailView.left.equalTo(view.safeAreaLayoutGuide).offset(2)
        }
        mapView.snp.makeConstraints { mapView in
            mapView.top.equalTo(detailView)
            mapView.bottom.equalTo(detailView).offset(-50)
            mapView.left.equalTo(detailView)
            mapView.right.equalTo(detailView)
        }
        
        detailLabel.snp.makeConstraints { detailLabel in
            detailLabel.top.equalTo(mapView.snp.bottom).offset(5)
            detailLabel.bottom.equalTo(detailView)
            detailLabel.right.equalTo(detailView).offset(-2)
            detailLabel.left.equalTo(detailView).offset(2)
        }
    }
}
