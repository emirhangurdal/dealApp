import UIKit
import SnapKit
import CoreData
import Firebase
import FirebaseAuth
import RxSwift
import RxCocoa
import RxDataSources
protocol UpdateCustomCell: class {
    func labelfade()
}
protocol UpdateButtonImage: class {
    func updateButton()
}
protocol UpdateFavorites: class {
    func updateFavorites()
}
protocol OpenLink: class {
    func openLink(url: String)
}

class StoresTabCell: UITableViewCell, RemoveDeleteButton {
    weak var delegate: UpdateCustomCell?
    weak var delegate2: UpdateButtonImage?
    weak var delegate3: UpdateFavorites?
    weak var delegate4: OpenLink?
    var storeid: String?
    var representedItendifier: String = ""
    var distance = Double()
    var fav = false
    var newData = StoresData()
    let db = Firestore.firestore()
    var storeIDsArray = [String]()
    var phoneNumber = String()
    
    private var disposeBag = DisposeBag()
    
    private var imageViewPart: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    
    private var contentViewSeparator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    
    let storeImage : CircularImageView = {
        let imgView = CircularImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.backgroundColor = .clear
//        imgView.clipsToBounds = true
//        imgView.layer.cornerRadius = 10
        return imgView
    }()
    var storeName : UILabel = {
        let lbl = UILabel()
//        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        lbl.backgroundColor = .clear
        return lbl
    }()
    var urlLabel : UILabel = {
        let lbl = UILabel()
//        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .blue
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        lbl.backgroundColor = .clear
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    lazy var phoneButton: UIButton = {
       var phone = UIButton()
       let image = UIImage(named: "icons8-phone-100") as UIImage?
       phone.setImage(image, for: .normal)
       phone.backgroundColor = .clear
       phone.addTarget(self, action: #selector(phoneTapped), for: .touchUpInside)
       return phone
   }()
    
    lazy var addFavButton: UIButton = {
        var addFav = UIButton()
        let image = UIImage(named: "icons8-checked-checkbox-50") as UIImage?
        addFav.setImage(image, for: .normal)
        addFav.backgroundColor = .clear
        addFav.addTarget(self, action: #selector(addFavTapped), for: .touchUpInside)
        return addFav
    }()
    var deleteFromFavsButton: UIButton = {
        var deleteFav = UIButton()
        let image = UIImage(named: "icons8-minus-50") as UIImage?
        deleteFav.setImage(image, for: .normal)
        deleteFav.backgroundColor = .clear
        deleteFav.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return deleteFav
    }()
    @objc func phoneTapped(){
        print("phoneTapped")
        print("phoneNumber = \(phoneNumber)")
        let phoneNumberWithoutSpace = phoneNumber.filter {!$0.isWhitespace}
        callNumber(phoneNumber: phoneNumberWithoutSpace)
                // call the string phone here
    }
    func addGestureToURLLabel(){
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(urlTapped))
        urlLabel.addGestureRecognizer(tapViewGesture)
    }
    @objc func urlTapped() {
        print("urlTapped")
        
        self.delegate4?.openLink(url: urlLabel.text ?? "https://www.google.com/")
    }
    private func callNumber(phoneNumber:String) {
      if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            application.open(phoneCallURL, options: [:], completionHandler: nil)
        }
      }
    }
 
    @objc func addFavTapped(_ sender: UIButton) {
        print("addFavTapped")        
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
        }
        
        
        //MARK: - Save favIDs to Firestore
      
        if Auth.auth().currentUser != nil {
            let favStoresDocRef = self.db.collection("favStoreCollection").document(Auth.auth().currentUser!.uid)
            let favStoreIdsColRef = favStoresDocRef.collection("storeIDs").document(storeid ?? "")
            self.delegate2?.updateButton()
            
            favStoreIdsColRef.setData(["email" : Auth.auth().currentUser?.email]) { error in
                if let err = error {
                    print("error = \(err)")
                } else {
                    print("favStoreID sended to firebase db. = with \(favStoreIdsColRef.documentID)")
                    print("self.storeID = \(self.storeid)")
                        self.delegate3?.updateFavorites()
                }
            }
        }
        
        //MARK: - Locally save favoreStore Ids Core Data
        
        func save(favoriteStoreID: String) { //not used
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let Ids = StoreIDs(context: context)
            Ids.favoriteStoreID = favoriteStoreID
            do {
                try context.save()
            }
            catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
            
    }
    @objc func deleteTapped(_ sender: UIButton){
        print("deleteTapped")
        sender.alpha = 0.5
//        addFavButton.setImage(UIImage(named: "icons8-checked-checkbox-50"), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
        }
    
        let favStoresDocRef = self.db.collection("favStoreCollection").document(Auth.auth().currentUser!.uid)
       
        let _ = favStoresDocRef.collection("storeIDs").document(storeid ?? "").delete { error in
            if let err = error {
                print("error deleting favstoreID = \(err)")
                return
            } else {
                
                self.delegate3?.updateFavorites()

                print("fav storeid = \(self.storeid ?? "") deleted.")
                print("store name = \(self.storeName.text ?? "") deleted")
            }
        }
    }
    func removeButton() {
        deleteFromFavsButton.isHidden = true
    }
    //MARK: - Core Data
    func deleteFavIdCoreData(id: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<StoreIDs>
        fetchRequest = StoreIDs.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "favoriteStoreID LIKE %@", "\(id)"
        )
        do {
            let idstoDelete = try context.fetch(fetchRequest)
            for i in 0..<idstoDelete.count {
                context.delete(idstoDelete[i])
                do {
                    try context.save()
                } catch {
                    print("error saving after deleting favorite = \(error)")
                }
            }
        } catch {
            print("error fetching request with predicate to delete = \(error)")
        }
    }
    private func fetchtheLatest() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<StoreIDs> = StoreIDs.fetchRequest()
        do {
            let fetchedID = try context.fetch(request)
            
        } catch {
            print("Error fetching data from CoreData \(error)")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureConstraints()
        addGestureToURLLabel()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    //MARK: - Constraints
    func configureConstraints() {
        
        contentView.addSubview(storeName)
        contentView.addSubview(urlLabel)
        contentView.addSubview(addFavButton)
        contentView.addSubview(deleteFromFavsButton)
        contentView.addSubview(contentViewSeparator)
        contentView.addSubview(phoneButton)
        
        contentViewSeparator.addSubview(imageViewPart)
        imageViewPart.addSubview(storeImage)
//        contentView.backgroundColor = UIColor(red: 65/255, green: 76/255, blue: 97/255, alpha: 0.8) - 108, 106, 117
//        contentView.backgroundColor = UIColor(red: 108/255, green: 106/255, blue: 117/255, alpha: 0.8)
//        contentView.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 0.5)
        contentViewSeparator.snp.makeConstraints { separatorContentView in
            separatorContentView.width.equalTo(1)
            separatorContentView.height.equalTo(1)
            separatorContentView.centerX.equalTo(contentView)
            separatorContentView.centerY.equalTo(contentView)
        }
        imageViewPart.snp.makeConstraints { imageViewPart in
            imageViewPart.top.equalTo(contentView)
            imageViewPart.bottom.equalTo(contentView)
            imageViewPart.left.equalTo(contentView)
            imageViewPart.right.equalTo(contentViewSeparator)
        }
        storeImage.snp.makeConstraints { storeImage in
            storeImage.width.equalTo(80)
            storeImage.height.equalTo(80)
            storeImage.centerY.equalTo(imageViewPart)
            storeImage.centerX.equalTo(imageViewPart)
        }
        
        storeName.snp.makeConstraints { storeName in
            storeName.top.equalTo(contentView)
            storeName.bottom.equalTo(contentViewSeparator)
            storeName.left.equalTo(storeImage.snp.right).offset(5)
            storeName.right.equalTo(contentView).offset(-50)
        }
        urlLabel.snp.makeConstraints { urlLabel in
            urlLabel.height.equalTo(15)
            urlLabel.right.equalTo(contentView)
            urlLabel.left.equalTo(storeImage.snp.right).offset(5)
            urlLabel.top.equalTo(storeName.snp.bottom).offset(2)
        }
        phoneButton.snp.makeConstraints { phoneButton in
            phoneButton.height.equalTo(25)
            phoneButton.width.equalTo(25)
            phoneButton.top.equalTo(contentView).offset(1)
            phoneButton.right.equalTo(contentView).offset(-10)
        }

    }
    //MARK: - Configure with Data
    func configureWithData(dataModel: StoresFeedModel) {
        storeName.text = dataModel.title
        storeid = dataModel.id // use this id to recall api
        distance = dataModel.distance // use this to list only the deals nearby
    }
}


//MARK: - Remove duplicate elements from array: 

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
// delete an element
extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}
