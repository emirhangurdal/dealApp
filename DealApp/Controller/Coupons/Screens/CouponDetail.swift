
import Foundation
import UIKit
import SnapKit

class CouponDetail: UIViewController {
    
    override func viewDidLoad() {
        
        configureConstraints()
        updateUI()
        addGesture()
    }
    override func viewDidAppear(_ animated: Bool) {
       
    }
    var store = String()
    init(coupon: Coupon, brand: String) {
        self.coupon = coupon
        store = brand
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    var coupon: Coupon?
    let couponImage : UIImageView = {
    let imgView = UIImageView()
    imgView.contentMode = .scaleAspectFit
    imgView.clipsToBounds = true
    imgView.layer.cornerRadius = 8.0
    imgView.backgroundColor = .white
    return imgView
    }()
    let separator = UIView()
    let upperView = UIView()
    var couponDetail: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 17)
        lbl.textColor = .black
        lbl.layer.masksToBounds = true
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    var exp: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 17)
        lbl.textColor = .red
        lbl.layer.masksToBounds = true
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    func updateUI() {
        couponImage.loadImageAsync(with: coupon?.image)
        
        couponDetail.text = "Coupon at \(store): \n\(coupon?.save ?? "")\n\(coupon?.title ?? "") \n\(coupon?.desc ?? "")"
        exp.text = "Expiration: \(coupon?.exp ?? "")"
        view.backgroundColor = .white
    }
    func addGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            couponDetail.addGestureRecognizer(tapGesture)
            upperView.addGestureRecognizer(tapGesture2)
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("couponImage Tapped or detail")
        let couponWebView = CouponWebView(url: coupon?.link ?? "https://www.weeklyads2.com/")
        navigationController?.pushViewController(couponWebView, animated: true)
    }
    
    func configureConstraints(){
        view.addSubview(couponImage)
        view.addSubview(couponDetail)
        view.addSubview(separator)
        view.addSubview(upperView)
        view.addSubview(exp)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            adjustConstraints(sizeDetail: 250, sizeExp: 100)
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            adjustConstraints(sizeDetail: 150, sizeExp: 50)
        }
        func adjustConstraints(sizeDetail: Int, sizeExp: Int) {
            separator.snp.makeConstraints { separator in
                separator.height.equalTo(1)
                separator.width.equalTo(1)
                separator.centerX.equalTo(view)
                separator.centerY.equalTo(view)
            }
            upperView.snp.makeConstraints { upperView in
                upperView.top.equalTo(view.safeAreaLayoutGuide)
                upperView.bottom.equalTo(separator.snp.top)
                upperView.right.equalTo(view.safeAreaLayoutGuide)
                upperView.left.equalTo(view.safeAreaLayoutGuide)
            }
            
            couponImage.snp.makeConstraints { couponImage in
                couponImage.height.equalTo(upperView).multipliedBy(0.50)
                couponImage.width.equalTo(upperView).multipliedBy(0.50)
                couponImage.centerX.equalTo(upperView)
                couponImage.centerY.equalTo(upperView)
            }
            couponDetail.snp.makeConstraints { couponDetail in
                couponDetail.width.equalTo(view.frame.size.width - 10)
                couponDetail.height.equalTo(150)
                couponDetail.centerX.equalTo(view)
                couponDetail.top.equalTo(upperView.snp.bottom).offset(2)
            }
            exp.snp.makeConstraints { exp in
                exp.width.equalTo(view.frame.size.width - 10)
                exp.height.equalTo(50)
                exp.centerX.equalTo(view)
                exp.top.equalTo(couponDetail.snp.bottom).offset(2)
            }
        }
    }
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}

