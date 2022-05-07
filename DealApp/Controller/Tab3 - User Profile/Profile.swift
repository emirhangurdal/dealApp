import SnapKit
import Firebase
import FirebaseAuth
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import FirebaseFirestore

class Profile: UIViewController, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Profile Page")
        self.title = ""
        view.backgroundColor = .white
        configureConstraints()
        tableView.register(DealTabCell.self, forCellReuseIdentifier: dealCellID)
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        print("Auth.auth().currentUser?.email = \(Auth.auth().currentUser?.email)")
        fetchDataFB()
        bindTableView()
//        configRefreshControl()
    }
    private let refreshControl = UIRefreshControl()
    var spinner = SpinnerViewController()
    var storeArray = [String]()
    private let storage = Storage.storage()
    let db = Firestore.firestore()
    var dataProfile = ProfileDeals()
    private let disposeBag = DisposeBag()
    var dealCellID = "DealCellID"
    lazy var tableView = UITableView()
    var profilePic: UIImageView = {
        var img = UIImageView()
        img.image = UIImage(named: "profile")
        img.backgroundColor = .clear
        img.contentMode = .scaleAspectFit
        img.layer.borderWidth = 1
        img.layer.borderColor = UIColor.black.cgColor
        return img
    }()
    var userName: UILabel = {
        var lbl = UILabel()
        lbl.text = "muhtarSteelBallssdfsdşlk"
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        lbl.numberOfLines = 0
        return lbl
    }()
    var dealsPosted: UILabel = {
        var lbl = UILabel()
        lbl.attributedText = NSMutableAttributedString()
            .bold("200\n")
            .normal("Deals")
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.backgroundColor = .clear
        lbl.numberOfLines = 0
        return lbl
    }()
    var likes: UILabel = {
        var lbl = UILabel()
        lbl.attributedText = NSMutableAttributedString()
            .bold("1500\n")
            .normal("Likes")
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.backgroundColor = .clear
        lbl.numberOfLines = 0
        return lbl
    }()
    var latestPostsby: UILabel = {
        var lbl = UILabel()
        lbl.text = "Latest deals by user"
        return lbl
    }()
    var statView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    //MARK: - TableView and Rx Functions
    func bindTableView() {
        dataProfile.userDealsRelay.asObservable()
            .bind(to: tableView
                    .rx
                    .items(cellIdentifier: dealCellID, cellType: DealTabCell.self)
            )
        {
            row, profileData, cell in
            cell.storeID = profileData.storeID ?? ""
            cell.dealID = profileData.dealID ?? ""
            cell.storeTitle = profileData.storeTitle ?? ""
            cell.configureProfile(dataModel: profileData)
        }
        .disposed(by: disposeBag)
    }
    //MARK: - SPINNER
    func addSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
        self.tableView.isHidden = true
    }
    func stopSpinner(){
        DispatchQueue.main.async {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
            self.tableView.isHidden = false
        }
    }
    //MARK: - REFRESH CONTROL
    func configRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refreshMain(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refreshMain(_ sender: AnyObject) {
        print("refreshmain working")
        
        refreshControl.endRefreshing()
    }
    //MARK: - FIREBASE
    func fetchDataFB(){
        let senderEmail: String? = Auth.auth().currentUser?.email
        print(senderEmail!)
        let dealsCol = self.db.collection("dealsCollection")
        dealsCol.addSnapshotListener { querySnapShot, error in
            if let err = error {
                print("err = \(err)")
            } else {
                self.dataProfile.userDeals.removeAll()
                for document in querySnapShot!.documents {
                    print("store doc = \(document.documentID)")
                    let dealRef = dealsCol.document(document.documentID).collection("deals")
                    let query = dealRef.whereField("Sender", isEqualTo: senderEmail!)
                    query.addSnapshotListener { querySnapShot, error in
                        if let err = error {
                            print("error reading senderDeals = \(err)")
                        } else {
                            for document in querySnapShot!.documents {
                                let source = document.metadata.hasPendingWrites ? "Local" : "Server"
                              
                                let data = document.data()
                                if let sender = data["Sender"] as? String,
                                   let image = data["ImagePath"] as? String,
                                   let dealTitle = data["DealTitle"] as? String,
                                   let dealDesc = data["DealDesc"] as? String,
                                   let storeID = data["StoreID"] as? String,
                                   let storeTitle = data["StoreTitle"] as? String,
                                   let dealID = data["DealID"] as? String,
                                   let userName = data["UserName"] as? String {
                                    print("storeTitle = \(storeTitle)")
//                                    self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, dealID: dealID, sender: sender, userName: userName)
                                    
                                } else {
                                    print("something wrong with if let sender")
                                }
                            }
                        }
                        querySnapShot?.documentChanges.enumerated().forEach { indexDeal, diff in
                            self.addSpinner()
                            if (diff.type == .added) {
                                let data = diff.document.data()
                                if let sender = data["Sender"] as? String,
                                   let image = data["ImagePath"] as? String,
                                   let dealTitle = data["DealTitle"] as? String,
                                   let dealDesc = data["DealDesc"] as? String,
                                   let storeID = data["StoreID"] as? String,
                                   let storeTitle = data["StoreTitle"] as? String,
                                   let dealID = data["DealID"] as? String,
                                   let userName = data["UserName"] as? String,
                                   let distance = data["Distance"] as? Double {
                                    
                                    self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, dealID: dealID, sender: sender, userName: userName, distance: distance)
                                    
                                    self.stopSpinner()
                                } else {
                                    print("something wrong with if let in added. ")
                                }
                            }
                            if (diff.type == .modified) {
                                let data = diff.document.data()
                                print("snapshot.documentChanges.forEach")
                                if let sender = data["Sender"] as? String,
                                   let image = data["ImagePath"] as? String,
                                   let dealTitle = data["DealTitle"] as? String,
                                   let dealDesc = data["DealDesc"] as? String,
                                   let storeID = data["StoreID"] as? String,
                                   let storeTitle = data["StoreTitle"] as? String,
                                   let dealID = data["DealID"] as? String,
                                   let userName = data["UserName"] as? String {
                                    //  self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, dealID: dealID, sender: sender, userName: userName)
                                } else {
                                    print("something wrong with diff.type == .modified")
                                }
                            }
                            if (diff.type == .removed) {
                                self.addSpinner()
                                let data = diff.document.data()
                                print("if (diff.type == .removed)")
                                if let dealID = data["DealID"] as? String {
                                    self.dataProfile.userDeals.removeAll(where: {$0.dealID == dealID })
                                    
                                    print("Dealsdata after deleted deal = \(DealsData.shared.dealsArray)")
                                    DispatchQueue.main.async {
                                        self.dataProfile.userDealsRelay.accept(self.dataProfile.userDeals)
                                    }
                                    self.stopSpinner()
                                } else {
                                    print("something wrong with .removed")
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    func getImageFromURLfromFirebase(path: String, dealTitle: String, dealDesc: String, storeTitle: String, storeID: String, dealID: String, sender: String, userName: String, distance: Double){
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
                self.dataProfile.userDeals.append(DealModel(storeID: storeID, dealImage: response.image, dealTitle: dealTitle, dealDesc: dealDesc, dealID: dealID, storeTitle: storeTitle, sender: sender, userName: userName, distance: distance))
                print("self.dataProfile.userDeals = \(self.dataProfile.userDeals.count)")
                DispatchQueue.main.async {
                    self.dataProfile.userDealsRelay.accept(self.dataProfile.userDeals)
                }
            }
        }
    }
    //MARK: - Constraints
    func configureConstraints(){
        self.view.addSubview(profilePic)
        self.view.addSubview(userName)
        self.view.addSubview(statView)
        statView.addSubview(dealsPosted)
        statView.addSubview(latestPostsby)
        statView.addSubview(likes)
        self.view.addSubview(tableView)
        tableView.clipsToBounds = true
        tableView.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        profilePic.snp.makeConstraints { profilePic in
            profilePic.height.equalTo(100)
            profilePic.width.equalTo(100)
            profilePic.centerX.equalTo(view.snp.centerX)
            profilePic.centerY.equalTo(view.snp.centerY).offset(-300)
        }
        userName.snp.makeConstraints { userName in
            userName.height.equalTo(40)
            userName.width.equalTo(120)
            userName.centerX.equalTo(view)
            userName.top.equalTo(profilePic.snp.bottom).offset(5)
        }
        statView.snp.makeConstraints { statView in
            statView.right.equalTo(view.safeAreaLayoutGuide)
            statView.left.equalTo(view.safeAreaLayoutGuide)
            statView.bottom.equalTo(view.safeAreaLayoutGuide).offset(-500)
            statView.top.equalTo(userName.snp.bottom).offset(10)
        }
        dealsPosted.snp.makeConstraints { dealsPosted in
            dealsPosted.height.equalTo(55)
            dealsPosted.width.equalTo(85)
            dealsPosted.centerX.equalTo(statView).offset(150)
            dealsPosted.centerY.equalTo(statView)
        }
        likes.snp.makeConstraints { likes in
            likes.height.equalTo(55)
            likes.width.equalTo(85)
            likes.centerX.equalTo(statView).offset(100)
            likes.centerY.equalTo(statView)
        }
        latestPostsby.snp.makeConstraints { latestPostsby in
            latestPostsby.centerX.equalTo(statView).offset(-110)
            latestPostsby.centerY.equalTo(statView)
        }
        
        tableView.snp.makeConstraints { tableView in
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
            tableView.top.equalTo(statView.snp.bottom).offset(10)
            tableView.right.equalTo(view.safeAreaLayoutGuide)
            tableView.left.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
}
extension NSMutableAttributedString {
    var fontSize:CGFloat { return 14 }
    var boldFont:UIFont { return UIFont.boldSystemFont(ofSize: 18) }
    var normalFont:UIFont { return UIFont.systemFont(ofSize: 12) }
    
    func bold(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func blackHighlight(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
