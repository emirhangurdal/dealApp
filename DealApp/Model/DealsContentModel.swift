import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct DealModel: Hashable {
    var storeID: String?
    var dealImage: UIImage?
    var dealTitle: String?
    var dealDesc: String?
    var dealID : String?
    var storeTitle: String?
    var sender: String?
    var userName: String?
    var distance: Double?
    init(storeID: String?, dealImage: UIImage?, dealTitle: String?, dealDesc: String?, dealID: String?, storeTitle: String?, sender: String?, userName: String?, distance: Double?) {
        self.storeID = storeID
        self.dealImage = dealImage
        self.dealDesc = dealDesc
        self.dealTitle = dealTitle
        self.dealID = dealID
        self.storeTitle = storeTitle
        self.sender = sender
        self.userName = userName
        self.distance = distance
    }
}

struct SectionOfCustomData {
  var header: String
  var items: [Item]
}
extension SectionOfCustomData: SectionModelType, Hashable {
    typealias Item = DealModel
    init(original: SectionOfCustomData, items: [Item]) { 
    self = original
    self.items = items
  }
}
class DealsData {
    
    static let shared = DealsData()
//    let dealsData : BehaviorRelay<[DealModel]> = BehaviorRelay(value: [])
    let dealsData : BehaviorRelay<[SectionOfCustomData]> = BehaviorRelay(value: [])
    var dealsArray = [SectionOfCustomData]()
    var id = String()
    var lat = Double()
    var long = Double()
    var distance = Double()
    var storeTitle = String()
}

