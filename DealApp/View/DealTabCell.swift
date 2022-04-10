import UIKit
import SnapKit
import RxDataSources
import RxSwift
import Firebase

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
    let db = Firestore.firestore()
    var senderEmail: String? = Auth.auth().currentUser?.email
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
    lbl.font = UIFont(name: "Optima-Regular", size: 20)
    lbl.textAlignment = .natural
    lbl.numberOfLines = 0
    lbl.textColor = UIColor(red: 194/255, green: 199/255, blue: 219/255, alpha: 1.0)
    lbl.textAlignment = .left
    lbl.backgroundColor = .clear
    return lbl
    }()
    var dealDesc : UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont(name: "Optima-Regular", size: 15)
    lbl.textColor = UIColor(red: 194/255, green: 199/255, blue: 219/255, alpha: 1.0)
    lbl.textAlignment = .natural
    lbl.numberOfLines = 0
    lbl.textAlignment = .left
    lbl.backgroundColor = .clear
    return lbl
    }()
    var sender : UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont(name: "Optima-Bold", size: 12)
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
        let subColRef = db.collection("dealsCollection").document(storeTitle).collection("deals")
        subColRef.document(dealID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Deal Document successfully removed!")
            }
        }
    }
    
    func configureConstraints(){
        print("configureConstraints")
        self.contentView.addSubview(dealImage)
        self.contentView.addSubview(dealTitle)
        self.contentView.addSubview(dealDesc)
        self.contentView.addSubview(deleteDealFromFirebase)
        self.contentView.addSubview(sender)
        self.contentView.backgroundColor = UIColor(red: 65/255, green: 76/255, blue: 97/255, alpha: 0.8)
        
        dealImage.snp.makeConstraints { dealImage in
            dealImage.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 240))
        }
        dealTitle.snp.makeConstraints { dealTitle in
            dealTitle.right.equalTo(self.contentView.snp.right).offset(-5)
            dealTitle.left.equalTo(dealImage.snp.right).offset(28)
            dealTitle.top.equalTo(self.contentView.snp.top).offset(2)
            dealTitle.bottom.equalTo(self.contentView.snp.bottom).offset(-90)
        }
        dealDesc.snp.makeConstraints { dealDesc in
            dealDesc.right.equalTo(self.contentView.snp.right).offset(-5)
            dealDesc.left.equalTo(dealImage.snp.right).offset(28)
            dealDesc.top.equalTo(dealTitle.snp.bottom).offset(2)
            dealDesc.bottom.equalTo(self.contentView.snp.bottom).offset(-25)
        }
        deleteDealFromFirebase.snp.makeConstraints { deleteDealFromFirebase in
            deleteDealFromFirebase.right.equalTo(self.contentView).offset(-15)
            deleteDealFromFirebase.left.equalTo(dealImage.snp.right).offset(205)
            deleteDealFromFirebase.bottom.equalTo(self.contentView).offset(-5)
            deleteDealFromFirebase.top.equalTo(dealDesc.snp.bottom).offset(2)
        }
        sender.snp.makeConstraints { sender in
            sender.right.equalTo(deleteDealFromFirebase.snp.left).offset(-2)
            sender.left.equalTo(dealImage.snp.right).offset(28)
            sender.bottom.equalTo(self.contentView).offset(-5)
            sender.top.equalTo(dealDesc.snp.bottom).offset(2)
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
        self.contentView.backgroundColor = .gray
        
        // Center the image vertically and place it near the leading
        // edge of the view. Constrain its width and height to 50 points.
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
