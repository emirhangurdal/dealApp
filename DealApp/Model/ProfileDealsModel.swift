import RxSwift
import RxCocoa

class ProfileDeals {
    static let shared = ProfileDeals()
    var userDeals = [DealModel]()
    var storeArray = [String]()
    let userDealsRelay : BehaviorRelay<[DealModel]> = BehaviorRelay(value: [])
}
