import SnapKit
import Firebase
import FirebaseAuth
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import FirebaseFirestore
import Photos
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import KeychainSwift
import Security

enum AuthProviders: String {
    case password
    case facebook = "facebook.com"
    case google = "google.com"
    case apple = "apple.com"
}

class Profile: UIViewController, UITableViewDelegate, CreateAlert, UITextViewDelegate, PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("photo library did change")
        if #available(iOS 14, *) {
            DispatchQueue.main.async {
                self.profilePicPhotoHelper.allowAccessToPhotos(viewcontroller: self)
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self)
        
        print("ProfileViewDidLoad")
        configureConstraints()
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        tableView.register(DealTabCell.self, forCellReuseIdentifier: dealCellID)
        print("Auth.auth().currentUser?.UID = \(Auth.auth().currentUser?.uid)")
        bindTableView()
        getDataFireBase()
        getLikes(userID: senderUID)
        getUserNameOnce(userUID: senderUID)
        downloadProfileImage(senderUID: senderUID)
        addGestureToView()
        removeGesture()
        NotificationCenter.default.addObserver(self, selector: #selector(logOutTapped), name: NSNotification.Name(rawValue: "LogOut"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    override func viewDidDisappear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self, name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        } else {
            // Fallback on earlier versions
        }
    }

    init(senderUID: String) {
        self.senderUID = senderUID
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    //MARK: - Properties
    let keychain = KeychainSwift()
    var senderUID = String()
    var likes = Int()
    let deals = ProfileDeals()
    private let storage = Storage.storage()
    let profilePicPhotoHelper = ProfilePicPhotoHelper()
    private let refreshControl = UIRefreshControl()
    var dealNumber = Int()
    var spinner = SpinnerViewController()
    var storeArray = [StoresFeedModel]()
    let db = Firestore.firestore()
    lazy var logOut = UIBarButtonItem(title: "Log Out".localized(), style: .plain, target: self, action: #selector(logOutTapped))
    
    private var disposeBag = DisposeBag()
    var dealCellID = "DealCellID"
    var tableView = UITableView()
    lazy var gestureButton: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("", for: .normal)
        bttn.backgroundColor = .clear
        bttn.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        return bttn
    }()
    lazy var settings: UIButton = {
        var bttn = UIButton()
        bttn.setImage(UIImage(named: "icons8-settings-50"), for: .normal)
        bttn.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        return bttn
    }()
    lazy var profilePic: CircularImageView = {
        var img = CircularImageView()
        img.backgroundColor = .clear
        img.contentMode = .scaleAspectFill
        img.isUserInteractionEnabled = true
        return img
    }()
    var userName: UILabel = {
        var lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 13)
        lbl.numberOfLines = 0
        lbl.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0)
        lbl.textColor = C.shared.statViewColor
        lbl.layer.cornerRadius = 5
        lbl.layer.masksToBounds = true
        lbl.textAlignment = .center
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
            .normal("Likes".localized())
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.backgroundColor = .clear
        lbl.numberOfLines = 0
        return lbl
    }()
    var latestPostsby: UILabel = {
        var lbl = UILabel()
        lbl.text = "User's Deals".localized()
        return lbl
    }()
    private var statView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var buttonView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    
    
    private var profilePicView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var profileView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var separatorForAbout: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var separator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()

    
 
    //MARK: - Log Out Tapped
    @objc func logOutTapped(){
        let signUp = SignUp()
        let navController = UINavigationController(rootViewController: signUp)
        guard let window = self.view.window else {
            return
        }
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stopTimer"), object: nil, userInfo: nil)
        if #available(iOS 13.0, *) {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(navController)
            
            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil, completion: nil)
          
            //            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil, completion: nil)
        } else {
            // Fallback on earlier versions
            //            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            UIApplication.shared.windows.first?.rootViewController = navController
            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        do {
            try Auth.auth().signOut()
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    var endEditing = false
    var devlin = Bool()
    func addGestureToView(){
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        statView.addGestureRecognizer(tapViewGesture)
        profilePicView.addGestureRecognizer(tapViewGesture)
        tableView.keyboardDismissMode = .onDrag
        let tapViewGesture2 = UITapGestureRecognizer(target: self, action: #selector(userNameTapped))
        userName.addGestureRecognizer(tapViewGesture2)
        userName.isUserInteractionEnabled = true
    }
    @objc func viewTapped(){
        print("viewTapped")
        
    }
    
    func removeGesture(){
        if devlin == true {
            userName.isUserInteractionEnabled = false
        } else {
            userName.isUserInteractionEnabled = true
        }
    }
    
    //MARK: - profile image part:
    @objc func profileImageTapped(){
        print("profile image tapped")
        profilePicPhotoHelper.presentActionSheet(from: self)
    }
    
    func downloadProfileImage(senderUID: String){
        let dealImageRef = storage.reference().child("/ProfilePics/\(senderUID)/profilepic")
        dealImageRef.downloadURL { url, error in
            guard error == nil else {
               
                DispatchQueue.main.async {
                    self.profilePic.image = UIImage(named: "profilePlaceHolder")
                }
                return
            }
            
            self.profilePic.downloadImage(from: "\(url!)") { response in
                guard response.image != nil else {return}
                DispatchQueue.main.async {
                    self.profilePic.image = response.image
                }
            }
        }
    }
    //MARK: - UserName
    func getUserNameOnce(userUID: String) {
        
        let favDealsDocRef = self.db.collection("favStoreCollection").document(userUID)
        favDealsDocRef.getDocument { document, error in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                let data = document.data()
                
                if let displayName = data?["UserName"] as? String {
                    print(displayName)
                    self.userName.text = displayName
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func changeUserName(text: String, userUID: String){
        
        let doc = self.db.collection("favStoreCollection").document(userUID)
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        
        changeRequest?.displayName = text
//        guard let displayName = Auth.auth().currentUser?.displayName else {return}
        changeRequest?.commitChanges(completion: { error in
            if let error = error {
                print("error changing display name = \(error.localizedDescription)")
                return
            } else {
//                print("changeRequest?.displayName = \(changeRequest?.displayName)")
                print("et de brutes")
                let newName = changeRequest?.displayName ?? ""
                doc.updateData(["UserName" : newName])
            }
        })
    }
    var textFieldUserName = UITextField()
    var textFieldPassword = UITextField()

    //MARK: - Settings
    
    @objc func settingsTapped(){
        let settings = Settings()
        self.navigationController?.pushViewController(settings, animated: true)
    }
    
    //MARK: UserName Tapped
    
    @objc func userNameTapped(){
  
        let alert = UIAlertController(title: "Edit Profile".localized(), message: "", preferredStyle: .alert)
        
        //MARK: - Blocked Users
        
        alert.addAction(UIAlertAction(title: "Blocked Users".localized(), style: .default, handler: { [weak self] action in
            guard let strongSelf = self else {return}
            let blockedUsers = BlockedUsers()
            self?.navigationController?.pushViewController(blockedUsers, animated: true)
        }))
        //MARK: - Reset Password
        
        let alertPasswordEmail = UIAlertController(title: "Check Your Email".localized(), message: "Password Reset Email Has Been Sent".localized(), preferredStyle: .alert)
        alertPasswordEmail.addAction(UIAlertAction(title: "Done".localized(), style: .default, handler: { action in
            print("Done")
        }))
        //alertwarning
        let alertWarning = UIAlertController(title: "Do You Wanna Change Your Password?".localized(), message: "", preferredStyle: .alert)
        alertWarning.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { action in
            // handle password reset email request:
            guard let userEmail = Auth.auth().currentUser?.email else {return}
            Auth.auth().sendPasswordReset(withEmail: userEmail) { error in
                if let error = error {
                    let warning = UIAlertController(title: "An Error Occured".localized(), message: "Try Again Later".localized(), preferredStyle: .alert)
                    warning.addAction(UIAlertAction(title: "Ok".localized(), style: .cancel, handler: { action in
                        print("cancelled")
                    }))
                    self.present(warning, animated: true, completion: nil)
                    return
                } else {
                    self.present(alertPasswordEmail, animated: true, completion: nil)
                }
            }
        }))
        alertWarning.addAction(UIAlertAction(title: "No".localized(), style: .cancel, handler: { action in
            
        }))
        alert.addTextField { textField2 in
            textField2.placeholder = "Your Username".localized()
            self.textFieldUserName = textField2
        }
        //MARK: Change User Name Action
        
        alert.addAction(UIAlertAction(title: "Change User Name".localized(), style: .default, handler: { (action) in
            guard let userUID = Auth.auth().currentUser?.uid else {return}
            self.userName.text = self.textFieldUserName.text!
            guard let userDisplayName = Auth.auth().currentUser?.displayName else{return}
            self.changeUserName(text: self.textFieldUserName.text!, userUID: userUID)
            self.queryForDisplayNameChange(displayName: userDisplayName, newUserName: self.userName.text!)
        }))
        
        //MARK: Change Password Alert
        
        if let providerId = Auth.auth().currentUser?.providerData.first?.providerID,
           let provider = AuthProviders(rawValue: providerId) {
            switch provider {
            case .password:
                alert.addAction(UIAlertAction(title: "Change Password".localized(), style: .default, handler: { action in
                    print("change password")
                    self.present(alertWarning, animated: true, completion: nil)
                }))
            case .facebook:
                print("facebook")
            case .google:
                print("google")
            case .apple:
                print("apple")
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func queryForDisplayNameChange(displayName: String, newUserName: String) {
        let query = self.db.collectionGroup("deals").whereField("UserName", isEqualTo: displayName)
        
        query.getDocuments { querySnapShot, error in
            if let error = error {
                print("error.localizedDescription in query = \(error.localizedDescription)")
                return
            } else {
                for document in querySnapShot!.documents {
                    document.reference.updateData(["UserName" : newUserName])
                }
                self.callDataChangedUserName()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshHere"), object: nil, userInfo: nil)
            }
        }
    }
    
    func callDataChangedUserName() {
        guard let senderEmail: String? = Auth.auth().currentUser?.email else {return}
        deals.userDeals.removeAll()
        db.collectionGroup("deals").whereField("Sender", isEqualTo: senderEmail!).getDocuments { querySnapShot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                querySnapShot?.documentChanges.enumerated().forEach { indexD, documentChange in
                    if documentChange.type == .added {
                        let data = documentChange.document.data()
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
                            if Date().timeIntervalSince1970 - date < 86400 {
                                self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, dealID: dealID, sender: sender, userName: userName, distance: distance, senderUID: senderUID, countDown: difference)
                                
                            } else {
                                // maybe delete the older deals here.
                            }
                        } else {
                            
                        }
                    }
                }
            }
        }
    }
    //MARK: - TableView and Rx Functions
    func bindTableView() {
        deals.userDealsRelay.asObservable()
            .bind(to: tableView
                    .rx
                    .items(cellIdentifier: dealCellID, cellType: DealTabCell.self)
            )
        {
            row, profileData, cell in
            cell.block.isHidden = true
            cell.storeID = profileData.storeID ?? ""
            cell.dealID = profileData.dealID ?? ""
            cell.storeTitle = profileData.storeTitle ?? ""
            cell.configureProfile(dataModel: profileData)
            cell.senderUID = profileData.senderUID
            cell.delegate2 = self
            cell.sender.text = profileData.userName
            cell.timerLabel.isHidden = true
            cell.storeLabel.text = profileData.storeTitle
            
            cell.btnTapClosure = { [weak self] cell in
                // safely unwrap weak self and optional indexPath
                guard let self = self,
                      let indexPath = self.tableView.indexPath(for: cell)
                else { return }
                
                // get the url from our data source
                let urlString = "https://apple.com"
                let activityItem: AnyObject = cell.dealImage.image!
                
                guard let url = URL(string: urlString) else {
                    // could not get a valid URL from the string
                    return
                }
                // present the share screen
                let objectsToShare = [activityItem]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        }
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
    //MARK: - FIREBASE deal data
    
    func getLikes(userID: String){
        let docRef = db.collection("favStoreCollection").document(userID)
        docRef.addSnapshotListener { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let lkes = data?["Likes"] as? Int {
                    self.likesLabel.attributedText = NSMutableAttributedString()
                        .bold("\(lkes)\n")
                        .normal("Likes".localized())
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
                print("error?.localizedDescription collectiongroup = \(error?.localizedDescription ?? "")")
                return
            }
            self.dealNumber = snapshot?.documents.count ?? 0
            DispatchQueue.main.async {
                self.dealsPosted.attributedText = NSMutableAttributedString()
                    .bold("\(self.dealNumber)\n")
                    .normal("Deals".localized())
            }
            snapshot?.documentChanges.enumerated().forEach { indexD, documentChange in
                if documentChange.type == .added {
                    let data = documentChange.document.data()
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
                        
                        if Date().timeIntervalSince1970 - date < 86400 {
                            print("golden brown")
                            self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, dealID: dealID, sender: sender, userName: userName, distance: distance, senderUID: senderUID, countDown: difference)
                        } else {
                            // maybe delete the older deals here.
                        }
                    }
                }
                
                if (documentChange.type == .removed) {
                    let data = documentChange.document.data()
                    if let dealID = data["DealID"] as? String {
                        self.deals.userDeals.removeAll(where: {$0.dealID == dealID})
                        DispatchQueue.main.async {
                            self.deals.userDealsRelay.accept(self.deals.userDeals.removingDuplicates())
                        }
                    }
                }
            }
        }
    }
    //MARK: - Delete a Deal for Profile
    func deleteDealAlert(data: forDelete) {
        let subColRef = self.db.collection("dealsCollection").document(data.storeID).collection("deals")
        let dealImageRef = self.storage.reference().child("/deals/\(data.storeTitle)/\(data.dealID)")
        let storeRef = self.db.collection("dealsCollection").document(data.storeID)
        
        let alert = UIAlertController(title: "Delete This Deal?".localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .default, handler: { (action) in
            guard Auth.auth().currentUser != nil else {return}
            // delete the document from firestore database
            subColRef.document(data.dealID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                    return
                } else {
                    // delete the image file from storage
                    dealImageRef.delete { error in
                        if let error = error {
                            print(error)
                            return
                        } else {
                            print("file deleted successfully")
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
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getImageFromURLfromFirebase(path: String, dealTitle: String, dealDesc: String, storeTitle: String, storeID: String, dealID: String, sender: String, userName: String, distance: Double, senderUID: String, countDown: Int) {
        print("getimagefromURL in Profile Page")
        
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
            
            dealImageView.downloadImage(from: "\(url)") { response in
                print("downloadImageWithURL")
                self.deals.userDeals.append(DealModel(storeID: storeID, dealImage: response.image, dealTitle: dealTitle, dealDesc: dealDesc, dealID: dealID, storeTitle: storeTitle, sender: sender, userName: userName, distance: distance, senderUID: senderUID, countDown: countDown))
                
                DispatchQueue.main.async {
                    self.deals.userDealsRelay.accept(self.deals.userDeals.removingDuplicates())
                }
            }
        }
    }
    //MARK: - Constraints
    func configureConstraints(){
        dealsPosted.textColor = .white
        likesLabel.textColor = .white
        latestPostsby.textColor = .white
        view.backgroundColor = .white
        // self.view
        view.addSubview(statView)
        view.addSubview(tableView)
        view.addSubview(profileView)
        profileView.addSubview(profilePicView)
        profileView.addSubview(buttonView)
        buttonView.addSubview(separatorForAbout)
        profileView.addSubview(separator)
        profilePicView.addSubview(profilePic)
        profileView.addSubview(userName)
        profileView.addSubview(settings)
        statView.addSubview(dealsPosted)
        statView.addSubview(latestPostsby)
        statView.addSubview(likesLabel)
        profilePic.addSubview(gestureButton)
        profilePic.bringSubviewToFront(gestureButton)
        // profileView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        // profile view
        separator.snp.makeConstraints { separator in
            separator.width.equalTo(1)
            separator.height.equalTo(1)
            separator.centerX.equalTo(profileView)
            separator.centerY.equalTo(profileView)
        }
        profileView.snp.makeConstraints { profileView in
            profileView.top.equalTo(view.safeAreaLayoutGuide)
            profileView.bottom.equalTo(view.safeAreaLayoutGuide.snp.centerY)
            profileView.right.equalTo(view.safeAreaLayoutGuide)
            profileView.left.equalTo(view.safeAreaLayoutGuide)
        }
        //        profilePicView.backgroundColor = .gray
        profilePicView.snp.makeConstraints { profilePicView in
            profilePicView.top.equalTo(profileView)
            profilePicView.bottom.equalTo(separator)
            profilePicView.left.equalTo(profileView)
            profilePicView.right.equalTo(profileView)
        }
        buttonView.snp.makeConstraints { buttonView in
            buttonView.top.equalTo(separator)
            buttonView.bottom.equalTo(profileView)
            buttonView.right.equalTo(profileView)
            buttonView.left.equalTo(profileView)
        }
        separatorForAbout.snp.makeConstraints { separatorForAbout in
            separatorForAbout.width.equalTo(1)
            separatorForAbout.height.equalTo(1)
            separatorForAbout.centerX.equalTo(buttonView)
            separatorForAbout.centerY.equalTo(buttonView)
        }
        profilePic.snp.makeConstraints { profilePic in
            profilePic.width.equalTo(125)
            profilePic.height.equalTo(125)
            profilePic.centerX.equalTo(profilePicView)
            profilePic.centerY.equalTo(profilePicView)
        }
        gestureButton.snp.makeConstraints { gestureButton in
            gestureButton.height.equalTo(profilePic)
            gestureButton.width.equalTo(profilePic)
        }
        userName.snp.makeConstraints { userName in
            userName.width.equalTo(125)
            userName.height.equalTo(25)
            userName.top.equalTo(buttonView)
            userName.centerX.equalTo(buttonView)
        }
        settings.snp.makeConstraints { settings in
            settings.width.equalTo(25)
            settings.height.equalTo(25)
            settings.top.equalTo(buttonView)
            settings.left.equalTo(userName.snp.right).offset(5)
        }
        //statview
        statView.backgroundColor = C.shared.statViewColor
        statView.snp.makeConstraints { statView in
            statView.top.equalTo(userName.snp.bottom).offset(5)
            statView.centerX.equalTo(buttonView)
            statView.right.equalTo(buttonView)
            statView.left.equalTo(buttonView)
        }
        
        dealsPosted.snp.makeConstraints { dealsPosted in
            dealsPosted.top.equalTo(statView).offset(2)
            dealsPosted.bottom.equalTo(statView).offset(-2)
            dealsPosted.centerX.equalTo(statView)
        }
        latestPostsby.snp.makeConstraints { latestPostsby in
            latestPostsby.top.equalTo(statView).offset(2)
            latestPostsby.bottom.equalTo(statView).offset(-2)
            latestPostsby.left.equalTo(statView).offset(2)
            latestPostsby.right.equalTo(dealsPosted.snp.left)
        }
        likesLabel.snp.makeConstraints { likesLabel in
            likesLabel.top.equalTo(statView).offset(2)
            likesLabel.bottom.equalTo(statView).offset(-2)
            likesLabel.left.equalTo(dealsPosted.snp.right)
            likesLabel.right.equalTo(statView).offset(-120)
        }
        tableView.snp.makeConstraints { tableView in
            tableView.top.equalTo(statView.snp.bottom)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
            tableView.right.equalTo(view.safeAreaLayoutGuide)
            tableView.left.equalTo(view.safeAreaLayoutGuide)
        }
        configureNavBar()
    }
    func configureNavBar(){
        self.navigationController?.navigationBar.backgroundColor = C.shared.navColor
        self.navigationItem.title = "Profile".localized()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
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
        self.navigationItem.rightBarButtonItem = logOut
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

class CircularImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
}
