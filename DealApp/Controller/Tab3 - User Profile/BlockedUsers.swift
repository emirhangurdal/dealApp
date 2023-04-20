import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth


class BlockedUsers: UIViewController, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraints()
        tableView.register(ListCell.self, forCellReuseIdentifier: cellidentifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
   
    
    let userUID = Auth.auth().currentUser?.uid
    var tableView = UITableView()
    let db = Firestore.firestore()
    let cellidentifier = "List"
    func configureConstraints(){
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { tableView in
            tableView.top.equalTo(view.safeAreaLayoutGuide)
            tableView.bottom.equalTo(view.safeAreaLayoutGuide)
            tableView.right.equalTo(view.safeAreaLayoutGuide)
            tableView.left.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileDeals.shared.blockedUsersIDs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellidentifier) as! ListCell
        cell.userName.text = ProfileDeals.shared.blockedUsersIDs[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let colRef = db.collection("favStoreCollection").document(userUID ?? "").collection("blockedUserIDs")
        
        
        let alert = UIAlertController(title: "Unblock?".localized(), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { action in
            guard let unBlockUserID = ProfileDeals.shared.blockedUsersIDs[indexPath.row].id else {return}
            let docRef = self.db.collection("favStoreCollection").document(unBlockUserID)
            guard ProfileDeals.shared.blockedUsersIDs[indexPath.row].id != nil else {return}
            let id = ProfileDeals.shared.blockedUsersIDs[indexPath.row].id!
            
            let query = colRef.whereField("ID", isEqualTo: id)
            query.getDocuments { querySnap, error in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    querySnap?.documents.enumerated().forEach { index, document in
                        document.reference.delete { error in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            } else {
                                ProfileDeals.shared.blockedUsersIDs.removeAll(where: {$0.id == id})
                                print("ProfileDeals.shared.blockedUsersIDs unblock/delete block = \(ProfileDeals.shared.blockedUsersIDs)")
                                docRef.updateData(["BlockCounter" : FieldValue.increment(Int64(-1))])
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableRefresh"), object: nil, userInfo: nil)
                                
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
