import UIKit
import SnapKit
import RxDataSources
import RxSwift
import Firebase
import FirebaseStorage

protocol CreateAlert: class {
    func deleteDealAlert(data: forDelete)
}
protocol PushProfilePage: class {
    func pushProfilePage(vc: UIViewController)
}
protocol BlockUser: class {
    func blockUser(user: BlockedData)
}

struct forDelete {
    var storeTitle = String()
    var storeID = String()
    var dealID = String()
}

class DealTabCell: UITableViewCell {
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureConstraints()
        
        runTimer()
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.senderTapped))
        sender.addGestureRecognizer(tapViewGesture)
        sender.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(stopTimer), name: NSNotification.Name(rawValue: "stopTimer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadSavedTime), name: NSNotification.Name(rawValue: "savedTime"), object: nil)
    }
    
    @objc func stopTimer(){
        timer.invalidate()
    }
    

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
              contentView.frame = contentView.frame.inset(by: margins)
              contentView.layer.cornerRadius = 8
    }
//MARK: - Properties
    let userDefaults = UserDefaults.standard
    let START_TIME_KEY = "startTime"
    var isTimerRunning = false
    var seconds = 10
    var timer = Timer()
    var disposeBag = DisposeBag()
    weak var delegate: CreateAlert?
    weak var delegate2: CreateAlert?
    weak var delegate3: PushProfilePage?
    weak var delegate4: BlockUser?
    var btnTapClosure: ((DealTabCell)->())?
    let db = Firestore.firestore()
    private let storage = Storage.storage()
    var currentEmail: String? = Auth.auth().currentUser?.email
    var emailSender: String?
    var userName: String?
    var senderUID: String?
    var storeID = String()
    var storeTitle = String()
    var dealID = String()
    private var separatorContentView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var buttonandViewSeparator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var dealTitleandDealDescViewSeparator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var dealTitleandDealDescView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var buttonAndLabelView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var buttonAndLabelViewSeparator: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var buttonsView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()

    private var imageViewPart: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    private var buttonandTextView: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    
    let dealImage : UIImageView = {
    let imgView = UIImageView()
    imgView.contentMode = .scaleAspectFill
    imgView.clipsToBounds = true
    imgView.layer.cornerRadius = 8.0
    imgView.backgroundColor = .clear
    return imgView
    }()

    var dealTitle : UILabel = {
    let lbl = UILabel()
//    lbl.font = UIFont(name: "Optima-Regular", size: 20)
    lbl.font = UIFont.systemFont(ofSize: 18)
    lbl.numberOfLines = 0
//    lbl.textColor = UIColor(red: 194/255, green: 199/255, blue: 219/255, alpha: 1.0)
    lbl.textColor = .black
    lbl.textAlignment = .natural
        
    lbl.backgroundColor = .clear
    return lbl
    }()
    private var dealDesc : UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 12)
    lbl.textColor = .black
    lbl.textAlignment = .natural
    lbl.backgroundColor = .clear
    return lbl
    }()
    var storeLabel : UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 10)
    lbl.textColor = .black
    lbl.textAlignment = .natural
    lbl.numberOfLines = 0
    lbl.textAlignment = .left
    lbl.backgroundColor = .clear
    return lbl
    }()
    var sender : UILabel = {
    let lbl = UILabel()
//    lbl.font = UIFont(name: "Optima-Bold", size: 12)
    lbl.font = UIFont.boldSystemFont(ofSize: 12)
    lbl.textAlignment = .natural
    lbl.numberOfLines = 0
    lbl.textColor = UIColor(red: 194/255, green: 199/255, blue: 219/255, alpha: 1.0)
//    lbl.textColor = .systemBlue
    lbl.textAlignment = .left
    lbl.backgroundColor = .clear
    return lbl
    }()
    lazy var deleteDealFromFirebase: UIButton = {
       var deleteDeal = UIButton()
       let image = UIImage(named: "icons8-minus-50") as UIImage?
       deleteDeal.setImage(image, for: .normal)
       deleteDeal.backgroundColor = .clear
       deleteDeal.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
       return deleteDeal
   }()
    lazy var share: UIButton = {
       var shr = UIButton()
       let image = UIImage(named: "icons8-share-3-50") as UIImage?
       shr.setImage(image, for: .normal)
       shr.backgroundColor = .clear
       shr.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
       return shr
   }()
    lazy var like: UIButton = {
       var shr = UIButton()
       let image = UIImage(named: "icons8-heart-100") as UIImage?
       shr.setImage(image, for: .normal)
       shr.backgroundColor = .clear
       shr.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
       return shr
   }()
    lazy var block: UIButton = {
       var shr = UIButton()
       let image = UIImage(named: "icons8-hide-100") as UIImage?
       shr.setImage(image, for: .normal)
       shr.backgroundColor = .clear
       shr.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
       return shr
   }()
    
    @objc func reportTapped(){
        
        delegate4?.blockUser(user: BlockedData(id: senderUID, name: userName))
        
        let docRef = db.collection("favStoreCollection").document(senderUID ?? "")
        docRef.updateData(["BlockCounter" : FieldValue.increment(Int64(1))])
        
        //add report number to the deal model.
        //add field to favStoreCollection "Blocks": Int
        //query favStoreCollection in postDealVC
        //if blocks field exceeds 15 don't let the user post anything
    }
  
    lazy var timerLabel : UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 13)
    lbl.textColor = .black
    lbl.textAlignment = .center
    return lbl
    }()

    
    //MARK: - Button Methods
    
    @objc func senderTapped(){
        print("senderTapped")
        print("senderUID = \(senderUID)")
        let profilepage = Profile(senderUID: senderUID ?? "")
        profilepage.tableView.isHidden = true

        profilepage.profilePic.isUserInteractionEnabled = false


        profilepage.latestPostsby.text = ""
        profilepage.devlin = true
        self.delegate3?.pushProfilePage(vc: profilepage)
//        self.present(profilepage, animated: true, completion: nil)
    }

    @objc func likeTapped(sender: UIButton){
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
        }
        print("like tapped")
        print("senderUID  = \(senderUID ?? "")")
        
        let ref = db.collection("favStoreCollection").document(senderUID ?? "")
        ref.updateData(["Likes" : FieldValue.increment(Int64(1))])
        
        
        
        }
    @objc func shareTapped(){
        btnTapClosure?(self)
    }
    @objc func deleteTapped(_ sender: UIButton) {
        print("deleteTapped")
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
        }
        print("dealID = \(dealID)")
        print("store ID = \(storeID)")
        print("storeTitle = \(storeTitle)")
        delegate?.deleteDealAlert(data: forDelete(storeTitle: storeTitle, storeID: storeID, dealID: dealID))
        delegate2?.deleteDealAlert(data: forDelete(storeTitle: storeTitle, storeID: storeID, dealID: dealID))
    }
    
    //MARK: - Constraints
    func configureConstraints(){
        print("configureConstraints")
        contentView.addSubview(separatorContentView)
        contentView.addSubview(buttonandTextView)
        contentView.addSubview(imageViewPart)
        
        imageViewPart.addSubview(dealImage)
        imageViewPart.addSubview(timerLabel)
        
       
        contentView.addSubview(block)
        
        buttonandTextView.addSubview(buttonandViewSeparator)
        buttonandTextView.addSubview(buttonAndLabelView)
        buttonandTextView.addSubview(dealTitleandDealDescView)
        
        dealTitleandDealDescView.addSubview(dealTitleandDealDescViewSeparator)
        dealTitleandDealDescView.addSubview(dealTitle)
        dealTitleandDealDescView.addSubview(dealDesc)
        
        buttonAndLabelView.addSubview(buttonAndLabelViewSeparator)
        buttonAndLabelView.addSubview(storeLabel)
        buttonAndLabelView.addSubview(sender)
        buttonandTextView.addSubview(like)
        buttonandTextView.addSubview(share)
        buttonandTextView.addSubview(deleteDealFromFirebase)

        
//        self.contentView.backgroundColor = UIColor(red: 65/255, green: 76/255, blue: 97/255, alpha: 0.8)
//        contentView.backgroundColor = UIColor(red: 108/255, green: 106/255, blue: 117/255, alpha: 0.8)
        separatorContentView.snp.makeConstraints { separatorX in
            separatorX.width.equalTo(1)
            separatorX.height.equalTo(1)
            separatorX.centerY.equalTo(contentView)
            separatorX.centerX.equalTo(contentView)
        }
        // imageview and timerlabel Part
        imageViewPart.snp.makeConstraints { imageViewPart in
            imageViewPart.top.equalTo(contentView)
            imageViewPart.bottom.equalTo(contentView)
            imageViewPart.right.equalTo(separatorContentView)
            imageViewPart.left.equalTo(contentView)
        }
        dealImage.snp.makeConstraints { dealImage in
            dealImage.height.equalTo(100)
            dealImage.width.equalTo(100)
            dealImage.centerX.equalTo(imageViewPart)
            dealImage.centerY.equalTo(imageViewPart)
        }
        timerLabel.snp.makeConstraints { timerLabel in
            timerLabel.top.equalTo(dealImage.snp.bottom)
            timerLabel.bottom.equalTo(imageViewPart)
            timerLabel.right.equalTo(separatorContentView)
            timerLabel.left.equalTo(imageViewPart)
        }
        //buttons and content
        buttonandTextView.snp.makeConstraints { buttonandTextView in
            buttonandTextView.top.equalTo(contentView)
            buttonandTextView.bottom.equalTo(contentView)
            buttonandTextView.right.equalTo(contentView)
            buttonandTextView.left.equalTo(separatorContentView)
        }
        buttonandViewSeparator.snp.makeConstraints { buttonandViewSeparator in
            buttonandViewSeparator.width.equalTo(1)
            buttonandViewSeparator.height.equalTo(1)
            buttonandViewSeparator.centerY.equalTo(buttonandTextView)
            buttonandViewSeparator.centerX.equalTo(buttonandTextView)
        }
        
        dealTitleandDealDescView.snp.makeConstraints { dealTitleandDealDescView in
            dealTitleandDealDescView.top.equalTo(buttonandTextView)
            dealTitleandDealDescView.bottom.equalTo(buttonandViewSeparator)
            dealTitleandDealDescView.right.equalTo(buttonandTextView)
            dealTitleandDealDescView.left.equalTo(buttonandTextView)
        }
        dealTitleandDealDescViewSeparator.snp.makeConstraints { dealTitleandDealDescViewSeparator in
            dealTitleandDealDescViewSeparator.width.equalTo(1)
            dealTitleandDealDescViewSeparator.height.equalTo(1)
            dealTitleandDealDescViewSeparator.centerY.equalTo(dealTitleandDealDescView)
            dealTitleandDealDescViewSeparator.centerX.equalTo(dealTitleandDealDescView)
        }
        dealTitle.snp.makeConstraints { dealTitle in
            dealTitle.top.equalTo(dealTitleandDealDescView)
            dealTitle.bottom.equalTo(dealTitleandDealDescViewSeparator)
            dealTitle.right.equalTo(dealTitleandDealDescView)
            dealTitle.left.equalTo(dealTitleandDealDescView)
        }
        dealDesc.snp.makeConstraints { dealDesc in
            dealDesc.top.equalTo(dealTitleandDealDescViewSeparator)
            dealDesc.bottom.equalTo(dealTitleandDealDescView)
            dealDesc.right.equalTo(dealTitleandDealDescView)
            dealDesc.left.equalTo(dealTitleandDealDescView)
        }
        
        
        buttonAndLabelView.snp.makeConstraints { buttonAndLabelView in
            buttonAndLabelView.top.equalTo(buttonandViewSeparator)
            buttonAndLabelView.bottom.equalTo(buttonandTextView)
            buttonAndLabelView.right.equalTo(buttonandTextView)
            buttonAndLabelView.left.equalTo(buttonandTextView)
        }
        buttonAndLabelViewSeparator.snp.makeConstraints { buttonAndLabelViewSeparator in
            buttonAndLabelViewSeparator.width.equalTo(1)
            buttonAndLabelViewSeparator.height.equalTo(1)
            buttonAndLabelViewSeparator.centerY.equalTo(buttonAndLabelView)
            buttonAndLabelViewSeparator.centerX.equalTo(buttonAndLabelView)
        }
        storeLabel.snp.makeConstraints { storeLabel in
            storeLabel.top.equalTo(buttonAndLabelView)
            storeLabel.bottom.equalTo(buttonAndLabelViewSeparator)
            storeLabel.right.equalTo(buttonAndLabelView)
            storeLabel.left.equalTo(buttonAndLabelView)
        }
        sender.snp.makeConstraints { sender in
            sender.top.equalTo(storeLabel.snp.bottom)
            sender.bottom.equalTo(buttonAndLabelView)
            sender.right.equalTo(buttonAndLabelViewSeparator)
            sender.left.equalTo(buttonAndLabelView)
        }
        like.snp.makeConstraints { like in
            like.height.equalTo(20)
            like.width.equalTo(20)
            like.left.equalTo(buttonAndLabelViewSeparator)
            like.bottom.equalTo(buttonAndLabelView).offset(-5)
        }
        share.snp.makeConstraints { share in
            share.height.equalTo(20)
            share.width.equalTo(20)
            share.left.equalTo(like.snp.right).offset(5)
            share.bottom.equalTo(buttonAndLabelView).offset(-5)
        }
        deleteDealFromFirebase.snp.makeConstraints { deleteDealFromFirebase in
            deleteDealFromFirebase.height.equalTo(20)
            deleteDealFromFirebase.width.equalTo(20)
            deleteDealFromFirebase.left.equalTo(share.snp.right).offset(5)
            deleteDealFromFirebase.bottom.equalTo(buttonAndLabelView).offset(-5)
        }
        block.snp.makeConstraints { block in
            block.height.equalTo(20)
            block.width.equalTo(20)
            block.left.equalTo(deleteDealFromFirebase.snp.right).offset(5)
            block.bottom.equalTo(buttonAndLabelView).offset(-5)
        }
    }
//MARK: - Timer

    func runTimer() {
         timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//                self?.updateTimer()
//                }
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
    
    @objc func loadSavedTime(){
        var howManySecondsPassedinBackground = Double()
        let savedSecond = userDefaults.object(forKey: START_TIME_KEY) as? Double
        howManySecondsPassedinBackground = Date().timeIntervalSince1970 - (savedSecond ?? 0.00)
        if savedSecond != nil {
            seconds -= Int(howManySecondsPassedinBackground)
        }
    }
    
    @objc func updateTimer(){
        if seconds > 0 {
            seconds -= 1     //This will decrement(count down)the seconds.
        }
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds)
        if h == 0, m == 0, s == 0 {
            timerLabel.text = "Expired"
            timerLabel.textColor = .red
        } else {
            timerLabel.text = "Ends in \(h):\(m):\(s)" //This will update the label.
            timerLabel.textColor = .black
//            print("timer tick tock = \(timerLabel.text ?? "")")
        }
    }
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    //MARK: - Data Configuration
    func configureWithData(dataModel: SectionOfCustomData.Item) {
        dealImage.image = dataModel.dealImage
        dealTitle.text = dataModel.dealTitle
        dealDesc.text = dataModel.dealDesc
        
        
        if dataModel.sender != currentEmail {
            self.deleteDealFromFirebase.isHidden = true
            block.isHidden = false
        } else {
            self.deleteDealFromFirebase.isHidden = false
            block.isHidden = true
        }
    }
    func configureProfile(dataModel: DealModel) {
        dealImage.image = dataModel.dealImage
        dealTitle.text = dataModel.dealTitle
        dealDesc.text = dataModel.dealDesc
//        deleteDealFromFirebase.isHidden = true
    }
    func configureStoreDeals(dataModel: DealModel) {
        dealImage.image = dataModel.dealImage
        dealTitle.text = dataModel.dealTitle
        dealDesc.text = dataModel.dealDesc
    }
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
//MARK: - Below is a custom section header taken from Apple doc.
class MyCustomHeader: UITableViewHeaderFooterView {
    let title = UILabel()
    let image = UIImageView()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureContents() {
        image.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        contentView.backgroundColor = .white

        
        title.snp.makeConstraints { title in
            title.top.equalTo(contentView.safeAreaLayoutGuide)
            title.bottom.equalTo(contentView.safeAreaLayoutGuide)
            title.centerX.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
}
