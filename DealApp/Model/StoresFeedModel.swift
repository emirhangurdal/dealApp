
import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import CoreData
import Firebase
import FirebaseAuth

struct StoresFeedModel: Codable, Hashable {
    var title = String()
    var image = String()
    var id = String()
    var distance = Double()
    var latitude = Double()
    var longitude = Double()
    var address1 = String()
    var address2 = String()
}
protocol NewDataDelegate{
     func didFetchData()
}

class StoresData {
    let novalueImageUrl = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/no%20value.jpg?alt=media&token=df6afb68-402f-4681-ad9b-5a30532376a1"
    static let shared = StoresData()
    var lat = Double()
    var lon = Double()
    var selectedSegment = Int()
    var storeIDSelected = String()
    var delegate: NewDataDelegate?
    let businesses: BehaviorRelay<[StoresFeedModel]> = BehaviorRelay(value: [])
    var favIDsCoreData : [StoreIDs] = [] {
        didSet {
        }
    }

    var favIDsFirebase = [String]()
    var businessDataMain = [StoresFeedModel]()
    var businessDataFav = [StoresFeedModel]()
    var chooseStoreData = [StoresFeedModel]()
    var storesList = [String]()
    let disposeBag = DisposeBag()
    let db = Firestore.firestore()
    var storeIDsArray = [String]()
    var favStoreDocID = String()
    func getFavDataFromFirebase(completion: @escaping ([StoresFeedModel]) -> Void) {
        var completionData = [StoresFeedModel]()
        completionData.removeAll()
        storeIDsArray.removeAll()
        let favStoresDocRef = self.db.collection("favStoreCollection").document(Auth.auth().currentUser!.uid)
        let favStoreIdsColRef = favStoresDocRef.collection("storeIDs")
        favStoreIdsColRef.getDocuments { querySnapshot, error in
            if let err = error {
                print("err reading favstoreIDs = \(err)")
            } else {
                print("querySnapshot!.documents.count = \(querySnapshot!.documents.count)")
                if querySnapshot!.documents.count == 0 {
                    self.businessDataFav = [StoresFeedModel(title: "No Stores Yet", image: self.novalueImageUrl, id: "No ID", distance: 0.0)]
                    self.businesses.accept(self.businessDataFav)
                }
                querySnapshot!.documents.enumerated().forEach { indexS, storeDocument in
                    self.favStoreDocID = storeDocument.documentID
                    print("favstoreDocument.documentID = \(self.favStoreDocID)")
                    YelpAPIManager.shared.getFavStoreInfo(id: self.favStoreDocID) { favData in
                        completionData.append(favData)
                        completion(completionData.removingDuplicates())
                    }
                }
            }
        }
    }
    func getFavData(completion: @escaping ([StoresFeedModel]) -> Void ) {
        var completionData = [StoresFeedModel]()
        completionData.removeAll()
        fetchtheLatest()
        if favIDsCoreData.removingDuplicates().count != 0 {
            for i in 0..<favIDsCoreData.removingDuplicates().count {
                YelpAPIManager.shared.getFavStoreInfo(id: favIDsCoreData.removingDuplicates()[i].favoriteStoreID!) { favDataApi in
                completionData.append(favDataApi)
                completion(completionData.removingDuplicates())
                }
            }
        } else {
            print("favIDsCoreData.removingDuplicates().count = \(favIDsCoreData.removingDuplicates().count)")
            completionData = [StoresFeedModel(title: "No Favorites Selected Yet", image: novalueImageUrl, id: "")]
            completion(completionData)
        }
    }
    private func fetchtheLatest() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<StoreIDs> = StoreIDs.fetchRequest()
        do {
            favIDsCoreData = try context.fetch(request)
            
        } catch {
            print("Error fetching data from CoreData \(error)")
        }
    }
    func subscribeTo() {
        businesses.asObservable()
          .subscribe(onNext: {
            [weak self] businessData in
              print("businessData = \(businessData)")
          }) .disposed(by: disposeBag)
    }
}
