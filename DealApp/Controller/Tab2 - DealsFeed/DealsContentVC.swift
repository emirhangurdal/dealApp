import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Firebase
import CoreLocation
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
        setupDataSource()
        loadDealsDataFromFirebase()
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
            return cell
        }
    )
    var newData = StoresData()
    var distanceToStore = Double()
    var indexPath = Int()
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
        dataSource.configureCell = { (_, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "DealCellID", for: indexPath) as! DealTabCell
            cell.configureWithData(dataModel: item)
            cell.dealID = item.dealID ?? "No deal ID found, empty or nil"
            cell.storeID = item.storeID ?? "No Store ID found, empty or nil"
            cell.storeTitle = item.storeTitle ?? "No Store Title"
            cell.sender.text = "@\(item.userName ?? "A User")"
           
            cell.btnTapClosure = { [weak self] cell in
                // safely unwrap weak self and optional indexPath
                guard let self = self,
                      let indexPath = tableView.indexPath(for: cell)
                else { return }
                
                // get the url from our data source
                let urlString = "https://apple.com"
                let activityItem: AnyObject = cell.dealImage.image!
                
                guard let url = URL(string: urlString) else {
                    // could not get a valid URL from the string
                    return
                }
                
                // present the share screen
                let objectsToShare = [activityItem]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
            return cell
        }
        dataSource.titleForHeaderInSection = { ds, section in
            return "Deals @ \(ds.sectionModels[section].header)"
        }
        DealsData.shared.dealsData.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        tableView.rx
            .modelSelected(DealModel.self)
            .subscribe(onNext:  { deal in
                print("value.dealTitle = \(deal.dealTitle)")
                let dealDetail = DealDetail()
                dealDetail.dealImage.image = deal.dealImage
                dealDetail.labelTitle.text = deal.dealTitle
                dealDetail.labelContent.text = deal.dealDesc
                print("value.sender = \(deal.sender)")
                self.navigationController?.present(dealDetail, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        //                tableView.rx
        //                           .itemSelected
        //                           .map { indexPath in
        //                               return (indexPath, self.dataSource[indexPath])
        //                           }
        //                           .subscribe(onNext: { pair in
        //                           })
        //                           .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
//        tableView.backgroundColor = UIColor(red: 58/255, green: 67/255, blue: 86/255, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 0.5)
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { tableView in
            tableView.right.equalTo(view.safeAreaLayoutGuide)
            tableView.left.equalTo(view.safeAreaLayoutGuide)
            tableView.top.equalTo(view).offset(100)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    //MARK: - Data From Firebase
  
    func loadDealsDataFromFirebase(){
        print("loadDealsDataFromFirebase")
        let docRef = db
            .collection("dealsCollection")
        self.addSpinner()
        
        docRef.addSnapshotListener { (querySnapShot, err) in
            if let err = err {
                print("error listening to storedocument. = \(err)")
            } else {
                DealsData.shared.dealsArray.removeAll()
                querySnapShot!.documents.enumerated().forEach { indexS, storeDocument in
                   
                     let storeData = storeDocument.data()
                    if let lat = storeData["Lat"] as? Double, let lon = storeData["Long"] as? Double {
                        let locationOne = CLLocation(latitude: lat, longitude: lon)
                        let locationTwo = CLLocation(latitude: StoresData.shared.lat,longitude: StoresData.shared.lon)
                        self.distanceToStore = locationOne.distance(from: locationTwo)
                    }
                    if self.distanceToStore < 650 {
                        let subColRef = self.db.collection("dealsCollection/\(storeDocument.documentID)/deals")
                        print("storeDocument = \(storeDocument.documentID)")
                        
                        DealsData.shared.dealsArray.append(SectionOfCustomData(header: storeDocument.documentID, items: [DealModel(storeID: "storeID", dealImage: UIImage(named: "empty-icon-25"), dealTitle: "No Deals at This Store", dealDesc: "\(storeDocument.documentID) has no deals yet.", dealID: "dealID", storeTitle: "storeTitle", sender: "sender email", userName: "user name", distance: 0.0)]))
                        
                        subColRef.addSnapshotListener { querySnapShot, error in
                            print("DealsData initial append == \(DealsData.shared.dealsArray)")
                            if let err = error {
                                print("error in subColRef = \(err)")
                            } else {
                                guard let snapshot = querySnapShot else {
                                    print("Error fetching snapshots: \(error!)")
                                    return
                                }
    //                            if querySnapShot?.documents.count == 0 {
    //                                print("querySnapShot?.documents.count == 0 TRUE")
    //                                let storeDocumentRef = self.db.collection("dealsCollection").document(storeDocument.documentID).delete { error in
    //                                    if let err = error {
    //                                        print("error deleting storedocument with no data = \(err)")
    //                                    } else {
    ////                                        DealsData.shared.dealsArray.removeAll(where: {$0.header == storeDocument.documentID})
    //                                        print("DealsData.shared.dealsArray after = \(DealsData.shared.dealsArray.count) ")
    //                                    }
    //                                }
    //                            }
                                snapshot.documents.enumerated().forEach { indexD, document in
                                    let data = document.data()
                                    if let sender = data["Sender"] as? String,
                                       let image = data["ImagePath"] as? String,
                                       let dealTitle = data["DealTitle"] as? String,
                                       let dealDesc = data["DealDesc"] as? String,
                                       let storeID = data["StoreID"] as? String,
                                       let storeTitle = data["StoreTitle"] as? String,
                                       let dealID = data["DealID"] as? String,
                                       let userName = data["UserName"] as? String {
                                     
    //                                self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, section: indexS, dealID: dealID, sender: sender, userName: userName)
                                        self.stopSpinner()
                                    }
                                }
                                snapshot.documentChanges.enumerated().forEach { indexDeal, diff in
                                    if (diff.type == .added) {
                                        print("added store deal: \(diff.document.documentID)")
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
                                            
                                       self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, section: indexS, dealID: dealID, sender: sender, userName: userName, distance: distance)
                                            
                                        } else {
                                            print("something wrong with diff.type == .added")
                                        }
                                    }
                                    if (diff.type == .modified) {
                                        print("Modified store deal: \(diff.document.documentID)")
                                        let data = diff.document.data()
                                        if let sender = data["Sender"] as? String,
                                           let image = data["ImagePath"] as? String,
                                           let dealTitle = data["DealTitle"] as? String,
                                           let dealDesc = data["DealDesc"] as? String,
                                           let storeID = data["StoreID"] as? String,
                                           let storeTitle = data["StoreTitle"] as? String,
                                           let dealID = data["DealID"] as? String,
                                           let userName = data["UserName"] as? String {
    //                                        let filtered = DealsData.shared.dealsArray[indexS].items.filter { $0.dealTitle == dealTitle }
    //                                        print("filtered = \(filtered)")
    //                                        print("deal title = \(dealTitle)")
                                            print("snapshot.documentChanges.forEach")
                                        } else {
                                            
                                            print("something wrong with diff.type == .modified")
                                        }
                                    }
                                    if (diff.type == .removed) {
                                        print("Removed store deal: \(diff.document.documentID)")
                                        let data = diff.document.data()
                                        
                                        if let dealID = data["DealID"] as? String {
                                            print("dealID to be deleted = \(dealID)")
                                            print("indexS = \(indexS)")
                                            print("indexdeal = \(indexDeal)")
    //                                        if DealsData.shared.dealsArray.count != 1 {
    //                                        }
                                       
                                            // this is index out of range when it is the last
    //                                        DealsData.shared.dealsArray.removeAll(where: {$0.items[indexDeal].dealID == dealID })
                                            
                                            DealsData.shared.dealsArray[indexS].items.removeAll(where: { $0.dealID == dealID })
                                            print("section data = \(DealsData.shared.dealsArray[indexS].items)")
                                            DispatchQueue.main.async {
                                                DealsData.shared.dealsData.accept(DealsData.shared.dealsArray)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func getImageFromURLfromFirebase(path: String, dealTitle: String, dealDesc: String, storeTitle: String, storeID: String, section: Int, dealID: String, sender: String, userName: String, distance: Double){
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
                print("section = \(section)")
                print("DealsData.shared.dealsArray downloadImageWithURL= \(DealsData.shared.dealsArray)")
                
                DealsData.shared.dealsArray[section].items.append(DealModel(storeID: storeID, dealImage: response.image ?? UIImage(named: "empty-icon-25"), dealTitle: dealTitle, dealDesc: dealDesc, dealID: dealID, storeTitle: storeTitle, sender: sender, userName: userName, distance: distance))
                
                if DealsData.shared.dealsArray[section].items.count > 1 {
                    DealsData.shared.dealsArray[section].items.removeAll(where: { $0.dealTitle == "No Deals at This Store" })
                }
                print("DealsData.shared.dealsArray download closure = \(DealsData.shared.dealsArray.count)")
                DispatchQueue.main.async {
                    DealsData.shared.dealsData.accept(DealsData.shared.dealsArray)
                }
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





