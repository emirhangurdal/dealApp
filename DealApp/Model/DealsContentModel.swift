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
    var senderUID: String?
    var countDown: Int?
    
    init(storeID: String?, dealImage: UIImage?, dealTitle: String?, dealDesc: String?, dealID: String?, storeTitle: String?, sender: String?, userName: String?, distance: Double?, senderUID: String?, countDown: Int?) {
        self.storeID = storeID
        self.dealImage = dealImage
        self.dealDesc = dealDesc
        self.dealTitle = dealTitle
        self.dealID = dealID
        self.storeTitle = storeTitle
        self.sender = sender
        self.userName = userName
        self.distance = distance
        self.senderUID = senderUID
        self.countDown = countDown
    }
}

struct SectionOfCustomData {
    var header: String
    var date: Double
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
    var id: String?
    var lat = Double()
    var long = Double()
    var distance = Double()
    var storeTitle: String?
    var dealCount = Int()
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

