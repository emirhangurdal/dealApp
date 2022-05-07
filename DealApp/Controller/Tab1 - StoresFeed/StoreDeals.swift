import UIKit
import SnapKit
import RxCocoa
import RxSwift
import FirebaseAuth
import Firebase

// the place user goes when they tap on a cell on the StoreSfeed.
class StoreDeals: UIViewController, UIScrollViewDelegate, UITableViewDelegate {
    override func viewDidLoad() {
        view.backgroundColor = .white
        print("DealsVC")
        print("storeDetail = \(storeDetail)")
        configureConstraints()
        configureTV()
        bindTV()
    }
    let detailView = UIView()
    var strDeals = StrDeals()
    private let storage = Storage.storage()
    let db = Firestore.firestore()
    lazy var tableView = UITableView()
    var storeDetail = StoresFeedModel()
    var detailLabel: UILabel = {
        var lbl = UILabel()
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.backgroundColor = .white
        lbl.numberOfLines = 0
        return lbl
    }()
    var tableViewTitle: UILabel = {
        var lbl = UILabel()
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.backgroundColor = .white
        lbl.numberOfLines = 0
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        lbl.text = "Store's Deals"
        return lbl
    }()
    let storeImage : UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = .clear
        return imgView
    }()
    var dealCellID = "DealCellID"
    private let disposeBag = DisposeBag()
    init(storeDetail: StoresFeedModel) {
        self.storeDetail = storeDetail
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    
    //MARK: - Tableview Configure and Rx Bind and Firebase Data
    func configureTV(){
        tableView.register(DealTabCell.self, forCellReuseIdentifier: dealCellID)
        tableView.separatorStyle = .none
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        view.addSubview(tableView)
        tableView.backgroundColor = .gray
        view.addSubview(tableViewTitle)
        tableView.snp.makeConstraints { tableView in
            tableView.top.equalTo(detailView.snp.bottom).offset(40)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
            tableView.right.equalTo(view.safeAreaLayoutGuide)
            tableView.left.equalTo(view.safeAreaLayoutGuide)
        }
        tableViewTitle.snp.makeConstraints { tableViewTitle in
            tableViewTitle.bottom.equalTo(tableView.snp.top)
            tableViewTitle.top.equalTo(detailView.snp.bottom)
            tableViewTitle.right.equalTo(view.safeAreaLayoutGuide)
            tableViewTitle.left.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func bindTV(){
        strDeals.strDealsRelay.asObservable()
            .bind(to: tableView
                    .rx
                    .items(cellIdentifier: dealCellID, cellType: DealTabCell.self)
            )
        {
            row, storeDealsData, cell in
            cell.configureStoreDeals(dataModel: storeDealsData)
            cell.deleteDealFromFirebase.isHidden = true
        }
        .disposed(by: disposeBag)
        getDataFromFireBase()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    func getDataFromFireBase(){
        let senderEmail: String? = Auth.auth().currentUser?.email
        print(senderEmail!)
        let dealsCol = self.db.collection("dealsCollection")
        dealsCol.addSnapshotListener { querySnapShot, error in
            if let err = error {
                print("err = \(err)")
            } else {
                self.strDeals.strDeals.removeAll()
                for document in querySnapShot!.documents {
                    print("store doc = \(document.documentID)")
                    let dealRef = dealsCol.document(document.documentID).collection("deals")
                    let query = dealRef.whereField("StoreID", isEqualTo: self.storeDetail.id)
                    query.addSnapshotListener { querySnapShot, error in
                        if let err = error {
                            print("error reading senderDeals = \(err)")
                        } else {
                            for document in querySnapShot!.documents {
                              
                                let data = document.data()
                                if let sender = data["Sender"] as? String,
                                   let image = data["ImagePath"] as? String,
                                   let dealTitle = data["DealTitle"] as? String,
                                   let dealDesc = data["DealDesc"] as? String,
                                   let storeID = data["StoreID"] as? String,
                                   let storeTitle = data["StoreTitle"] as? String,
                                   let dealID = data["DealID"] as? String,
                                   let userName = data["UserName"] as? String {
                                
                                } else {
                                    print("something wrong with if let sender")
                                }
                            }
                        }
                        querySnapShot?.documentChanges.enumerated().forEach { indexDeal, diff in
                            if (diff.type == .added) {
                                let data = diff.document.data()
                                if let sender = data["Sender"] as? String,
                                   let image = data["ImagePath"] as? String,
                                   let dealTitle = data["DealTitle"] as? String,
                                   let dealDesc = data["DealDesc"] as? String,
                                   let storeID = data["StoreID"] as? String,
                                   let storeTitle = data["StoreTitle"] as? String,
                                   let dealID = data["DealID"] as? String,
                                   let userName = data["UserName"] as? String,
                                   let distance = data["Distance"] as? Double {
                                    self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, dealID: dealID, sender: sender, userName: userName, distance: distance)
                                    } else {
                                    print("something wrong with if let in added.")
                                
                                }
                                if (diff.type == .removed) {
//
//                                    let data = diff.document.data()
//                                    print("if (diff.type == .removed)")
//                                    if let dealID = data["DealID"] as? String {
//                                        self.strDeals.strDeals.removeAll(where: {$0.dealID == dealID })
//                                        print("Dealsdata after deleted deal = \(DealsData.shared.dealsArray)")
//                                        DispatchQueue.main.async {
//                                            self.strDeals.strDealsRelay.accept(self.strDeals.strDeals)
//                                        }
//                                    } else {
//                                        print("something wrong with .removed")
//                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func getImageFromURLfromFirebase(path: String, dealTitle: String, dealDesc: String, storeTitle: String, storeID: String, dealID: String, sender: String, userName: String, distance: Double){
        print("getimagefromURL")
        let storageRef = storage.reference()
        let dealImageRef = storageRef.child(path)
        dealImageRef.downloadURL { url, error in
            guard error == nil else {
                print("error downloading image = \(error)")
                return
            }
            downloadImageWithURL(url: url!)
        }
        func downloadImageWithURL(url: URL) {
            let dealImageView = UIImageView()
            dealImageView.downloadImage(from: "\(url)") { response in
                print("downloadImageWithURL")
                self.strDeals.strDeals.append(DealModel(storeID: storeID, dealImage: response.image, dealTitle: dealTitle, dealDesc: dealDesc, dealID: dealID, storeTitle: storeTitle, sender: sender, userName: userName, distance: distance))
                DispatchQueue.main.async {
                    self.strDeals.strDealsRelay.accept(self.strDeals.strDeals)
                }
            }
        }
    }
    //MARK: - Constraint and Content of Labels/Units.
    func configureConstraints(){
        // configure content
        storeImage.downloaded(from: storeDetail.image)
        detailLabel.attributedText = NSMutableAttributedString()
            .bold("\(storeDetail.title)\n")
            .normal("\(storeDetail.address1)\(storeDetail.address2)")
        //configure constraints.
        view.addSubview(detailView)
        detailView.backgroundColor = .white
        detailView.addSubview(storeImage)
        detailView.addSubview(detailLabel)
        let white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        let dimGray = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 0.5)
        detailView.layer.borderColor = dimGray.cgColor
        detailView.layer.borderWidth = 2.0
        detailView.layer.masksToBounds = true
        detailView.layer.cornerRadius = 5
        detailView.snp.makeConstraints { detailView in
            detailView.height.equalTo(200)
            detailView.width.equalTo(350)
            detailView.centerX.equalTo(view.safeAreaLayoutGuide)
            detailView.centerY.equalTo(view.safeAreaLayoutGuide).offset(-200)
        }
        storeImage.snp.makeConstraints { storeImage in
            storeImage.top.equalTo(detailView)
            storeImage.bottom.equalTo(detailView)
            storeImage.left.equalTo(detailView)
            storeImage.right.equalTo(detailView).offset(-150)
        }
        detailLabel.snp.makeConstraints { detailLabel in
            detailLabel.top.equalTo(detailView).offset(10)
            detailLabel.bottom.equalTo(detailView).offset(-10)
            detailLabel.right.equalTo(detailView)
            detailLabel.left.equalTo(storeImage.snp.right).offset(5)
        }
    }
    
    
}
