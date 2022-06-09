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
        self.title = "Profile"
        view.backgroundColor = .white
        configureConstraints()
        tableView.register(DealTabCell.self, forCellReuseIdentifier: dealCellID)
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        print("Auth.auth().currentUser?.UID = \(Auth.auth().currentUser?.uid)")
        bindTableView()
        getDataFireBase()
        configRefreshControl()
        getLikes()
        downloadProfileImage()
    }
    
    var likes = Int()
    private let storage = Storage.storage()
    let profilePicPhotoHelper = ProfilePicPhotoHelper()
    private let refreshControl = UIRefreshControl()
    var dealNumber = Int()
    var spinner = SpinnerViewController()
    var storeArray = [StoresFeedModel]()
    let db = Firestore.firestore()
    var dataProfile = ProfileDeals()
    private let disposeBag = DisposeBag()
    var dealCellID = "DealCellID"
    lazy var tableView = UITableView()
    var stores = [String]()
    lazy var gestureButton: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("", for: .normal)
        bttn.backgroundColor = .clear
        bttn.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        return bttn
    }()
    lazy var profilePic: UIImageView = {
        var img = UIImageView()
        img.backgroundColor = .clear
        img.contentMode = .scaleAspectFill
//        img.layer.borderWidth = 1
//        img.layer.borderColor = UIColor.black.cgColor
        img.isUserInteractionEnabled = true
        return img
    }()
    var userName: UILabel = {
        var lbl = UILabel()
        lbl.text = ""
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        lbl.numberOfLines = 0
        return lbl
    }()
    var dealsPosted: UILabel = {
        var lbl = UILabel()
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.backgroundColor = .clear
        lbl.numberOfLines = 0
        return lbl
    }()
    var likesLabel: UILabel = {
        var lbl = UILabel()
        lbl.attributedText = NSMutableAttributedString()
            .bold("0\n")
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
    
    //MARK: - Image Gesture - Change Profile Image
    @objc func profileImageTapped(){
        print("profile image tapped")
        profilePicPhotoHelper.presentActionSheet(from: self)
    }
    func downloadProfileImage(){
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        let dealImageRef = storage.reference().child("/ProfilePics/\(userUID)/profilepic")
        dealImageRef.downloadURL { url, error in
            guard error == nil else {
                print("error downloading image = \(error)")
                return
            }
            print("url for downloading image = \(url)")
            self.profilePic.downloadImage(from: "\(url!)") { response in
                DispatchQueue.main.async {
                    self.profilePic.image = response.image
                }
            }
        }
    }

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
            cell.senderUID = profileData.senderUID
            
        }
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - FIREBASE
  
    func getLikes(){
        guard let uid: String? = Auth.auth().currentUser?.uid else {
            return
        }
        guard let usrName: String? = Auth.auth().currentUser?.displayName else {
            return
        }
        userName.text = usrName
        let docRef = db.collection("favStoreCollection").document(uid!)
        docRef.addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let lkes = data?["Likes"] as? Int {
                    self.likesLabel.attributedText = NSMutableAttributedString()
                        .bold("\(lkes)\n")
                        .normal("Likes")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    func getDataFireBase() {
        guard let senderEmail: String? = Auth.auth().currentUser?.email else {
            return
        }
        db.collectionGroup("deals").whereField("Sender", isEqualTo: senderEmail!).addSnapshotListener { (snapshot, error) in
            guard error == nil else {
                print("error?.localizedDescription collectiongroup = \(error?.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.dealsPosted.attributedText = NSMutableAttributedString()
                    .bold("\(self.dealNumber)\n")
                    .normal("Deals")
            }
            self.dealNumber = snapshot?.documents.count ?? 0
            for document in snapshot!.documents {
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
                   let senderUID = data["SenderUID"] as? String {
                    self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, dealID: dealID, sender: sender, userName: userName, distance: distance, senderUID: senderUID)
                    DispatchQueue.main.async {
                        self.stopSpinner()
                    }
                } else {
                    print("zonk")
                }
            }
            snapshot?.documentChanges.enumerated().forEach { indexD, documentChange in
                if (documentChange.type == .removed) {
                    let data = documentChange.document.data()
                    if let dealID = data["DealID"] as? String {
                        self.dataProfile.userDeals.removeAll(where: {$0.dealID == dealID})
                        DispatchQueue.main.async {
                            self.dataProfile.userDealsRelay.accept(self.dataProfile.userDeals.removingDuplicates())
                        }
                    }
                }
            }
            
        }
    }
    
    func getImageFromURLfromFirebase(path: String, dealTitle: String, dealDesc: String, storeTitle: String, storeID: String, dealID: String, sender: String, userName: String, distance: Double, senderUID: String){
        print("getimagefromURL")
        self.dataProfile.userDeals.removeAll()
        let storageRef = storage.reference()
        let dealImageRef = storageRef.child(path)
        dealImageRef.downloadURL { url, error in
            guard error == nil else {
                print("error downloading image = \(error?.localizedDescription)")
                return
            }
            downloadImageWithURL(url: url!)
        }
        func downloadImageWithURL(url: URL) {
            let dealImageView = UIImageView()
            addSpinner()
            dealImageView.downloadImage(from: "\(url)") { response in
                print("downloadImageWithURL")
                self.dataProfile.userDeals.append(DealModel(storeID: storeID, dealImage: response.image, dealTitle: dealTitle, dealDesc: dealDesc, dealID: dealID, storeTitle: storeTitle, sender: sender, userName: userName, distance: distance, senderUID: senderUID))
                print("self.dataProfile.userDeals = \(self.dataProfile.userDeals.count)")
                DispatchQueue.main.async {
                    self.dataProfile.userDealsRelay.accept(self.dataProfile.userDeals.removingDuplicates())
                    self.stopSpinner()
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
        statView.addSubview(likesLabel)
        self.view.addSubview(tableView)
        profilePic.addSubview(gestureButton)
        profilePic.bringSubviewToFront(gestureButton)
        tableView.clipsToBounds = true
        tableView.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 0.5)
        profilePic.snp.makeConstraints { profilePic in
            profilePic.height.equalTo(100)
            profilePic.width.equalTo(100)
            profilePic.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            profilePic.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY).offset(-250)
        }
        gestureButton.snp.makeConstraints { gestureButton in
            gestureButton.height.equalTo(profilePic)
            gestureButton.width.equalTo(profilePic)
        }
        userName.snp.makeConstraints { userName in
            userName.height.equalTo(40)
            userName.width.equalTo(120)
            userName.centerX.equalTo(view.safeAreaLayoutGuide)
            userName.top.equalTo(profilePic.snp.bottom).offset(5)
        }
        statView.snp.makeConstraints { statView in
            statView.right.equalTo(view.safeAreaLayoutGuide)
            statView.left.equalTo(view.safeAreaLayoutGuide)
            statView.bottom.equalTo(view.safeAreaLayoutGuide).offset(-420)
            statView.top.equalTo(userName.snp.bottom).offset(10)
        }
        dealsPosted.snp.makeConstraints { dealsPosted in
            dealsPosted.height.equalTo(55)
            dealsPosted.width.equalTo(85)
            dealsPosted.centerX.equalTo(statView).offset(150)
            dealsPosted.centerY.equalTo(statView).offset(-10)
        }
        likesLabel.snp.makeConstraints { likes in
            likes.height.equalTo(55)
            likes.width.equalTo(85)
            likes.centerX.equalTo(statView).offset(100)
            likes.centerY.equalTo(statView).offset(-10)
        }
        latestPostsby.snp.makeConstraints { latestPostsby in
            latestPostsby.centerX.equalTo(statView).offset(-110)
            latestPostsby.centerY.equalTo(statView).offset(-5)
        }
        tableView.snp.makeConstraints { tableView in
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
            tableView.top.equalTo(statView.snp.bottom).offset(10)
            tableView.right.equalTo(view.safeAreaLayoutGuide)
            tableView.left.equalTo(view.safeAreaLayoutGuide)
        }
        configureNavBar()
    }
    func configureNavBar(){
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
        self.navigationItem.title = "Profile"
        self.navigationController?.navigationBar.isTranslucent = true
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
            // Customizing our navigation bar
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
