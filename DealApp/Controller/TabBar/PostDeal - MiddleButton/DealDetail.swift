import UIKit
import SnapKit
import Firebase

protocol DealDetailDelegate: AnyObject {
     func updateData(data: DealModel)
}
class DealDetail: UIViewController {
    override func viewDidLoad() {
        print("DealDetail")
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        view.backgroundColor = .white
        self.title = "DealDetail"
        configureConst()
        if self.delegate == nil {
            print("delegate is nil")
        }
    }
    let db = Firestore.firestore()
    var delegate: DealDetailDelegate?
    let dealsContent = DealsContentVC()
    var deals = DealsData()
    var spinner = SpinnerViewController()
    var labelMessage : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        lbl.text = "Your Deal Has Been Posted!"
        lbl.textColor = .black
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        lbl.layer.borderColor = gray.cgColor
        lbl.layer.borderWidth = 2.0
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        lbl.textAlignment = .center
        lbl.sizeToFit()
        return lbl 
    }()
    var labelContent : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        lbl.text = "Deal Description"
        lbl.textColor = .black
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        lbl.layer.borderColor = gray.cgColor
        lbl.layer.borderWidth = 2.0
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        lbl.sizeToFit()
        return lbl
    }()
    var labelTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Title"
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        lbl.textColor = .black
        lbl.layer.borderColor = gray.cgColor
        lbl.layer.borderWidth = 2.0
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        return lbl
    }()
    var storeTitle = String()
    var labelStoreTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Deal at ... "
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        lbl.font = UIFont.boldSystemFont(ofSize: 12)
        lbl.textColor = .black
        lbl.layer.borderColor = gray.cgColor
        lbl.layer.borderWidth = 2.0
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        return lbl
    }()
    var dealImage : UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "ExampleDeal")!
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        img.layer.borderColor = gray.cgColor
        img.contentMode = .scaleAspectFit
        img.layer.borderWidth = 2.0
        img.layer.masksToBounds = true
        img.layer.cornerRadius = 5
        return img
    }()
   lazy var seeAllDealsButton: UIButton = {
       var bttn = UIButton()
       bttn.setTitle("Done", for: .normal)
       bttn.backgroundColor = .gray
       bttn.addTarget(self, action: #selector(seeAllDealsTapped), for: .touchUpInside)
       return bttn
   }()
    @objc func seeAllDealsTapped(sender: UIButton){
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
        }
        print("SEE ALL DEALS")
//        guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? TabBarViewController else {return}
//        tabBarController.selectedIndex = 2
//        let dealsContentVC = tabBarController.viewControllers?[2]
//        dealsContentVC?.deals.dealsArray.append(contentsOf: [DealModel(dealImage: dealImage.image!, dealTitle: labelTitle.text!, dealDesc: labelContent.text!)])
        self.dismiss(animated: true, completion: nil)
    }
    func configureConst(){
        view.addSubview(seeAllDealsButton)
        view.addSubview(labelContent)
        view.addSubview(labelTitle)
        view.addSubview(dealImage)
        view.addSubview(labelMessage)
        view.addSubview(labelStoreTitle)
        labelStoreTitle.text = "Deal at \(storeTitle)"
        dealImage.snp.makeConstraints { dealImage in
            dealImage.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            dealImage.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-400)
            dealImage.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            dealImage.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
        labelStoreTitle.snp.makeConstraints { labelStoreTitle in
            labelStoreTitle.top.equalTo(dealImage.snp.bottom).offset(5)
            labelStoreTitle.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-370)
            labelStoreTitle.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            labelStoreTitle.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
        labelTitle.snp.makeConstraints { labelTitle in
            labelTitle.top.equalTo(dealImage.snp.bottom).offset(35)
            labelTitle.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-315)
            labelTitle.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            labelTitle.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
        labelContent.snp.makeConstraints { labelContent in
            labelContent.top.equalTo(labelTitle.snp.bottom).offset(5)
            labelContent.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-165)
            labelContent.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            labelContent.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
        labelMessage.snp.makeConstraints { labelMessage in
            labelMessage.top.equalTo(labelContent.snp.bottom).offset(5)
            labelMessage.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-115)
            labelMessage.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            labelMessage.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
        seeAllDealsButton.snp.makeConstraints { seeAllDealsButton in
            seeAllDealsButton.top.equalTo(labelMessage.snp.bottom).offset(5)
            seeAllDealsButton.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-65)
            seeAllDealsButton.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-5)
            seeAllDealsButton.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
        }
    }
    func addSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    func stopSpinner(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
        }
    }
}
