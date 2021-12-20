//
//  StoresTabCell.swift
//  DealApp
//
//  Created by Emir Gurdal on 20.11.2021.
// ImageView is for Store's Logo. It can be empty if no one adds or no Api data exissts.

import UIKit
import SnapKit
import CoreData
import Firebase
import FirebaseAuth
import RxSwift
import RxDataSources

class StoresTabCell: UITableViewCell {
  
    var favIDsCoreData = [StoreIDs]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static let shared = StoresTabCell()
    var storeid = String()
    
    
    
    let storeImage : UIImageView = {
    let imgView = UIImageView()
    imgView.contentMode = .scaleAspectFit
    imgView.backgroundColor =  .clear
    imgView.clipsToBounds = true
    imgView.layer.cornerRadius = 10
    
    return imgView
    }()
    let storeName : UILabel = {
    let lbl = UILabel()
    lbl.textColor = .black
    lbl.font = UIFont.boldSystemFont(ofSize: 10)
    lbl.textAlignment = .center
    lbl.numberOfLines = 0
    lbl.textAlignment = .left
   
    lbl.backgroundColor = .clear
    return lbl
    }()
    var addFavButton: UIButton = {
        var addFav = UIButton()
        let image = UIImage(named: "icons8-add-to-favorites-50") as UIImage?
        addFav.setImage(image, for: .normal)
        addFav.backgroundColor = .gray
        addFav.addTarget(self, action: #selector(addFavTapped), for: .touchUpInside)
        return addFav
    }()
    var deleteFromFavsButton: UIButton = {
        var deleteFav = UIButton()
        let image = UIImage(named: "icons8-delete-64") as UIImage?
        deleteFav.setImage(image, for: .normal)
        deleteFav.backgroundColor = .gray
        deleteFav.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return deleteFav
    }()
    
    @objc func addFavTapped(_ sender: UIButton) {
        print("addFavTapped")
         sender.alpha = 0.5
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
             sender.alpha = 1.0
         }

//MARK: - Locally save favoreStore Ids
        save(favoriteStoreID: storeid)
        func save(favoriteStoreID: String) {
            let Ids = StoreIDs(context: context)
            Ids.favoriteStoreID = favoriteStoreID
            do {
                try context.save()
            }
            catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        YelpAPIManager.shared.getFavStoreInfo(id: storeid) { dataFavAdded in
            
        }
    
    }
    @objc func deleteTapped(_ sender: UIButton){
        print("deleteTapped")
         sender.alpha = 0.5
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
             sender.alpha = 1.0
         }
        deleteFavIdCoreData(id: storeid)
        let newFavDataAfterDeleting = StoresFeed.shared.businessDataFav.filter { $0.id != storeid }
        StoresFeed.shared.businessDataFav = newFavDataAfterDeleting
    }
    //Fetch with predicate, delete, and save.
    func deleteFavIdCoreData(id: String) {
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
        fetchStoreIdCoreData()
    }
//Fetch storeids from coredata:
    func fetchStoreIdCoreData() {
        let request: NSFetchRequest<StoreIDs> = StoreIDs.fetchRequest()
        do {
            favIDsCoreData = try context.fetch(request).removingDuplicates()
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

        storeImage.snp.makeConstraints { storeImage in
            storeImage.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 5, left: 5, bottom: 50, right: 300))
        }
        storeName.snp.makeConstraints { storeName in
            storeName.left.equalTo(storeImage.snp.right).offset(5)
            storeName.right.equalTo(self.contentView).offset(-130)
            storeName.bottom.equalTo(self.contentView).offset(-50)
            storeName.top.equalTo(self.contentView)
        }
        addFavButton.snp.makeConstraints { addFavButton in
            addFavButton.left.equalTo(storeName.snp.right)
            addFavButton.right.equalTo(self.contentView).offset(-5)
            addFavButton.bottom.equalTo(self.contentView).offset(-75)
            addFavButton.top.equalTo(self.contentView)
        }
        deleteFromFavsButton.snp.makeConstraints { deleteFromFavsButton in
            deleteFromFavsButton.left.equalTo(storeName.snp.right)
            deleteFromFavsButton.right.equalTo(self.contentView).offset(-5)
            deleteFromFavsButton.bottom.equalTo(self.contentView).offset(-5)
            deleteFromFavsButton.top.equalTo(addFavButton.snp.bottom).offset(5)
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
                else { return }
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
