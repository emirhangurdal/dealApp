import UIKit
import SnapKit

class Help: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHelp()
    }
    var help : VerticalTopAlignLabel = {
        let lbl = VerticalTopAlignLabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        lbl.textColor = .black
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        lbl.textAlignment = .justified
        lbl.numberOfLines = 0
        lbl.sizeToFit()
        return lbl
    }()
    func configureHelp(){
        view.backgroundColor = .white
        self.navigationItem.title = "Help".localized()
        view.addSubview(help)
        help.snp.makeConstraints { help in
            help.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            help.bottom.equalTo(view.safeAreaLayoutGuide).offset(-5)
            help.right.equalTo(view.safeAreaLayoutGuide).offset(-5)
            help.left.equalTo(view.safeAreaLayoutGuide).offset(5)
        }
        help.text = "Here you can find coupons of national brands. Coupons are popular discounts used by bargain hunters. You can find the popular grocery stores, restaurants, and many others here. All the coupons are redirected to the official pages and you can see their own pages when you tap on a coupon. This app does not provide you with the official information of the coupons. To use or redeem the coupons you should visit the official page of the brand of the coupon."
    }
}
