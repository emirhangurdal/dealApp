import UIKit
import SnapKit
import Firebase

protocol DealDetailDelegate: AnyObject {
     func updateData(data: DealModel)
}
class DealDetail: UIViewController {
    override func viewDidLoad() {
        print("DealDetail")
        view.backgroundColor = .black
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
        lbl.font = UIFont(name: "Optima-Bold", size: 15)
        lbl.text = "Your Deal Has Been Posted!"
        lbl.textColor = .white
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        lbl.layer.borderColor = white.cgColor
        lbl.layer.borderWidth = 2.0
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        lbl.textAlignment = .center
        lbl.sizeToFit()
        return lbl 
    }()
    var labelContent : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Optima-Bold", size: 15)
        lbl.text = "labelContent"
        lbl.textColor = .white
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        lbl.layer.borderColor = white.cgColor
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
        lbl.text = "labelTitle"
        lbl.font = UIFont(name: "Optima-Bold", size: 15)
        lbl.textColor = .white
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        lbl.layer.borderColor = white.cgColor
        lbl.layer.borderWidth = 2.0
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        return lbl
    }()
    var dealImage : UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "ExampleDeal")!
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        img.layer.borderColor = white.cgColor
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
        dealImage.snp.makeConstraints { dealImage in
            dealImage.right.equalTo(view.snp.right).offset(-5)
            dealImage.left.equalTo(view.snp.left).offset(5)
            dealImage.bottom.equalTo(view.snp.bottom).offset(-550)
            dealImage.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(50)
        }
        labelTitle.snp.makeConstraints { labelTitle in
            labelTitle.right.equalTo(view.snp.right).offset(-5)
            labelTitle.left.equalTo(view.snp.left).offset(5)
            labelTitle.bottom.equalTo(view.snp.bottom).offset(-500)
            labelTitle.top.equalTo(dealImage.snp.bottom).offset(5)
        }
        labelContent.snp.makeConstraints { labelContent in
            labelContent.right.equalTo(view.snp.right).offset(-5)
            labelContent.left.equalTo(view.snp.left).offset(5)
            labelContent.bottom.equalTo(view.snp.bottom).offset(-250)
            labelContent.top.equalTo(labelTitle.snp.bottom).offset(5)
        }
        labelMessage.snp.makeConstraints { labelMessage in
            labelMessage.right.equalTo(view.snp.right).offset(-35)
            labelMessage.left.equalTo(view.snp.left).offset(35)
            labelMessage.bottom.equalTo(view.snp.bottom).offset(-150)
            labelMessage.top.equalTo(labelContent.snp.bottom).offset(5)
        }
        seeAllDealsButton.snp.makeConstraints { seeAllDealsButton in
            seeAllDealsButton.right.equalTo(view.snp.right).offset(-35)
            seeAllDealsButton.left.equalTo(view.snp.left).offset(35)
            seeAllDealsButton.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            seeAllDealsButton.top.equalTo(labelMessage.snp.bottom).offset(5)
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
