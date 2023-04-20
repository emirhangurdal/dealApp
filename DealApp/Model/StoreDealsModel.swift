import RxSwift
import RxCocoa

class StrDeals {
    static let shared = StrDeals()
    var strDeals = [DealModel]()
    let strDealsRelay : BehaviorRelay<[DealModel]> = BehaviorRelay(value: [])
}

