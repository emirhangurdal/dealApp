import UIKit
import SnapKit
import CoreData
import Firebase
import FirebaseAuth
import RxSwift
import RxCocoa
import RxDataSources
protocol UpdateCustomCell: class {
    func updateTableView()
}
class StoresTabCell: UITableViewCell {
    weak var delegate: UpdateCustomCell?
    var storeid = String()
    
    var newData = NewData()
    let db = Firestore.firestore()
    var storeIDsArray = [String]()
    let storeImage : UIImageView = {
    let imgView = UIImageView()
    imgView.contentMode = .scaleAspectFit
    imgView.backgroundColor = .clear
    imgView.clipsToBounds = true
    imgView.layer.cornerRadius = 10
    return imgView
    }()
    var storeName : UILabel = {
    let lbl = UILabel()
    lbl.textColor = .black
    lbl.font = UIFont.boldSystemFont(ofSize: 25)
    lbl.textColor = .white
    lbl.textAlignment = .center
    lbl.numberOfLines = 0
    lbl.textAlignment = .left
    lbl.backgroundColor = .clear
    return lbl
    }()
     var addFavButton: UIButton = {
        var addFav = UIButton()
        let image = UIImage(named: "icons8-checked-checkbox-50") as UIImage?
        addFav.setImage(image, for: .normal)
        addFav.backgroundColor = .clear
        addFav.addTarget(self, action: #selector(addFavTapped), for: .touchUpInside)
        return addFav
    }()
     var deleteFromFavsButton: UIButton = {
        var deleteFav = UIButton()
        let image = UIImage(named: "icons8-close-50") as UIImage?
        deleteFav.setImage(image, for: .normal)
        deleteFav.backgroundColor = .clear
        deleteFav.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return deleteFav
    }()
    @objc func addFavTapped(_ sender: UIButton) {
        print("addFavTapped")
         sender.alpha = 0.5
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
             sender.alpha = 1.0
         }
//MARK: - Save favIDs to Firestore
        if Auth.auth().currentUser != nil {
            let favStoresDocRef = self.db.collection("favStoreCollection").document(Auth.auth().currentUser!.uid)
            let favStoreIdsColRef = favStoresDocRef.collection("storeIDs").document(storeid)
            favStoreIdsColRef.setData(["email" : Auth.auth().currentUser?.email]) { error in
                if let err = error {
                    print("error = \(err)")
                } else {
                    print("favStoreID sended to firebase db. = with \(favStoreIdsColRef.documentID)")
                    print("self.storeID = \(self.storeid)")
                }
            }
        }
//MARK: - Locally save favoreStore Ids
        
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
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
             sender.alpha = 1.0
         }
        print("self.storeID = \(self.storeid)")
       
        delegate?.updateTableView()
        print("storeid = \(storeid)")
        let favStoresDocRef = self.db.collection("favStoreCollection").document(Auth.auth().currentUser!.uid) // data fucks up when you delete here. find why
        let favStoreIdsColRef = favStoresDocRef.collection("storeIDs").document(storeid).delete { error in
            if let err = error {
                print("error deleting favstoreID = \(err)")
            } else {
                print("fav storeid deleted.")
            }
        }
    }
    //Fetch with predicate, delete, and save.
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
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//MARK: - Constraints
    func configureConstraints() {
        self.contentView.addSubview(storeImage)
        self.contentView.addSubview(storeName)
        self.contentView.addSubview(addFavButton)
        self.contentView.addSubview(deleteFromFavsButton)
        contentView.backgroundColor = UIColor(red: 65/255, green: 76/255, blue: 97/255, alpha: 0.8)
        
        storeImage.snp.makeConstraints { storeImage in
            storeImage.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 300))
        }
        storeName.snp.makeConstraints { storeName in
            storeName.left.equalTo(storeImage.snp.right).offset(25)
            storeName.right.equalTo(self.contentView).offset(-80)
            storeName.bottom.equalTo(self.contentView).offset(-50)
            storeName.top.equalTo(self.contentView)
        }
        addFavButton.snp.makeConstraints { addFavButton in
            addFavButton.left.equalTo(storeImage.snp.right).offset(25)
            addFavButton.right.equalTo(self.contentView).offset(-245)
            addFavButton.bottom.equalTo(self.contentView).offset(-10)
            addFavButton.top.equalTo(storeName.snp.bottom).offset(10)
        }
        deleteFromFavsButton.snp.makeConstraints { deleteFromFavsButton in
            deleteFromFavsButton.left.equalTo(addFavButton.snp.right).offset(5)
            deleteFromFavsButton.right.equalTo(self.contentView).offset(-210)
            deleteFromFavsButton.bottom.equalTo(self.contentView).offset(-10)
            deleteFromFavsButton.top.equalTo(storeName.snp.bottom).offset(10)
        }

    }
//MARK: - Configure with Data
    func configureWithData(dataModel: StoresFeedModel) {
        storeName.text = dataModel.title
        storeImage.downloaded(from: dataModel.image)
        storeid = dataModel.id // use this id to recall api
    }
}
//MARK: - Extensions

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {  return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
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
