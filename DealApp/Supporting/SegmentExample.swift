//
//import Foundation
//enum SegmentType: String {
//    case allStores = "All Stores"
//    case favorites = "Favorites"
//}
//let segments: [SegmentType] = [.allStores, .favorites]
//lazy var segmentControl: UISegmentedControl = {
//    let sc = UISegmentedControl(items: segments.map({ $0.rawValue }))
//    
//    sc.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
//    sc.selectedConfiguration(font: UIFont.systemFont(ofSize: 12), color: .black)
//    sc.defaultConfiguration()
//    sc.tintColor = .white
//    sc.selectedSegmentIndex = 0
//    sc.addTarget(self, action: #selector(actionofSC), for: .valueChanged)
//    return sc
//}()
//@objc func actionofSC() {
//    print("action of SCr")
//    let type = segments[segmentControl.selectedSegmentIndex]
//    switch type {
//    case .allStores:
//        getMainData()
//        print("ALL STORES")
//    case .favorites:
//        print("FAVORITES")
//        reCallApi()
//    }
//}
