import UIKit
import SnapKit
import RxDataSources
import RxSwift
import Firebase
import FirebaseStorage

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
    var btnTapClosure: ((DealTabCell)->())?
    let db = Firestore.firestore()
    private let storage = Storage.storage()
    var senderEmail: String? = Auth.auth().currentUser?.email
    var senderUID: String?
    var storeID = String()
    var storeTitle = String()
    var dealID = String()
    let dealImage : UIImageView = {
    let imgView = UIImageView()
    imgView.contentMode = .scaleAspectFit
    imgView.backgroundColor = .clear
    imgView.clipsToBounds = true
    imgView.layer.cornerRadius = 15
    return imgView
    }()
    var dealTitle : UILabel = {
    let lbl = UILabel()
//    lbl.font = UIFont(name: "Optima-Regular", size: 20)
    lbl.font = UIFont.boldSystemFont(ofSize: 25)
    lbl.textAlignment = .natural
    lbl.numberOfLines = 0
//    lbl.textColor = UIColor(red: 194/255, green: 199/255, blue: 219/255, alpha: 1.0)
        lbl.textColor = .black
    lbl.textAlignment = .left
    lbl.backgroundColor = .clear
    return lbl
    }()
    var dealDesc : UILabel = {
    let lbl = UILabel()
//    lbl.font = UIFont(name: "Optima-Regular", size: 15)
    lbl.font = UIFont.boldSystemFont(ofSize: 15)
//    lbl.textColor = UIColor(red: 194/255, green: 199/255, blue: 219/255, alpha: 1.0)
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
        if Auth.auth().currentUser != nil {
            print("Auth.auth().currentUser?.email = \(Auth.auth().currentUser?.email!)")
        }
        let subColRef = db.collection("dealsCollection").document(storeID).collection("deals")
        subColRef.document(dealID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Deal Document successfully removed!")
            }
        }
        let dealImageRef = storage.reference().child("/deals/\(storeTitle)/\(dealID)")
        dealImageRef.delete { error in
            if let error = error {
             } else {
               print("file deleted successfully")
             }
        }
        
        let storeRef = self.db.collection("dealsCollection").document(storeID)
        storeRef.updateData(["DealCount" : FieldValue.increment(Int64(-1))])
    }
    func configureConstraints(){
        print("configureConstraints")
        self.contentView.addSubview(dealImage)
        self.contentView.addSubview(dealTitle)
        self.contentView.addSubview(dealDesc)
        self.contentView.addSubview(deleteDealFromFirebase)
        self.contentView.addSubview(sender)
        self.contentView.addSubview(share)
        self.contentView.addSubview(like)
//        self.contentView.backgroundColor = UIColor(red: 65/255, green: 76/255, blue: 97/255, alpha: 0.8)
//        contentView.backgroundColor = UIColor(red: 108/255, green: 106/255, blue: 117/255, alpha: 0.8)
        dealImage.snp.makeConstraints { dealImage in
            dealImage.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 240))
        }
        dealTitle.snp.makeConstraints { dealTitle in
            dealTitle.right.equalTo(self.contentView.snp.right).offset(-5)
            dealTitle.left.equalTo(dealImage.snp.right).offset(28)
            dealTitle.top.equalTo(self.contentView.snp.top).offset(2)
            dealTitle.bottom.equalTo(self.contentView.snp.bottom).offset(-100)
        }
        dealDesc.snp.makeConstraints { dealDesc in
            dealDesc.right.equalTo(self.contentView.snp.right).offset(-5)
            dealDesc.left.equalTo(dealImage.snp.right).offset(28)
            dealDesc.top.equalTo(dealTitle.snp.bottom).offset(2)
            dealDesc.bottom.equalTo(self.contentView.snp.bottom).offset(-30)
        }
        deleteDealFromFirebase.snp.makeConstraints { deleteDealFromFirebase in
            deleteDealFromFirebase.height.equalTo(20)
            deleteDealFromFirebase.width.equalTo(20)
            deleteDealFromFirebase.left.equalTo(dealImage.snp.right).offset(205)
            deleteDealFromFirebase.bottom.equalTo(self.contentView).offset(-5)
        }
        sender.snp.makeConstraints { sender in
            sender.right.equalTo(share.snp.left).offset(-2)
            sender.left.equalTo(dealImage.snp.right).offset(28)
            sender.bottom.equalTo(self.contentView).offset(-5)
            sender.top.equalTo(dealDesc.snp.bottom).offset(2)
        }
        share.snp.makeConstraints { share in
            share.height.equalTo(20)
            share.width.equalTo(20)
            share.right.equalTo(deleteDealFromFirebase.snp.left).offset(-5)
            share.bottom.equalTo(self.contentView).offset(-5)
        }
        like.snp.makeConstraints { like in
            like.height.equalTo(20)
            like.width.equalTo(20)
            like.right.equalTo(share.snp.left).offset(-5)
            like.bottom.equalTo(self.contentView).offset(-5)
        }
    }
    func configureWithData(dataModel: SectionOfCustomData.Item) {
        dealImage.image = dataModel.dealImage
        dealTitle.text = dataModel.dealTitle
        dealDesc.text = dataModel.dealDesc
        print("senderEmail DealTabCell = \(senderEmail)")
        if dataModel.sender != senderEmail {
            self.deleteDealFromFirebase.isHidden = true
        } else {
            self.deleteDealFromFirebase.isHidden = false
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
        contentView.addSubview(image)
        contentView.addSubview(title)
        self.contentView.backgroundColor = .white
        
        // Center the image vertically and place it near the leading
        // edge of the view. Constrain its width and height to 50 points
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            image.widthAnchor.constraint(equalToConstant: 50),
            image.heightAnchor.constraint(equalToConstant: 50),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            // Center the label vertically, and use it to fill the remaining
            // space in the header view.
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: image.trailingAnchor,
                   constant: 8),
            title.trailingAnchor.constraint(equalTo:
                   contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
