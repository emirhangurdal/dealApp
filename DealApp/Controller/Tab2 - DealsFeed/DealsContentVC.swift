import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Firebase
import CoreLocation
//where all the deals are collected in a tableview feed. Tableview is sectioned.
class DealsContentVC: UIViewController, UIScrollViewDelegate, UITableViewDelegate, StoresFeedDelegate2 {
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
        callDataBase2()
  
        print("displayname ? \(Auth.auth().currentUser?.displayName)")
    }
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData> (
        configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "DealCellID", for: indexPath) as! DealTabCell
            
            return cell
        }
    )
    var storeTitles = [StoreIDandTitle]()
    var newData = StoresData()
    var distanceToStore = Double()
    var indexPath = Int()
    let g = DispatchGroup()
    private let storage = Storage.storage()
    let db = Firestore.firestore()
    var spinner = SpinnerViewController()
    var tableView = UITableView()
    private let disposeBag = DisposeBag()
    var dealCellID = "DealCellID"
    var deals = DealsData()
    let userName = Auth.auth().currentUser?.displayName
    
    func changeUserName(){
        
        //        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        //        changeRequest?.displayName = "lazyPerson"
        //        changeRequest?.commitChanges(completion: { error in
        //            if let err = error {
        //                print("error changing display name = \(err)")
        //            }
        //        })
    }
    //MARK: - Cell Configuration, Binding, Selection Handling
    func setupDataSource(){
        dataSource.configureCell = { (_, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "DealCellID", for: indexPath) as! DealTabCell
            cell.configureWithData(dataModel: item)
            cell.dealID = item.dealID ?? "No deal ID found, empty or nil"
            cell.storeID = item.storeID ?? "No Store ID found, empty or nil"
            cell.storeTitle = item.storeTitle ?? "No Store Title"
            cell.sender.text = "@\(item.userName ?? "A User")"
            cell.senderUID = item.senderUID ?? ""
            
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
                dealDetail.labelMessage.isHidden = true
                dealDetail.storeTitle = deal.storeTitle ?? ""
                dealDetail.seeAllDealsButton.isHidden = true
                print("value.sender = \(deal.sender)")
                self.navigationController?.pushViewController(dealDetail, animated: true)
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    func configureConstraints(){
        view.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 1.0)
        self.tabBarItem.title = ""
        view.addSubview(tableView)
        //        tableView.backgroundColor = UIColor(red: 58/255, green: 67/255, blue: 86/255, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 179/255, green: 178/255, blue: 184/255, alpha: 0.5)
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints { tableView in
            tableView.right.equalTo(view.safeAreaLayoutGuide).offset(-5)
            tableView.left.equalTo(view.safeAreaLayoutGuide).offset(5)
            tableView.top.equalTo(view.safeAreaLayoutGuide)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        configureNavBar()
    }
    func configureNavBar(){
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
        self.navigationItem.title = "Deals"
        self.navigationController?.navigationBar.isTranslucent = true
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 75/255, alpha: 1.0)
            // Customizing our navigation bar
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    //MARK: - Data From Firebase
    func getStoreTitles(mainData: [StoresFeedModel]) {
        print("getStoreTitles")
        //        let query = dealRef.whereField("Sender", isEqualTo: senderEmail!)
        mainData.map { data in
            storeTitles.append(StoreIDandTitle(title: data.title, id: data.id, lat: data.latitude, lon: data.longitude))
        }
    }
    func getTitles(completionHandler: @escaping ([SectionOfCustomData]) -> Void){
        let colRef = db.collection("dealsCollection")
        colRef.order(by: "Date", descending: true).addSnapshotListener() { querySnapShot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                DealsData.shared.dealsArray.removeAll()
                querySnapShot?.documentChanges.enumerated().forEach { index, documentChange in
                    print("JOHANN S. BACH")
                    let data = documentChange.document.data()
                    if let storeTitle = data["Store"] as? String {
                        DealsData.shared.dealsArray.append(SectionOfCustomData(header: storeTitle, id: documentChange.document.documentID, items: [DealModel(storeID: "", dealImage: UIImage(named: "empty-icon-25"), dealTitle: "None", dealDesc: "", dealID: "", storeTitle: "", sender: "", userName: "", distance: 0.0, senderUID: "")]))
                        
                    } else {
                        return
                    }
                }
                completionHandler(DealsData.shared.dealsArray)
            }
        }
    }
    func callDataBase2(){
   
        getTitles { data in
            DealsData.shared.dealsArray = data
            data.enumerated().forEach { index, data in
                let colRef = self.db.collection("dealsCollection").document(data.id).collection("deals")
                colRef.getDocuments { querySnap, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    } else {
                        DealsData.shared.dealsArray[index].items.removeAll(where: {$0.dealTitle == "None"})

                        querySnap?.documentChanges.enumerated().forEach { indexD, dealDocChange in
                            if dealDocChange.type == .added {
                                print("led zeppelin")
                                let data = dealDocChange.document.data()
                                if let sender = data["Sender"] as? String,
                                   let image = data["ImagePath"] as? String,
                                   let dealTitle = data["DealTitle"] as? String,
                                   let dealDesc = data["DealDesc"] as? String,
                                   let storeID = data["StoreID"] as? String,
                                   let storeTitle = data["StoreTitle"] as? String,
                                   let dealID = data["DealID"] as? String,
                                   let userName = data["UserName"] as? String,
                                   let distance = data["Distance"] as? Double,
                                   let senderUID = data["SenderUID"] as? String {
                                    self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, section: index, dealID: dealID, sender: sender, userName: userName, distance: distance, senderUID: senderUID)
                                } else {
                                    print("something wrong with diff.type == .added")
                                }
                            }
                            
                        }
                    }
                }
            }
            
        }
    }
    
    
    func callDataBase(){
        let colRef = db.collection("dealsCollection")
        DealsData.shared.dealsArray.removeAll()
        storeTitles.removingDuplicates().enumerated().forEach { indexS, sectionTitle in
            
//            DealsData.shared.dealsArray.append(SectionOfCustomData(header: sectionTitle.title, id: sectionTitle.id, items: [DealModel(storeID: "", dealImage: UIImage(named: "empty-icon-25"), dealTitle: "None", dealDesc: "", dealID: "", storeTitle: "", sender: "", userName: "", distance: 0.0, senderUID: "")]))
            
            let query = colRef.document(sectionTitle.id).collection("deals").whereField("StoreTitle", isEqualTo: sectionTitle.title)
            query.addSnapshotListener { querySnapShot, error in
                if let err = error {
                    print("err calling query = \(err.localizedDescription)")
                } else {
                    
                    DealsData.shared.dealsArray[indexS].items.removeAll(where: {$0.dealTitle == "None"})
                    querySnapShot?.documentChanges.enumerated().forEach { indexD, documentChange in
                        if (documentChange.type == .added) {
                            print("added store deal document id: \(documentChange.document.documentID)")
                            let data = documentChange.document.data()
                            if let sender = data["Sender"] as? String,
                               let image = data["ImagePath"] as? String,
                               let dealTitle = data["DealTitle"] as? String,
                               let dealDesc = data["DealDesc"] as? String,
                               let storeID = data["StoreID"] as? String,
                               let storeTitle = data["StoreTitle"] as? String,
                               let dealID = data["DealID"] as? String,
                               let userName = data["UserName"] as? String,
                               let distance = data["Distance"] as? Double,
                               let senderUID = data["SenderUID"] as? String {
                                self.getImageFromURLfromFirebase(path: image, dealTitle: dealTitle, dealDesc: dealDesc, storeTitle: storeTitle, storeID: storeID, section: indexS, dealID: dealID, sender: sender, userName: userName, distance: distance, senderUID: senderUID)
                                
                                
                            } else {
                                print("something wrong with diff.type == .added")
                            }
                        }
                        
                        if (documentChange.type == .removed) {
                            print("Removed store deal: \(documentChange.document.documentID)")
                            let data = documentChange.document.data()
                            if let sender = data["Sender"] as? String,
                               let image = data["ImagePath"] as? String,
                               let dealTitle = data["DealTitle"] as? String,
                               let dealDesc = data["DealDesc"] as? String,
                               let storeID = data["StoreID"] as? String,
                               let storeTitle = data["StoreTitle"] as? String,
                               let dealID = data["DealID"] as? String,
                               let userName = data["UserName"] as? String,
                               let distance = data["Distance"] as? Double,
                               let senderUID = data["SenderUID"] as? String {
                                let newData = DealsData.shared.dealsArray.map { section in
                                    SectionOfCustomData(
                                        header: section.header,
                                        id: section.id,
                                        items: section.items.filter({$0.dealID != dealID})
                                    )
                                }
                                print("newData = \(newData)")
                                DealsData.shared.dealsArray = newData
                               
                                DispatchQueue.main.async {
                                    DealsData.shared.dealsData.accept(DealsData.shared.dealsArray)
                                }
                                //                                print("dataAfterRemove ?= \(dataAfterRemove)")
                                //                                DealsData.shared.dealsArray[indexS].items.removeAll(where: { $0.dealID == dealID})
                                //                                    print("ZEUS")
                            }
                        }

                    }
                }

            }
        }
    }
    
    func getImageFromURLfromFirebase(path: String, dealTitle: String, dealDesc: String, storeTitle: String, storeID: String, section: Int, dealID: String, sender: String, userName: String, distance: Double, senderUID: String){
        print("getimagefromURL")
        
        let storageRef = storage.reference()
        let dealImageRef = storageRef.child(path)
            self.addSpinner()
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
                DealsData.shared.dealsArray[section].items.append(DealModel(storeID: storeID, dealImage: response.image ?? UIImage(named: "empty-icon-25"), dealTitle: dealTitle, dealDesc: dealDesc, dealID: dealID, storeTitle: storeTitle, sender: sender, userName: userName, distance: distance, senderUID: senderUID))
//                DealsData.shared.dealsArray.sort {
//                    $0.items.count > $1.items.count
//                }
                    DispatchQueue.main.async {
                    DealsData.shared.dealsData.accept(DealsData.shared.dealsArray)
                    self.stopSpinner()
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





