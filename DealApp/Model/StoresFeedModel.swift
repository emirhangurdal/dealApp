
import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Firebase
import FirebaseAuth

struct StoresFeedModel: Codable, Hashable {
    var title = String()
    var image = Data()
    var id = String()
    var distance = Double()
    var latitude = Double()
    var longitude = Double()
    var address1 = String()
    var address2 = String()
    var url = String()
    var phoneNumber = String()
}
protocol NewDataDelegate{
     func didFetchData()
}

struct StoreIDandTitle: Hashable {
var title = String()
var id = String()
var lat = Double()
var lon = Double()
var date = Double()
}

class StoresData {
    let novalueImageUrl = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/no%20value.jpg?alt=media&token=df6afb68-402f-4681-ad9b-5a30532376a1"
    let groceryIcon = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/market-icon-1024.png?alt=media&token=0221329d-afef-48fe-b41e-3dbbe792300c"
    static let shared = StoresData()
    var lat = Double()
    var lon = Double()
    var selectedSegment = Int()
    var storeIDSelected = String()
    var delegate: NewDataDelegate?
    var chooseStoreData = [StoresFeedModel]()
    let businesses: BehaviorRelay<[StoresFeedModel]> = BehaviorRelay(value: [])
   
    let cache = NSCache<NSString, DataStructHolder>()

    let images = NSCache<NSString, NSData>()
    var favIDsFirebase = [String]()
    var businessDataMain = [StoresFeedModel]()
    var businessDataFav = [StoresFeedModel]()
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
//                    self.businessDataFav = [StoresFeedModel(title: "Add Favorite Stores", image: self.novalueImageUrl, id: "No ID", distance: 0.0)]
                    DispatchQueue.main.async {
                        self.businesses.accept(self.businessDataFav)
                    }
                } else {
                    querySnapshot!.documents.enumerated().forEach { indexS, storeDocument in
                        self.favStoreDocID = storeDocument.documentID
                        
                    }
                }

            }
        }
    }
    
    
}
