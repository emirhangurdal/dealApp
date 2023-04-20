import UIKit
import SnapKit
import Firebase
import SafariServices

protocol DealDetailDelegate: AnyObject {
     func updateData(data: DealModel)
}
class DealDetail: UIViewController {
    override func viewDidLoad() {
        print("DealDetail")
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        view.backgroundColor = .white
        self.title = "Deal Detail".localized()
        addGestureToContent()
        configureConst()
        configureImageFullScreen()
        makeURLBlue(url: URL(string: self.labelTitle.text ?? self.labelContent.text ?? "https://www.weeklyads2.com/"))
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
   
    let dealString = "Deal @".localized()
    let db = Firestore.firestore()
    var delegate: DealDetailDelegate?
    let dealsContent = DealsContentVC()
    var deals = DealsData()
    var spinner = SpinnerViewController()
    
    var labelMessage : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.text = "Your Deal Has Been Posted!".localized()
        lbl.textColor = .black
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        lbl.textAlignment = .center
        lbl.sizeToFit()
        return lbl 
    }()
    var labelContent : VerticalTopAlignLabel = {
        let lbl = VerticalTopAlignLabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.text = "Deal Description".localized()
        lbl.textColor = .black
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        lbl.numberOfLines = 0
        lbl.sizeToFit()
        return lbl
    }()
    var labelTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Title".localized()
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        lbl.font = UIFont.systemFont(ofSize: 22)
        lbl.textColor = .black
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        return lbl
    }()
    var storeTitle = String()
    var labelStoreTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Deal at ... ".localized()
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .black
        lbl.layer.masksToBounds = true
        return lbl
    }()
    var dealImage : UIImageView = {
        let img = UIImageView()
        var white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        var gray = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        img.contentMode = .scaleAspectFit
        img.layer.masksToBounds = true
        img.layer.cornerRadius = 5
        return img
    }()
   lazy var seeAllDealsButton: UIButton = {
       var bttn = UIButton()
       bttn.setTitle("Done".localized(), for: .normal)
       bttn.backgroundColor = .gray
       bttn.backgroundColor = UIColor(red: 82/255, green: 150/255, blue: 213/255, alpha: 1.0)
       bttn.addTarget(self, action: #selector(seeAllDealsTapped), for: .touchUpInside)
       bttn.layer.cornerRadius = 5
       return bttn
   }()
    @objc func seeAllDealsTapped(sender: UIButton){
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
        }
//        guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? TabBarViewController else {return}
//        tabBarController.selectedIndex = 2
//        let dealsContentVC = tabBarController.viewControllers?[2]
        
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "askToRefresh"), object: nil, userInfo: nil)

//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshHere"), object: nil, userInfo: nil)
    }
    //MARK: - Handle Links
    
    func makeURLBlue(url: URL?) {
        if url != nil {
            labelTitle.textColor = .blue
        } else {
            return
        }
    }
    func addGestureToContent(){
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(dealDescTapped))
        labelContent.addGestureRecognizer(tapViewGesture)
        labelTitle.addGestureRecognizer(tapViewGesture)
        labelContent.isUserInteractionEnabled = true
        labelTitle.isUserInteractionEnabled = true
    }
    @objc func dealDescTapped() {
        
        let url = URL(string: self.labelTitle.text ?? self.labelContent.text ?? "https://www.weeklyads2.com/")
        
        let verificationofURL = verifyUrl(urlString: url?.absoluteString)
        if url != nil, verificationofURL == true {
            let alert = UIAlertController(title: "You are leaving Depple?".localized(), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: { action in
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                
                let weeklyads2 = URL(string: "https://www.weeklyads2.com/")
                let vc = SFSafariViewController(url: url ?? weeklyads2!, configuration: config)
                self.present(vc, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Try Again Later".localized(), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                print("url not valid or nil")
            }))
            self.present(alert, animated: true, completion: nil)
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
    
    
    //MARK: - Handle Full Screen
    func configureImageFullScreen(){
        dealImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dealImageTapped))
        dealImage.addGestureRecognizer(tap)
    }
    @objc func dealImageTapped(sender: UITapGestureRecognizer){
        print("dealImageTapped")
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
//        newImageView.frame = UIScreen.main.bounds
        newImageView.frame = view.safeAreaLayoutGuide.layoutFrame
//        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    
    func configureConst(){
        view.addSubview(seeAllDealsButton)
        view.addSubview(labelContent)
        view.addSubview(labelTitle)
        view.addSubview(dealImage)
        view.addSubview(labelMessage)
        view.addSubview(labelStoreTitle)
        labelStoreTitle.text = "\(dealString) \(storeTitle)"
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
            seeAllDealsButton.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-40)
            seeAllDealsButton.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(40)
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


