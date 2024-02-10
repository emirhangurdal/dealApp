import Foundation
import FirebaseFirestore
import FirebaseStorage

struct SectionOfCouponBrand {
    var categories: [CouponCategory]?
}
struct CouponCategory {
    var categoryTitle: String?
    var categoryBrands: [String:CouponBrand]?
}

struct CouponBrand {
    let image: UIImage?
    let title: String?
    var coupons: [Coupon]?
}

struct Coupon {
    let image: String?
    let title: String?
    let save: String?
    let desc: String? //BOGO or similar
    let exp: String?
    let category: String?
    let link: String?
}

protocol CouponDataDelegate: AnyObject {
    func presentAlert(error: String)
}

class CouponData {
    let database = Firestore.firestore()
    var couponData: SectionOfCouponBrand?
    private let storage = Storage.storage()
    let dispatchGroup = DispatchGroup()
    weak var presentAlertDelegate: CouponDataDelegate?
    //MARK: - Get Data
    
    func getData(completion: @escaping (SectionOfCouponBrand?) -> Void) {
        couponData = SectionOfCouponBrand(categories: [])
        let couponsReference = database.collection("coupons")
        
        couponsReference.getDocuments { snapShotCategory, error in
            if let error = error {
                print("error getting Categories = \(error)")
                self.presentAlertDelegate?.presentAlert(error: error.localizedDescription)
                return
            }
            guard snapShotCategory != nil else {return}
            snapShotCategory?.documents.enumerated().forEach() { indexCategory, document in
                
                let data = document.data()
                let categoryTitle = document.documentID
                
                self.couponData?.categories?.append(CouponCategory(categoryTitle: categoryTitle, categoryBrands: [:]))
                
                let brandsReference = couponsReference.document(categoryTitle).collection("Brands")
                
                brandsReference.getDocuments { snapShotBrand, error in
                    if let error = error {
                        print(error)
                        self.presentAlertDelegate?.presentAlert(error: error.localizedDescription)
                        return
                    }
                    guard snapShotBrand != nil else {return}
                    snapShotBrand!.documents.enumerated().forEach() { indexBrand, document in
                      
                        let brand = document.documentID
                        
                        let couponsReference = brandsReference.document(brand).collection("coupons")
                        
                        self.downloadLogo(mainCategory: categoryTitle, brand: brand) { image in
                            
                            self.couponData?.categories?[indexCategory].categoryBrands?[brand] = CouponBrand(image: image, title: brand, coupons: [])
                            
                            print("downloadLogo finished")
                         
                            self.dispatchGroup.notify(queue: .main) {
                                
                                couponsReference.getDocuments { snapShotCoupon, error in
                                    
                                    if let error = error {
                                        print(error)
                                        self.presentAlertDelegate?.presentAlert(error: error.localizedDescription)
                                        return
                                    }
                                    var coupons = [Coupon]()
                                    guard snapShotCoupon != nil else {return}
                                    snapShotCoupon!.documents.enumerated().forEach() { indexCoupon, document in
                                        
                                        let data = document.data()
                                        if let desc = data["desc"] as? String,
                                           let title = data["title"] as? String,
                                           let save = data["save"] as? String,
                                           let exp = data["exp"] as? String,
                                           let image = data["image"] as? String,
                                           let category = data["category"] as? String,
                                           let link = data["link"] as? String {
                                            
                                            coupons.append(Coupon(image: image, title: title, save: save, desc: desc, exp: exp, category: category, link: link))
                                        } else {
                                            print("there is problem with data fields")
                                        }
                                    }
                                    
                                    self.couponData?.categories?[indexCategory].categoryBrands?[brand] = CouponBrand(image: image, title: brand, coupons: coupons)
                                    completion(self.couponData)
                                }
                            }
                        }
                      
                    }
                }
            }
           
        }
    }
    
    func downloadLogo(mainCategory: String, brand: String, image: @escaping (UIImage) -> Void) {
        let brandLogoReference = storage.reference().child("/CouponBrandLogos/\(brand)Logo.png")
        
        brandLogoReference.downloadURL { url, error in
            guard error == nil else {
                print("error downloading image = \(error?.localizedDescription)")
                return
            }
            self.dispatchGroup.enter()
            let logoImageView = UIImageView()
            
            logoImageView.downloadImage(from: url!.absoluteString) { response in
                
                image(response.image ?? UIImage(named: "empty-icon-25")!)
                self.dispatchGroup.leave()
            }
            
        }
    }
}



