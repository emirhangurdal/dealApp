import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Firebase
import FirebaseAuth
import CoreLocation
//where all the deals are collected in a tableview feed. Tableview is sectioned.
class DealsContentVC: UIViewController, UIScrollViewDelegate, UITableViewDelegate, StoresFeedDelegate2, CreateAlert, PushProfilePage, BlockUser {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraints()
        
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.register(DealTabCell.self, forCellReuseIdentifier: dealCellID)
        tableView.register(MyCustomHeader.self,
                           forHeaderFooterViewReuseIdentifier: "sectionHeader")
        setupDataSource()
        callDataBase()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTapped), name: NSNotification.Name(rawValue: "refreshHere"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(askToRefresh), name: NSNotification.Name(rawValue: "askToRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshEnabled), name: NSNotification.Name(rawValue: "enableRefresh"), object: nil)
        print("displayname ? \(Auth.auth().currentUser?.displayName)")
    }
    override func viewWillAppear(_ animated: Bool) {
        labelfade()
        AppUtility.lockOrientation(.portrait)
        checkLocAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }
    }
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData> (
        configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "DealCellID", for: indexPath) as! DealTabCell
            return cell
        }
    )
    var joker = [SectionOfCustomData]()
    let locale = Locale.current
    var sectionIndex = Int()
    var storeTitles = [StoreIDandTitle]()
    var newData = StoresData()
    var distanceToStore = Double()
    var indexPath = Int()
    let g = DispatchGroup()
    private let storage = Storage.storage()
    let db = Firestore.firestore()
    var spinner = SpinnerViewController()
    var tableView = UITableView()
    let gotoAllDealsView = UIView()
    private let disposeBag = DisposeBag()
    var dealCellID = "DealCellID"
    var senderUID = String()
    var deals = DealsData()
    let storageRef = Storage.storage().reference()
    let dealsString = "Deals @".localized()
    let userName = Auth.auth().currentUser?.displayName
    private var gotoAllDeals: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Tap Here for Brand Deals".localized(), for: .normal)
        bttn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        //        bttn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        bttn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        bttn.backgroundColor = UIColor(red: 82/255, green: 150/255, blue: 213/255, alpha: 1.0)
        bttn.layer.cornerRadius = 5
        bttn.addTarget(self, action: #selector(continueWithoutSigning), for: .touchUpInside)
        return bttn
    }()
    @objc func continueWithoutSigning() {
        print("continueWithoutSignUp")
        if #available(iOS 13, *) {
            let allDeals = AllDealsVC()
            self.navigationController?.pushViewController(allDeals, animated: true)
        }
        
    }

    
    //MARK: - Table View
    func setupDataSource(){
        dataSource.configureCell = { (_, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "DealCellID", for: indexPath) as! DealTabCell
            cell.configureWithData(dataModel: item)
            cell.delegate = self
            cell.delegate3 = self
            cell.delegate4 = self
            cell.dealID = item.dealID ?? "No deal ID found, empty or nil"
            cell.storeID = item.storeID ?? "No Store ID found, empty or nil"
            cell.storeTitle = item.storeTitle ?? "No Store Title"
            cell.userName = item.userName ?? ""
            cell.sender.text = "@\(item.userName ?? "A User")"
            cell.senderUID = item.senderUID ?? ""
            cell.seconds = item.countDown ?? 0
            cell.storeLabel.text = item.storeTitle ?? ""
            cell.emailSender = item.sender ?? ""
            
            if cell.storeTitle == "Affiliate" {
                cell.block.isHidden = true
                cell.like.isHidden = true
                cell.sender.isHidden = true
                cell.block.isHidden = true
                cell.timerLabel.isHidden = true
            } else {
                cell.block.isHidden = false
                cell.like.isHidden = false
                cell.sender.isHidden = false
                cell.block.isHidden = false
                cell.timerLabel.isHidden = false
            }
            
//            if cell.senderUID == Auth.auth().currentUser?.uid {
//                cell.block.isHidden = true
//            }
            if cell.emailSender == Auth.auth().currentUser?.email  {
                cell.block.isHidden = true
            } else if cell.senderUID == Auth.auth().currentUser?.uid {
                cell.block.isHidden = true
            }
            
            // Share Button:
            
            cell.btnTapClosure = { [weak self] cell in
                // safely unwrap weak self and optional indexPath
                guard let self = self,
                      let indexPath = tableView.indexPath(for: cell)
                else { return }
                
                let activityItem: AnyObject = cell.dealImage.image!
                
                // present the share screen
                let objectsToShare = [activityItem]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
            return cell
        }
        // title
        dataSource.titleForHeaderInSection = { ds, section in
            return "\(self.dealsString) \(ds.sectionModels[section].header)"
        }
        DealsData.shared.dealsData.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        tableView.rx
            .modelSelected(DealModel.self)
            .subscribe(onNext:  { deal in
              
                let dealDetail = DealDetail()
                dealDetail.dealImage.image = deal.dealImage
                dealDetail.labelTitle.text = deal.dealTitle
                dealDetail.labelContent.text = deal.dealDesc
                dealDetail.labelMessage.isHidden = true
                dealDetail.storeTitle = deal.storeTitle ?? ""
                dealDetail.seeAllDealsButton.isHidden = true
                
                self.navigationController?.pushViewController(dealDetail, animated: true)
            })
            .disposed(by: disposeBag)
        //                tableView.rx
        //                           .itemSelected
        //                           .map { indexPath in
        //                               return (indexPath, self.dataSource[indexPath])
        //                           }
        //                           .subscribe(onNext: { pair in
        //                           })
        //                           .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                                                                "sectionHeader") as! MyCustomHeader
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return 60
    }
    func header(header: String){
        tableView.rx.delegate.methodInvoked(#selector(tableView.delegate?.tableView(_:willDisplayHeaderView:forSection:)))
                    .take(until: tableView.rx.deallocated)
                    .subscribe(onNext: { event in
                        guard let headerView = event[1] as? MyCustomHeader else { return }
                        for view in headerView.subviews {
                            view.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
                        }
                        headerView.title.text = header
                        headerView.title.textColor = .white
                    })
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 5
        let maskLayer = CALayer()
//      maskLayer.cornerRadius = 10
        //if you want round edges
        maskLayer.backgroundColor = UIColor.blue.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    
    //MARK: - Constraints
    func configureConstraints(){
        self.tabBarItem.title = ""
        view.addSubview(tableView)
        view.addSubview(gotoAllDealsView)
        gotoAllDealsView.addSubview(gotoAllDeals)
        
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        tableView.clipsToBounds = true
        tableView.bounces = true
        
        tableView.separatorStyle = .none
        
        tableView.snp.makeConstraints { tableView in
            tableView.right.equalTo(view.safeAreaLayoutGuide)
            tableView.left.equalTo(view.safeAreaLayoutGuide)
            tableView.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide).offset(-1)
        }
        
        gotoAllDealsView.snp.makeConstraints { gotoAllDealsView in
            gotoAllDealsView.top.equalTo(view.safeAreaLayoutGuide)
            gotoAllDealsView.bottom.equalTo(tableView.snp.top)
            gotoAllDealsView.right.equalTo(view.safeAreaLayoutGuide)
            gotoAllDealsView.left.equalTo(view.safeAreaLayoutGuide)
        }
        gotoAllDeals.snp.makeConstraints { gotoAllDeals in
            gotoAllDeals.top.equalTo(gotoAllDealsView).offset(2)
            gotoAllDeals.bottom.equalTo(gotoAllDealsView).offset(-2)
            gotoAllDeals.left.equalTo(gotoAllDealsView).offset(2)
            gotoAllDeals.right.equalTo(gotoAllDealsView).offset(-2)
        }
        configureNavBar()
    }
    let refreshButtonItem = UIButton(type: .custom)
    //MARK: - Pull Refresh
    @objc func askToRefresh(){
        print("asktoRefresh")
        let alert = UIAlertController(title: "Congrats!".localized(), message: "Your deal has been posted.".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { [weak self] action in
            guard let self = self else {return}
            self.navigationItem.leftBarButtonItem?.customView?.isUserInteractionEnabled = true
            self.navigationItem.leftBarButtonItem?.customView?.isHidden = false
            self.callDataBase()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func configureNavBar(){
        self.navigationController?.navigationBar.backgroundColor = C.shared.navColor
        self.navigationItem.title = "Deals in last 24 hr".localized()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.navigationBar.isTranslucent = true

        let buttonWidth = CGFloat(30)
        let buttonHeight = CGFloat(30)
        
        refreshButtonItem.setImage(UIImage(named: "icons8-reset-100"), for: .normal)
        refreshButtonItem.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        refreshButtonItem.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        refreshButtonItem.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: refreshButtonItem)
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
    
    @objc func refreshTapped() {
        print("refresh tapped")
        callDataBase()
        self.navigationItem.leftBarButtonItem?.customView?.isUserInteractionEnabled = false
    }
    
    @objc func refreshEnabled() {
        self.navigationItem.leftBarButtonItem?.customView?.isUserInteractionEnabled = true
    }
    
    //MARK: profile page initialization
    func pushProfilePage(vc: UIViewController) {
        print("push profile page protocol")
        vc.modalPresentationStyle = .popover
        self.present(vc, animated: true, completion: nil)
    }
    //MARK: - Data From Firebase
    func getStoreTitles(mainData: [StoresFeedModel]) {
        //        let query = dealRef.whereField("Sender", isEqualTo: senderEmail!)
        
        storeTitles.removeAll()
        mainData.map { data in
            storeTitles.append(StoreIDandTitle(title: data.title, id: data.id, lat: data.latitude, lon: data.longitude))
        }
    }

    func callDataBase(){
        DealsData.shared.dealsArray.removeAll()
        let colRef = db.collection("dealsCollection")
        
        storeTitles.enumerated().forEach { index, sectionData in
            DealsData.shared.dealsArray.append(SectionOfCustomData(header: sectionData.title, date: 0.0, items: [DealModel(storeID: "", dealImage: UIImage(named: "no-image"), dealTitle: "None", dealDesc: "", dealID: "", storeTitle: "", sender: "", userName: "", distance: 0.0, senderUID: "", countDown: 0)]))
            addSpinner()
            let query = colRef.document(sectionData.id).collection("deals").whereField("StoreTitle", isEqualTo: sectionData.title)
            query.getDocuments { [unowned self] querySnapShot, error in
               
                if let err = error {
                    print("err calling query = \(err.localizedDescription)")
                    return
                } else {
                    print("calling")
                    
                    DealsData.shared.dealsArray[index].items.removeAll(where: {$0.dealTitle == "None"})
                    
                    if querySnapShot?.documents.count == 0 {
                        DealsData.shared.dealsArray[index].items.removeAll()
                        DispatchQueue.main.async {
                            DealsData.shared.dealsData.accept(DealsData.shared.dealsArray)
                        }
                    }
                    
                    querySnapShot?.documents.enumerated().forEach { indexS, document in
                        let data = document.data()
                        if let sender = data["Sender"] as? String,
                           let image = data["ImagePath"] as? String,
                           let dealTitle = data["DealTitle"] as? String,
                           let dealDesc = data["DealDesc"] as? String,
                           let storeID = data["StoreID"] as? String,
                           let storeTitle = data["StoreTitle"] as? String,
                           let dealID = data["DealID"] as? String,
                           let userName = data["UserName"] as? String,
                           let distance = data["Distance"] as? Double,
                           let senderUID = data["SenderUID"] as? String,
                           let date = data["Date"] as? Double {
                            let x = date + 86400
                            let difference = Int(x - (Date().timeIntervalSince1970))
                            
                            if ProfileDeals.shared.blockedUsersIDs.contains(where: {$0.id == senderUID}) == false {
                                if Date().timeIntervalSince1970 - date < 86400 {
                                    self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, section: index, dealID: dealID, sender: sender, userName: userName, distance: distance, senderUID: senderUID, date: date, countDown: difference)
                                }
                            }
                            
                        } else {
                            return
                        }
                    }
            
                }
            }
        }
        
        // try loading extra deals here if the locale.regioncode == US
        getMyDeals()
    }
    //MARK: - Data for
    
    func getMyDeals() {
        print("getMyDeals")
        print("locale.regionCode = \(locale.regionCode)")
        let regionCode = locale.regionCode
        let colRef = db.collection("myDeals")
        if regionCode == "US" {
            let myDealsRef = colRef.document("4UpHSbMBDFz05uO36U0z").collection("deals")
            myDealsRef.getDocuments { [weak self] querySnap, error in
                guard let strongSelf = self else {return}
                if let error = error {
                    print("error getting myDeals = \(error.localizedDescription)")
                    return
                } else {
                    querySnap?.documents.enumerated().forEach { indexS, document in
                        print("query works")
                         let data = document.data()
                        if let sender = data["Sender"] as? String,
                           let image = data["ImagePath"] as? String,
                           let dealTitle = data["DealTitle"] as? String,
                           let dealDesc = data["DealDesc"] as? String,
                           let storeID = data["StoreID"] as? String,
                           let storeTitle = data["StoreTitle"] as? String,
                           let dealID = data["DealID"] as? String,
                           let userName = data["UserName"] as? String,
                           let senderUID = data["SenderUID"] as? String,
                           let date = data["Date"] as? Double,
                            let brand = data["Brand"] as? String {
                            print("Date().timeIntervalSince1970 = \(Date().timeIntervalSince1970)")
                            strongSelf.getImageFromStorage(path: image) { [weak self] image in
                                guard let self = self else {return}
                                
                                print("deal Image = \(image)")
                                DealsData.shared.dealsArray.append(SectionOfCustomData(header: brand, date: date,
                                                                                       items: [DealModel(storeID: storeID,
                                                                                                         dealImage: image,
                                                                                                         dealTitle: dealTitle,
                                                                                                         dealDesc: dealDesc,
                                                                                                         dealID: dealID,
                                                                                                         storeTitle: storeTitle,
                                                                                                         sender: sender,
                                                                                                         userName: userName,
                                                                                                         distance: 0.0,
                                                                                                         senderUID: senderUID,
                                                                                                         countDown: 0)]))
                                print("myDealsData = \(DealsData.shared.dealsArray)")
                                let sorted = DealsData.shared.dealsArray.enumerated().sorted(by: {$0.element.date > $1.element.date})
                                self.joker.removeAll()
                                
                                sorted.map({
                                    self.joker.append($0.element)
                                    DispatchQueue.main.async {
                                        DealsData.shared.dealsData.accept(self.joker)
                                        self.stopSpinner()
                                    }
                                })
                            }
                           
                        } else {
                            print("something wrong with data")
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Get Images from FireBase
    
    func getImageFromStorage(path: String, completionHandler: @escaping (UIImage) -> Void) {
        let dealImageView = UIImageView()
        let dealImageRef = storageRef.child(path)
        dealImageRef.downloadURL { url, error in
            guard error == nil else {
                print("error downloading image = \(error?.localizedDescription)")
                return
            }
            dealImageView.downloadImage(from: "\(url!)") { response in
                DispatchQueue.main.async {
                    dealImageView.image = response.image ?? UIImage(named: "no-image")
                    guard dealImageView.image != nil else {return}
                    completionHandler(dealImageView.image!)
                }
            }
        }
    }

    
    func getImageFromURLfromFirebase(path: String, dealTitle: String, dealDesc: String, storeTitle: String, storeID: String, section: Int, dealID: String, sender: String, userName: String, distance: Double, senderUID: String, date: Double, countDown: Int) {
        
        let dealImageRef = storageRef.child(path)
//        self.addSpinner()
        
        dealImageRef.downloadURL { url, error in
            guard error == nil else {
                print("error downloading image = \(error?.localizedDescription)")
                return
            }
            downloadImageWithURL(url: url!)
        }
        func downloadImageWithURL(url: URL) {
            let dealImageView = UIImageView()
            dealImageView.downloadImage(from: "\(url)") { response in
                
                DealsData.shared.dealsArray[section].date = date
                DealsData.shared.dealsArray[section].items.append(DealModel(storeID: storeID, dealImage: response.image ?? UIImage(named: "no-image"), dealTitle: dealTitle, dealDesc: dealDesc, dealID: dealID, storeTitle: storeTitle, sender: sender, userName: userName, distance: distance, senderUID: senderUID, countDown: countDown))
                
                let sorted = DealsData.shared.dealsArray.enumerated().sorted(by: {$0.element.date > $1.element.date})
                
                self.joker.removeAll()
                sorted.map({
                    self.joker.append($0.element)
                    DispatchQueue.main.async {
                        
                        DealsData.shared.dealsData.accept(self.joker)
                        self.stopSpinner()
                    }
                })
            }
        }
    }
    
    //MARK: Delete Deal
    func deleteDealAlert(data: forDelete) {
        self.navigationItem.leftBarButtonItem?.customView?.isHidden = true
        let subColRef = self.db.collection("dealsCollection").document(data.storeID).collection("deals")
        let dealImageRef = self.storage.reference().child("/deals/\(data.storeTitle)/\(data.dealID)")
        let storeRef = self.db.collection("dealsCollection").document(data.storeID)
        let alert = UIAlertController(title: "Delete This Deal?".localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .default, handler: { action in
            guard Auth.auth().currentUser != nil else {return}
            // delete the document from firestore database
            subColRef.document(data.dealID).delete() { [weak self] err in
                guard let strongSelf = self else {return}
                if let err = err {
                    print("Error removing document: \(err)")
                    return
                } else {
                    // delete the image file from storage
                    dealImageRef.delete { error in
                        if let error = error {
                            return
                        } else {
                            print("file deleted successfully")
                            strongSelf.callDataBase()
                            strongSelf.navigationItem.leftBarButtonItem?.customView?.isHidden = false
                        }
                    }
                    print("Deal Document successfully removed!")
                }
            }
            // delete deal count field from the documents of stores. it is useless.
            storeRef.updateData(["DealCount" : FieldValue.increment(Int64(-1))])

        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
            print("cancelled")
            self.navigationItem.leftBarButtonItem?.customView?.isHidden = false
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: Block User
    func blockUser(user: BlockedData) {
        
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        let colRef = db.collection("favStoreCollection").document(userUID).collection("blockedUserIDs")
   
        if ProfileDeals.shared.blockedUsersIDs.contains(where: {$0.id == user.id}) == false {
            let blockedUserID = ["ID" : user.id, "UserName" : user.name]
            colRef.addDocument(data: blockedUserID)
            ProfileDeals.shared.blockedUsersIDs.append(BlockedData(id: user.id, name: user.name))
            print("ProfileDeals.shared.blockedUsersIDs = \(ProfileDeals.shared.blockedUsersIDs)")
        } else {
            // to delete the user from database:
            
//            let filteredIDs = ProfileDeals.shared.blockedUsersIDs.filter { ID in
//                ID != ID
//            }
//
//            let query = colRef.whereField("ID", isEqualTo: ID)
//            query.getDocuments { querySnapShot, error in
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                } else {
//                    querySnapShot?.documents.enumerated().forEach { index, document in
//                        if document.exists == true {
//                            document.reference.delete { error in
//                                if let error = error {
//                                    print(error.localizedDescription)
//                                    return
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//
//            ProfileDeals.shared.blockedUsersIDs = filteredIDs
//            print("filteredIDs \(filteredIDs)")
        }
        callDataBase()
    }
    
    //MARK: - Fading Message

    func labelfade() { // this works in delete button on StoresTabCell.swift where id of the selected store is removed from firebase.
        fadingLabelConfig(message: "Refresh This When You Change Category".localized(), color: UIColor.black, finalAlpha: 0.0)
    }
    func updateButton() {
        fadingLabelConfig(message: "Store Added To Favorites".localized(), color: UIColor.gray, finalAlpha: 0.0)
    }
    func fadingLabelConfig(message: String, color: UIColor, finalAlpha: CGFloat){
        var fadingLabel: UILabel!
        fadingLabel = UILabel()
        
        view.addSubview(fadingLabel)
        fadingLabel.isHidden = true
        fadingLabel.snp.makeConstraints { fadingLabel in
            fadingLabel.height.equalTo(80)
            fadingLabel.width.equalTo(view.safeAreaLayoutGuide)
            fadingLabel.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            fadingLabel.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
        }
        fadeMessage()
        func fadeMessage() {
            fadingLabel.text          = message
            fadingLabel.textColor     = .white
            fadingLabel.alpha         = 0.8
            fadingLabel.isHidden      = false
            fadingLabel.textAlignment = .center
            fadingLabel.backgroundColor     = color
            fadingLabel.layer.cornerRadius  = 5
            fadingLabel.layer.masksToBounds = true
            fadingLabel.font = UIFont.systemFont(ofSize: 15)
            UIView.animate(withDuration: 5.0, animations: { () -> Void in
                fadingLabel.alpha = finalAlpha
            })
        }
    }
    
    
    
    //MARK: -  Spinner
    func addSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
        self.navigationItem.leftBarButtonItem?.customView?.isHidden = true
        self.tableView.isHidden = true
    }
    func stopSpinner(){
        DispatchQueue.main.async {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
            self.tableView.isHidden = false
            self.navigationItem.leftBarButtonItem?.customView?.isHidden = false
        }
    }
    //MARK: - Do When Locatin is Disabled
    
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
}
//MARK: - Download Image with Completion Handler using URL String
extension UIImageView {
    func downloadImage(from URLString: String, with completion: @escaping (_ response: (status: Bool, image: UIImage? ) ) -> Void) {
        guard let url = URL(string: URLString) else {
            completion((status: false, image: nil))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion((status: false, image: nil))
                return
            }
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let data = data else {
                      completion((status: false, image: nil))
                      return
                  }
            let image = UIImage(data: data)
            completion((status: true, image: image))
        }.resume()
    }
}

// MARK: - This is useful to duplicate a struct object from model if it contains duplicate id or title or whatever.
extension Array {
    func unique(selector:(Element,Element)->Bool) -> Array<Element> {
        return reduce(Array<Element>()){
            if let last = $0.last {
                return selector(last,$1) ? $0 : $0 + [$1]
            } else {
                return [$1]
            }
        }
    }
}



