import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Firebase
//where all the deals are collected in a tableview feed. Tableview is sectioned.
class DealsContentVC: UIViewController, UIScrollViewDelegate, UITableViewDelegate {
    override func viewDidLoad() {
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        configureConstraints()
        tableView.register(DealTabCell.self, forCellReuseIdentifier: dealCellID)
        tableView.register(MyCustomHeader.self,
                           forHeaderFooterViewReuseIdentifier: "sectionHeader")
        print("DealsContentVC")
        loadDealsDataFromFirebase()
        setupDataSource()
//        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
//        changeRequest?.displayName = "lazyPerson"
//        changeRequest?.commitChanges(completion: { error in
//            if let err = error {
//                print("error changing display name = \(err)")
//            }
//        })
        print("displayname ? \(Auth.auth().currentUser?.displayName)")
    }
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData> (
        configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "DealCellID", for: indexPath) as! DealTabCell
            cell.configureWithData(dataModel: item)
            cell.dealID = item.dealID ?? "No deal ID found, empty or nil"
            cell.storeID = item.storeID ?? "No Store ID found, empty or nil"
            cell.storeTitle = item.storeTitle ?? "No Store Title"
            cell.sender.text = "@\(item.userName ?? "A User")"
            return cell
        })
    let g = DispatchGroup()
    private let storage = Storage.storage()
    let db = Firestore.firestore()
    var spinner = SpinnerViewController()
    lazy var tableView = UITableView()
    private let disposeBag = DisposeBag()
    var dealCellID = "DealCellID"
    var deals = DealsData()
    let userName = Auth.auth().currentUser?.displayName
    //MARK: - Cell Configuration, Binding, Selection Handling
    func setupDataSource(){
        dataSource.titleForHeaderInSection = { ds, section in
            return "Deals @ \(ds.sectionModels[section].header)"
        }
        DealsData.shared.dealsData.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        tableView.rx
            .modelSelected(DealModel.self)
            .subscribe(onNext:  { value in
            })
            .disposed(by: disposeBag)
        //        tableView.rx
        //                   .itemSelected
        //                   .map { indexPath in
        //                       return (indexPath, dataSource[indexPath])
        //                   }
        //                   .subscribe(onNext: { pair in
        //
        //                   })
        //                   .disposed(by: disposeBag)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("didselectrow")
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                                                                "sectionHeader") as! MyCustomHeader
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 10
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 10    //if you want round edges
        maskLayer.backgroundColor = UIColor.blue.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
    func configureConstraints(){
        self.title = "DealsContentVC"
        view.backgroundColor = .white
        self.tabBarItem.title = ""
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(red: 58/255, green: 67/255, blue: 86/255, alpha: 1.0)
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { tableView in
            tableView.right.equalTo(view.safeAreaLayoutGuide)
            tableView.left.equalTo(view.safeAreaLayoutGuide)
            tableView.top.equalTo(view).offset(100)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func loadDealsDataFromFirebase(){
        //.document(store).collection("deals")
        print("loadDealsDataFromFirebase")
        
        let docRef = db
            .collection("dealsCollection")
        docRef.addSnapshotListener { (querySnapShot, err) in
            if let err = err {
                print("error listening = \(err)")
            } else {
                DealsData.shared.dealsArray.removeAll()
                querySnapShot!.documents.enumerated().forEach { indexS, storeDocument in
                    let storeData = storeDocument.data()
                    let subColRef = self.db.collection("dealsCollection/\(storeDocument.documentID)/deals")
                    DealsData.shared.dealsArray.append(SectionOfCustomData(header: storeDocument.documentID, items: [DealModel(storeID: "storeID", dealImage: UIImage(named: "ExampleDeal"), dealTitle: "No Deals at This Store", dealDesc: "\(storeDocument.documentID) has no deals yet.", dealID: "dealID", storeTitle: "storeTitle", sender: "sender email", userName: "user name")]))
                    print("DealsData initial append == \(DealsData.shared.dealsArray)")
                    subColRef.addSnapshotListener { querySnapShot, error in
                        if let err = error {
                            print("error in subColRef = \(err)")
                        } else {
                            guard let snapshot = querySnapShot else {
                                print("Error fetching snapshots: \(error!)")
                                return
                            }
                            snapshot.documentChanges.enumerated().forEach { indexDeal, diff in
                                if (diff.type == .added) {
                                    let data = diff.document.data()
                                    print("data in added loop = \(data.count)")
                                    if let sender = data["Sender"] as? String,
                                       let image = data["ImagePath"] as? String,
                                       let dealTitle = data["DealTitle"] as? String,
                                       let dealDesc = data["DealDesc"] as? String,
                                       let storeID = data["StoreID"] as? String,
                                       let storeTitle = data["StoreTitle"] as? String,
                                       let dealID = data["DealID"] as? String,
                                       let userName = data["UserName"] as? String {
                                        print("snapshot.documentChanges.forEach")
//                                        if data.count == 0 {
//                                        DealsData.shared.dealsArray.removeAll(where: { $0.header == document.documentID })
//                                        }
                                        self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, section: indexS, dealID: dealID, sender: sender, userName: userName)
                                    } else {
                                        print("something wrong with diff.type == .added")
                                    }
                                }
                                if (diff.type == .modified) {
                                    print("Modified store deal: \(diff.document.documentID)")
                                    let data = diff.document.data()
                                    //let data = document.data()
                                    if let sender = data["Sender"] as? String,
                                       let image = data["ImagePath"] as? String,
                                       let dealTitle = data["DealTitle"] as? String,
                                       let dealDesc = data["DealDesc"] as? String,
                                       let storeID = data["StoreID"] as? String,
                                       let storeTitle = data["StoreTitle"] as? String,
                                       let dealID = data["DealID"] as? String,
                                        let userName = data["UserName"] as? String {
                                        print("snapshot.documentChanges.forEach")
                                        // this will give if you delete all the documents just after changing something in Firebase or adding/deleting here. But if you do a clean run after nil run, it will run.
                                        self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, section: indexS, dealID: dealID, sender: sender, userName: userName)
                                    } else {
                                        print("something wrong with diff.type == .modified")
                                    }
                                }
                                if (diff.type == .removed) {
                                    print("Removed store deal: \(diff.document.documentID)")
                                    let data = diff.document.data()
                                    if let dealID = data["DealID"] as? String {
                                        print("storeID that was deleted = \(dealID)")
//                                        DealsData.shared.dealsArray[indexS].items.removeAll(where: { $0.dealID == dealID })
                                        DealsData.shared.dealsArray.removeAll(where: {$0.items[indexDeal].dealID == dealID })
                                        print("Dealsdata after deleted deal = \(DealsData.shared.dealsArray)")
                                        DealsData.shared.dealsData.accept(DealsData.shared.dealsArray)
                                    }
                                }
                            }
                            querySnapShot!.documents.enumerated().forEach { index, document in
                            }
                        }
                    }
                }
            }
        }
    }
    func getImageFromURLfromFirebase(path: String, dealTitle: String, dealDesc: String, storeTitle: String, storeID: String, section: Int, dealID: String, sender: String, userName: String){
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
                DealsData.shared.dealsArray[section].items.append(DealModel(storeID: storeID, dealImage: response.image!, dealTitle: dealTitle, dealDesc: dealDesc, dealID: dealID, storeTitle: storeTitle, sender: sender, userName: userName))
                
                DealsData.shared.dealsArray[section].items.removeAll(where: { $0.dealTitle == "No Deals at This Store" })
                print("DealsData.shared.dealsArray = \(DealsData.shared.dealsArray)")
                DealsData.shared.dealsData.accept(DealsData.shared.dealsArray)
            }
        }
    }
    func addSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
        self.tableView.isHidden = true
    }
    func stopSpinner(){
        DispatchQueue.main.async {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
            self.tableView.isHidden = false
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
}
//MARK: - Download Image with Completion Handler using URL String
extension UIImageView {
    func downloadImage(from URLString: String, with completion: @escaping (_ response: (status: Bool, image: UIImage? ) ) -> Void) {
        guard let url = URL(string: URLString) else { 
            completion((status: false, image: nil))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion((status: false, image: nil))
                return
            }
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let data = data else {
                      completion((status: false, image: nil))
                      return
                  }
            let image = UIImage(data: data)
            completion((status: true, image: image))
        }.resume()
    }
}

// MARK: - This is useful to duplicate a struct object from model if it contains duplicate id or title or whatever.
extension Array {
    func unique(selector:(Element,Element)->Bool) -> Array<Element> {
        return reduce(Array<Element>()){
            if let last = $0.last {
                return selector(last,$1) ? $0 : $0 + [$1]
            } else {
                return [$1]
            }
        }
    }
}



