import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Firebase
import FirebaseAuth
import CoreLocation

//This is where the middle button of tabBar will go to. The data from here will be collecton in DealsContentVC.
// try creating a protocol to notify DealsContentVC to trigger loadfromFirebase. simple instance of PostdealVC on DealsContent breaks the hierarchy probably and won't work.

class PostDealVC: UIViewController, UITextFieldDelegate, UITextViewDelegate { 
    override func viewDidLoad() {
        configureConstraints()
        print("PostDeal")
        textFieldTitle.delegate = self
        textFieldContent.delegate = self
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapGesture2)
        initialStoreSelection()
        disablePostButtonIfDocIdNil()
    }
    var disposeBag = DisposeBag()
    var storeTitle = String()
    var imagePath = String()
    var ref: DocumentReference? = nil
    var userDealRef: DocumentReference? = nil
    var spinner = SpinnerViewController()
    let storesFeed = StoresFeed()
    let dealDetail = DealDetail()
    var distance = Double()
    private let storage = Storage.storage()
    let db = Firestore.firestore()
    var dealsData = DealsData()
    var newData = StoresData()
    var stopTextFieldTitle = false
    var textContentBool = Bool()
    var dealImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    private var textFieldTitle: UITextField = {
        var txt = UITextField()
        txt.font = UIFont(name: "Optima-Bold", size: 13)
        txt.backgroundColor = .white
        txt.textColor = .black
        txt.placeholder = "Enter a Title"
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        txt.layer.borderColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        txt.layer.borderWidth = 4.0
        txt.textAlignment = .left
        txt.layer.masksToBounds = true
        txt.layer.cornerRadius = 5
        return txt
    }()
    private var textFieldContent: UITextView = {
        var txt = UITextView()
        txt.font = UIFont(name: "Optima-Bold", size: 13)
        txt.backgroundColor = .white
        txt.isEditable = true
        txt.textColor = .black
        txt.text = "About Deal"
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        txt.layer.borderColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        txt.layer.borderWidth = 2.0
        txt.layer.masksToBounds = true
        txt.layer.cornerRadius = 5
        return txt
    }()
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        textFieldTitle.layer.borderWidth = 4.0
        textFieldTitle.layer.borderColor = gray
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        makeTextFieldTitleBorderPale()
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return stopTextFieldTitle
    }
    func makeTextFieldTitleBorderPale() {
        let gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        textFieldTitle.layer.borderColor = gray
        textFieldTitle.layer.borderWidth = 2.0
    }
    func makeTextContentBorderThick(){
        let gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        textFieldContent.layer.borderWidth = 4.0
        textFieldContent.layer.borderColor = gray
    }
    func makeTextContentBorderPale(){
        let gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        textFieldContent.layer.borderWidth = 2.0
        textFieldContent.layer.borderColor = gray
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        stopTextFieldTitle = true
        makeTextContentBorderThick()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        makeTextContentBorderPale()
    }
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        return self.textLimit(existingText: textFieldContent.text,
                              newText: text,
                              limit: 300)
    }
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return self.textLimit(existingText: textFieldTitle.text,
                              newText: string,
                              limit: 100)
    }
    //MARK: - PostDealButton
    lazy var postDeal: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Post", for: .normal)
        bttn.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        bttn.addTarget(self, action: #selector(posttheDeal), for: .touchUpInside)
        return bttn
    }()
    @objc func posttheDeal(sender: UIButton){
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
        }
        print(ref?.documentID)
        print("dealsData.id = \(DealsData.shared.id)")
        print("storeTitle = \(DealsData.shared.storeTitle)")
        self.createDocument(storeID: DealsData.shared.id, storeTitle: DealsData.shared.storeTitle)
    }
    func disablePostButtonIfDocIdNil(){
        if ref?.documentID == nil || ref?.documentID.isEmpty == true {
            print("refdocumend id is nil or empty")
            self.postDeal.isEnabled = false
        } else {
            self.postDeal.isEnabled = true
        }
    }
    //MARK: - Functions to upload image, create document in Firebase and get downloadURL
    func initialStoreSelection(){
        let alert = UIAlertController(title: "Please Choose A Store First", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Stores Near You", style: .cancel, handler: { (action) in
            let modalStyle = UIModalTransitionStyle.crossDissolve
            self.storesFeed.getMainData()
            self.storesFeed.modalTransitionStyle = modalStyle
            self.present(self.storesFeed, animated: true, completion: nil)
            self.storesFeed.tableView.rx
                .modelSelected(StoresFeedModel.self)
                .subscribe(onNext:  { value in
                    print("value.id = \(value.id)")
                    DealsData.shared.id = value.id
                    DealsData.shared.storeTitle = value.title
                    DealsData.shared.distance = value.distance
                    DealsData.shared.lat = value.latitude
                    DealsData.shared.long = value.longitude
                    
                    self.distance = value.distance
                    if value.id.isEmpty == false {
                        self.postDeal.isEnabled = true
                    }
                                        
                    self.storesFeed.dismiss(animated: true, completion: nil)
                    let alert = UIAlertController(title: "Store Selected", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Continue Editing", style: .cancel, handler: { (action) in
                    }))
                    self.present(alert, animated: true, completion: nil)
                })
                .disposed(by: self.disposeBag)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func createDocument(storeID: String, storeTitle: String){
        addSpinner()
        let newDealDocID = UUID().uuidString
       
        let dealImageToUpload = self.dealImage.image
        guard let dealImageData = dealImageToUpload?.jpeg(.lowest) else {
            return
        }
        guard let newImageData = dealImageToUpload?.pngData() else {
            return
        }
//        let timestamp = NSDate().timeIntervalSince1970
//        let myTimeInterval = TimeInterval(timestamp)
//        let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))

        let dealImageRef = storage.reference().child("/deals/\(storeTitle)/\(newDealDocID)")
        let uploadTask = dealImageRef.putData(dealImageData, metadata: nil) { metadata, error in
            if error != nil {
                print("uploading image error = \(error)")
            } else {
                print("sucessfully uploaded image")
            }
        }
        let newStoreDocRef = self.db.collection("dealsCollection").document(storeID)
//        newStoreDocRef.setData(["Lat" : DealsData.shared.lat, "Long" : DealsData.shared.long]) { error in
//            if let err = error {
//                print("err = \(err)")
//            } else {
//                print("store document created with ID = \(newStoreDocRef.documentID)")
//            }
//        }
        callforDealCount(storeID: storeID) { dealCount in
            let data = ["Lat" : DealsData.shared.lat, "Long" : DealsData.shared.long, "DealCount" : dealCount, "Date" : Date().timeIntervalSince1970, "Store" : storeTitle] as [String : Any]
            newStoreDocRef.setData(data)
//            newStoreDocRef.setData(["DealCount" : FieldValue.increment(Int64(1))])
        }
        
        if let dealSender = Auth.auth().currentUser?.email, let senderUID = Auth.auth().currentUser?.uid {
            uploadTask.observe(.progress) { snapshot in
                print("snapshot.progress?.completedUnitCount = \(snapshot.progress?.completedUnitCount)")
            }
            uploadTask.observe(.success) { snapshot in
                self.ref = newStoreDocRef.collection("deals").document(newDealDocID)
                let dealData: [String : Any] = ["Sender" : dealSender,
                                                "StoreID": storeID,
                                                "StoreTitle" : storeTitle,
                                                "ImagePath" : "/deals/\(storeTitle)/\(newDealDocID)",
                                                "DealTitle" : self.textFieldTitle.text ?? "none",
                                                "DealDesc" : self.textFieldContent.text ?? "none",
                                                "DealID" : newDealDocID,
                                                "UserName" : Auth.auth().currentUser?.displayName ?? "A User",
                                                "Distance" : DealsData.shared.distance,
                                                "Lat" : DealsData.shared.lat,
                                                "Long" : DealsData.shared.long,
                                                "SenderUID" : senderUID]
                self.ref?.setData(dealData, completion: { error in
                    if let err = error {
                        print("error creating document = \(err)")
                        return
                    } else {
                        print("success: created document for deal. ")
                    }
                })
                self.stopSpinner()
                self.dealDetail.dealImage.image = self.dealImage.image
                self.dealDetail.labelTitle.text = self.textFieldTitle.text
                self.dealDetail.labelContent.text = self.textFieldContent.text
                self.dealDetail.storeTitle = storeTitle
                self.navigationController?.pushViewController(self.dealDetail, animated: true)
            }
        } else {
            print("check if let dealSender = Auth.auth().currentUser?.email")
            return
        }
    }
    func callforDealCount(storeID: String, completionHandler: @escaping (Int) -> Void) {
        let dealColRef = self.db.collection("dealsCollection").document(storeID).collection("deals")
        dealColRef.getDocuments() { querySnapShot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                print("querySnapShot?.documents.count \(querySnapShot?.documents.count)")
                DealsData.shared.dealCount = (querySnapShot?.documents.count)!
                completionHandler(DealsData.shared.dealCount)
            }
        }
    }
    
    func addSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    func stopSpinner(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
        }
    }
    //MARK: - ChooseStoreButton
    var chooseStore: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("ChooseStore", for: .normal)
        bttn.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        bttn.addTarget(self, action: #selector(goToChooseStore), for: .touchUpInside)
        return bttn
    }()
    @objc func goToChooseStore(){
        let modalStyle = UIModalTransitionStyle.crossDissolve
        storesFeed.modalTransitionStyle = modalStyle
        present(storesFeed, animated: true, completion: nil)
        storesFeed.tableView.rx
            .modelSelected(StoresFeedModel.self)
            .subscribe(onNext:  { value in
                DealsData.shared.id = value.id
                DealsData.shared.storeTitle = value.title
                print("DealsData.shared.id = \(DealsData.shared.id)")
                //                        let docReference = self.db.collection("storeIDsofDeals").document(self.ref!.documentID)
                //                        docReference.updateData(["StoreID" : value.id])
                self.storesFeed.dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Store Selected", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Continue Editing", style: .cancel, handler: { (action) in
                }))
                self.present(alert, animated: true, completion: nil)
            })
            .disposed(by: newData.disposeBag)
    }
    @objc func viewTapped(){
        makeTextFieldTitleBorderPale()
        makeTextContentBorderPale()
        stopTextFieldTitle = true
        textFieldTitle.resignFirstResponder()
        textFieldContent.resignFirstResponder()
    }
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    func configureConstraints(){
        self.title = "PostDeal"
        self.tabBarItem.title = ""
//        view.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        view.backgroundColor = .white
        view.addSubview(textFieldTitle)
        view.addSubview(textFieldContent)
        view.addSubview(dealImage)
        view.addSubview(postDeal)
        view.addSubview(chooseStore)
        dealImage.snp.makeConstraints { dealImage in
            dealImage.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            dealImage.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-400)
            dealImage.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            dealImage.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
        textFieldTitle.snp.makeConstraints { textFieldTitle in
            textFieldTitle.top.equalTo(dealImage.snp.bottom).offset(5)
            textFieldTitle.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-350)
            textFieldTitle.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            textFieldTitle.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
        textFieldContent.snp.makeConstraints { textFieldContent in
            textFieldContent.top.equalTo(textFieldTitle.snp.bottom).offset(5)
            textFieldContent.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200)
            textFieldContent.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            textFieldContent.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
        chooseStore.snp.makeConstraints { chooseStore in
            chooseStore.top.equalTo(textFieldContent.snp.bottom).offset(5)
            chooseStore.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-150)
            chooseStore.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            chooseStore.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
        postDeal.snp.makeConstraints { postDeal in
            postDeal.top.equalTo(chooseStore.snp.bottom).offset(5)
            postDeal.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
            postDeal.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            postDeal.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
    }
}
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object???s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UIImage {

    func decodedImage() -> UIImage {
        guard let cgImage = cgImage else { return self }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context?.makeImage() else { return self }
        return UIImage(cgImage: decodedImage)
    }
}
