import RxSwift
import RxCocoa

struct BlockedData {
    let id: String?
    let name: String?
}

class ProfileDeals {
    static let shared = ProfileDeals()
    var userDeals = [DealModel]()
    var storeArray = [String]()
    let userDealsRelay : BehaviorRelay<[DealModel]> = BehaviorRelay(value: [])
    var blockedUsersIDs = [BlockedData]()
}
