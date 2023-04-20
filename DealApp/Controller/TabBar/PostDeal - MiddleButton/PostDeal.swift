import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Firebase
import FirebaseAuth
import CoreLocation
import Photos


class PostDealVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, PushPostDeal, PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("photoLibraryDidChange")
        if #available(iOS 14, *) {
            DispatchQueue.main.async {
                self.photoHelper.allowAccessToPhotos(viewcontroller: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraints()
        textFieldTitle.delegate = self
        textFieldContent.delegate = self
        addGestureToView()
        addGestureToImage()
        photoHelper.delegate = self
        askStoreIfAuthorized()
        checkBlock()
    
        NotificationCenter.default.addObserver(self, selector: #selector(enablePost), name: NSNotification.Name(rawValue: "enablePostButton"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    
    func askStoreIfAuthorized(){
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            postDeal.isHidden = false
            chooseStore.isHidden = false
        } else {
            postDeal.isHidden = true
            chooseStore.isHidden = true
        }
    }

    func addGestureToView(){
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapViewGesture)
    }
    func addGestureToImage(){
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        dealImage.addGestureRecognizer(tapViewGesture)
    }
    
    //MARK: - Properties
    var blockCheck = Bool()
        
    let dealsData = DealsData()
    private let disposeBag = DisposeBag()
    var storeTitle = String()
    let photoHelper = MGPhotoHelper()
    var imagePath = String()
    var ref: DocumentReference? = nil
    var userDealRef: DocumentReference? = nil
    var spinner = SpinnerViewController()
    var distance = Double()
    private let storage = Storage.storage()
    let db = Firestore.firestore()
    var newData = StoresData()
    var stopTextFieldTitle = false
    var textContentBool = Bool()
    var dealImage: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "upload-icon-1024")
        return img
    }()
    private lazy var textFieldTitle: UITextField = {
        var txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 13)
        txt.backgroundColor = .white
        txt.textColor = .black
        txt.placeholder = "Write a Title".localized()
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        txt.layer.borderColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        txt.layer.borderWidth = 4.0
        txt.textAlignment = .left
        txt.layer.masksToBounds = true
        txt.layer.cornerRadius = 5
        return txt
    }()
    private lazy var textFieldContent: UITextView = {
        var txt = UITextView()
        txt.font = UIFont.systemFont(ofSize: 13)
        txt.backgroundColor = .white
        txt.isEditable = true
        txt.textColor = .black
        txt.text = "Deal Description".localized()
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        txt.layer.borderColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        txt.layer.borderWidth = 2.0
        txt.layer.masksToBounds = true
        txt.layer.cornerRadius = 5
        return txt
    }()
    lazy var cancel: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Cancel".localized(), for: .normal)
        bttn.backgroundColor = UIColor(red: 82/255, green: 150/255, blue: 213/255, alpha: 1.0)
        bttn.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        bttn.layer.cornerRadius = 5
        return bttn
    }()
    lazy var postDeal: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Post".localized(), for: .normal)
        bttn.backgroundColor = UIColor(red: 82/255, green: 150/255, blue: 213/255, alpha: 1.0)
        bttn.addTarget(self, action: #selector(posttheDeal), for: .touchUpInside)
        bttn.layer.cornerRadius = 5
        return bttn
    }()
    var chooseStore: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Choose Store".localized(), for: .normal)
        bttn.backgroundColor = UIColor(red: 82/255, green: 150/255, blue: 213/255, alpha: 1.0)
        bttn.addTarget(self, action: #selector(goToChooseStore), for: .touchUpInside)
        bttn.layer.cornerRadius = 5
        return bttn
    }()
    //MARK: - TextField Title Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        textFieldTitle.layer.borderWidth = 3.0
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
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return self.textLimit(existingText: textFieldTitle.text,
                              newText: string,
                              limit: 100)
    }
    
    //MARK: - Make thick and thin, and limit word number
    func makeTextContentBorderThick(){
        let gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        textFieldContent.layer.borderWidth = 3.0
        textFieldContent.layer.borderColor = gray
    }
    func makeTextContentBorderPale(){
        let gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0).cgColor
        textFieldContent.layer.borderWidth = 2.0
        textFieldContent.layer.borderColor = gray
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
    //MARK: - TextView Content Methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        view.frame.origin.y = view.frame.origin.y - 200
        stopTextFieldTitle = true
        textFieldTitle.layer.borderWidth = 2.0
        print("textViewDidBeginEditing")
        makeTextContentBorderThick()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        view.frame.origin.y = 0
        makeTextContentBorderPale()
    }
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        return self.textLimit(existingText: textFieldContent.text,
                              newText: text,
                              limit: 300)
    }
 

//MARK: - Post deal, cancel , choose store button methods
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func posttheDeal(sender: UIButton){
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
        }
        self.createDocument(storeID: DealsData.shared.id ?? "", storeTitle: DealsData.shared.storeTitle ?? "")
    }
    @objc func enablePost(){
        if DealsData.shared.id != nil, DealsData.shared.storeTitle != nil {
            postDeal.isEnabled = true
        }
    }
    
    @objc func goToChooseStore(){
        let mapChoose = MapChooseVC()
        present(mapChoose, animated: true, completion: nil)
    }
        
    //MARK: - Create Document in Firebase
    func checkBlock() {
        let id = Auth.auth().currentUser?.uid
        guard id != nil else {return}

        let docRef = db.collection("favStoreCollection").document(id ?? "")

        docRef.getDocument { [weak self] document, error in
            guard let self = self else {return}
            
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                let data = document.data()
                
                if let blockCount = data?["BlockCounter"] as? Int {
                    if blockCount >= 10 {
                        self.blockCheck = true
                        self.postDeal.isHidden = true
                        
                        self.dealImage.isUserInteractionEnabled = false
                        self.dealImage.image = UIImage(named: "account-suspended")
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func createDocument(storeID: String, storeTitle: String){
        addSpinner()
        let newDealDocID = UUID().uuidString
        let dealImageToUpload = self.dealImage.image?.resizeWithPercent(percentage: 0.50)
        let dealImageData = dealImageToUpload!.jpeg(.low)
        
        // Upload the image:
         
        let dealImageRef = storage.reference().child("/deals/\(storeTitle)/\(newDealDocID)")
        let uploadTask = dealImageRef.putData(dealImageData!, metadata: nil) { metadata, error in
            if error != nil {
                print("uploading image error = \(error)")
            } else {
                print("sucessfully uploaded image")
            }
        }
        
        // Write deal count and store info:
        let newStoreDocRef = self.db.collection("dealsCollection").document(storeID)
        
        callforDealCount(storeID: storeID) { dealCount in

            let data = ["Lat" : DealsData.shared.lat, "Long" : DealsData.shared.long, "DealCount" : dealCount, "Date" : Date().timeIntervalSince1970, "Store" : storeTitle] as [String : Any]
            newStoreDocRef.setData(data)
        }
        uploadTask.observe(.progress) { snapshot in
            print("snapshot.progress?.completedUnitCount = \(snapshot.progress?.completedUnitCount)")
        }
        
        // Create deal document:
        ref = newStoreDocRef.collection("deals").document(newDealDocID)
        if let dealSender = Auth.auth().currentUser?.email, let senderUID = Auth.auth().currentUser?.uid {
            uploadTask.observe(.success) { [weak self] snapshot in
                guard let strongSelf = self else {return}
                
                let dealData: [String : Any] = ["Sender" : dealSender,
                                                "StoreID": storeID,
                                                "StoreTitle" : storeTitle,
                                                "ImagePath" : "/deals/\(storeTitle)/\(newDealDocID)",
                                                "DealTitle" : strongSelf.textFieldTitle.text ?? "none",
                                                "DealDesc" : strongSelf.textFieldContent.text ?? "none",
                                                "DealID" : newDealDocID,
                                                "UserName" : Auth.auth().currentUser?.displayName ?? "A User",
                                                "Distance" : DealsData.shared.distance,
                                                "Lat" : DealsData.shared.lat,
                                                "Long" : DealsData.shared.long,
                                                "SenderUID" : senderUID,
                                                "Date": Date().timeIntervalSince1970]
                
                strongSelf.ref?.setData(dealData, completion: { error in
                    if let err = error {
                        print("error creating document = \(err)")
                        return
                    } else {
                      
                        print("success: created document for deal. ")
                    }
                })
                strongSelf.stopSpinner()
                let dealDetail = DealDetail()
                weak var pvc = strongSelf.presentingViewController
                
                strongSelf.dismiss(animated: true) {
                    dealDetail.dealImage.image = strongSelf.dealImage.image
                    dealDetail.labelTitle.text = strongSelf.textFieldTitle.text
                    dealDetail.labelContent.text = strongSelf.textFieldContent.text
                    dealDetail.storeTitle = storeTitle
                    pvc?.present(dealDetail, animated: true, completion: nil)
                }
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
  //MARK: - Spinners
    func addSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        chooseStore.isHidden = true
        postDeal.isHidden = true
        cancel.isHidden = true
        spinner.didMove(toParent: self)
    }
    func stopSpinner(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
            self.chooseStore.isHidden = false
            self.postDeal.isHidden = false
            self.cancel.isHidden = false
        }
    }

    //MARK: - Get Image Via Delegate from Picker
    @objc func imageTapped(){
        print("imagetapped")
       
        PHPhotoLibrary.shared().register(self)
        photoHelper.presentActionSheet(from: self)
        
        textFieldTitle.resignFirstResponder()
        textFieldContent.resignFirstResponder()
    }
    func pushPostDealVC(image: UIImage) {
        dealImage.image = image
    }
    //MARK: - Set Constraints
    
    func configureConstraints(){
        self.title = "Post Deal".localized()
        self.tabBarItem.title = ""
//        view.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        view.backgroundColor = .white
        view.addSubview(cancel)
        view.addSubview(textFieldTitle)
        view.addSubview(textFieldContent)
        view.addSubview(dealImage)
        view.addSubview(postDeal)
        view.addSubview(chooseStore)
        dealImage.snp.makeConstraints { dealImage in
            dealImage.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            dealImage.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-430)
            dealImage.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            dealImage.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
        textFieldTitle.snp.makeConstraints { textFieldTitle in
            textFieldTitle.top.equalTo(dealImage.snp.bottom).offset(35)
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
            chooseStore.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-40)
            chooseStore.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(40)
        }
        postDeal.snp.makeConstraints { postDeal in
            postDeal.top.equalTo(chooseStore.snp.bottom).offset(5)
            postDeal.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-100)
            postDeal.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-40)
            postDeal.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(40)
        }
        cancel.snp.makeConstraints { cancel in
            cancel.top.equalTo(postDeal.snp.bottom).offset(5)
            cancel.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            cancel.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-40)
            cancel.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(40)
        }
    }
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

//MARK: - Extensions
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
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
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
         let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
         imageView.image = self
         UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
         guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
         guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
         UIGraphicsEndImageContext()
         return result
     }
     func resizeWithWidth(width: CGFloat) -> UIImage? {
         let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
         imageView.contentMode = .scaleAspectFit
         imageView.image = self
         UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
         guard let context = UIGraphicsGetCurrentContext() else { return nil }
         imageView.layer.render(in: context)
         guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
         UIGraphicsEndImageContext()
         return result
     }
}
