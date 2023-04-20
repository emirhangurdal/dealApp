
import Foundation
import UIKit
import SnapKit
import Firebase
import FirebaseAuth
import KeychainSwift
import GoogleSignIn


class Settings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureConstraints()
        tableView.register(ListCell.self, forCellReuseIdentifier: cellidentifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    let keychain = KeychainSwift()

    let db = Firestore.firestore()
    private let storage = Storage.storage()
    let cellidentifier = "List"
    var textFieldPassword = UITextField()
    var tableView = UITableView()
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellidentifier) as! ListCell
        cell.userName.text = "Delete Your Account"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        alertDelete()
    }
    
    //MARK: - Functions Necessary For Delete Action
    func googleCredential() -> AuthCredential? {
        
        guard let user = GIDSignIn.sharedInstance.currentUser else {return nil}
        let authentication = user.authentication
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!,
                                                       accessToken: authentication.accessToken)
        return credential
    }
    func logoutUserFireBaseforDelete(){
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func alertDelete(){
        let alert = UIAlertController(title: "Delete Your Account".localized(), message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete Your Account?".localized(), style: .default, handler: { action in
            
            let deleteYourData = UIAlertController(title: "Delete Your Data".localized(), message: "Deals or other content you provided before must be deleted.".localized(), preferredStyle: .alert)
            
            
            deleteYourData.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                guard let email = Auth.auth().currentUser?.email else {return}
                guard let uid = Auth.auth().currentUser?.uid else {return}
                
                self.deleteUserDeals(senderEmail: email, userUID: uid)
                
                let sure = UIAlertController(title: "Delete Your Profile?".localized(), message: "This can't be undone".localized(), preferredStyle: .alert)
                sure.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { action in
                    guard let user = Auth.auth().currentUser else {return}
                    guard let userEmail = Auth.auth().currentUser?.email else {return}
                    
                    if let providerId = Auth.auth().currentUser?.providerData.first?.providerID,
                       let provider = AuthProviders(rawValue: providerId) {
                        switch provider {
                        case .password:
                            // Signed-in with Firebase Password
                            print("romancio el dotoro")
                            user.delete { error in
                                if let error = error {
                                    print(error)
                                    var password = String()
                                    
                                    // An error happened.
                                    let askPass = UIAlertController(title: "Login".localized(), message: "Please Enter Your Password".localized(), preferredStyle: .alert)
                                    askPass.addTextField { textfield in
                                        self.textFieldPassword.placeholder = "Your Password".localized()
                                        self.textFieldPassword = textfield
                                        password = self.textFieldPassword.text ?? ""
                                    }
                                    askPass.addAction(UIAlertAction(title: "Enter".localized(), style: .default, handler: { action in
                                        let credential = EmailAuthProvider.credential(withEmail: userEmail, password: self.textFieldPassword.text ?? "")
                                        user.reauthenticate(with: credential) { result, error in
                                            if let error = error {
                                                print("error.localizedDescription reauthenticate = \(error.localizedDescription)")
                                                return
                                            } else {
                                                user.delete()
                                                self.logoutUserFireBaseforDelete()
                                                self.signOutForDeleteAccount()
                                            }
                                        }
                                    }))
                                    askPass.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
                                        
                                    }))
                                    
                                    self.present(askPass, animated: true, completion: nil)
                                    return
                                } else {
                                    // Account deleted.
                                    self.logoutUserFireBaseforDelete()
                                    self.signOutForDeleteAccount()
                                 
                                }
                            }
                        case .google:
                            
                            print("Signed-in with Google")
                            user.delete { error in
                                if error != nil {
                                    print("google delete error?.localizedDescription \(error?.localizedDescription ?? "")")
                                    let appleAccountDelete = AppleAccountDelete()
                                    self.navigationController?.pushViewController(appleAccountDelete, animated: true)
                                    if let credential = self.googleCredential() {
                                        user.reauthenticate(with: credential) { result, error in
                                            if let error = error {
                                                print("error reauth = \(error.localizedDescription)")
                                            } else {
                                                self.logoutUserFireBaseforDelete()
                                                self.signOutForDeleteAccount()
                                            }
                                        }
                                    }
                                } else {
                                    
                                    self.logoutUserFireBaseforDelete()
                                    self.signOutForDeleteAccount()
                                }
                            }
                            
                        case .apple:
                            print("apple sign in")
                            user.delete { error in
                                if let error = error {
                                    let appleAccountDelete = AppleAccountDelete()
                                    self.navigationController?.pushViewController(appleAccountDelete, animated: true)
                                    print(error.localizedDescription)
                                } else {
                                    self.appleRevokeTokenDeleteAccount()
                                }
                            }
                        case .facebook:
                            print("there is no facebook")
                        }
                    }
                }))
                
                sure.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
                    
                }))
                self.present(sure, animated: true, completion: nil)
                
            }))
            deleteYourData.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            self.present(deleteYourData, animated: true)
         
        }))
        self.present(alert, animated: true)
    }
    
    //MARK: Apple Delete Revoking Token

    func appleRevokeTokenDeleteAccount() {
        if let token = keychain.get("refreshToken") {
            print("TokenofMyGoodWill = \(token)")
            let url = URL(string: "https://us-central1-dealapp-f1ce1.cloudfunctions.net/revokeToken?refresh_token=\(token)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://apple.com")!
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }
                if httpResponse.statusCode == 200 {
                    print("Token revoked successfully")
                    self.logoutUserFireBaseforDelete()
                    DispatchQueue.main.async {
                        self.signOutForDeleteAccount()
                    }
                   
                } else {
                    print("Error revoking token: \(httpResponse.statusCode)")
                }
            }
            task.resume()
        } else {
            print("something wrong with keychain")
        }
    }
    
    //MARK: Delete User-Related Deals when deleting a user
    func deleteUserDeals(senderEmail: String, userUID: String) {
        db.collectionGroup("deals").whereField("Sender", isEqualTo: senderEmail).getDocuments { querySnapShot, error in
            guard error == nil else {
                print("error deleting deals of user when deleting = \(error?.localizedDescription ?? "")")
                return
            }
            for document in querySnapShot!.documents {
                document.reference.delete { error in
                    if error != nil {
                        print("error deleting user deals = \(error?.localizedDescription ?? "")")
                    }
                }
            }
        }
        
        db.collection("favStoreCollection").document(userUID).collection("blockedUserIDs").getDocuments { querySnapShot, error in
            guard error == nil else {
                print("error deleting deals of user when deleting = \(error?.localizedDescription ?? "")")
                return
            }
            for document in querySnapShot!.documents {
                document.reference.delete { error in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                    }
                }
            }
        }
        db.collection("favStoreCollection").document(userUID).collection("storeIDs").getDocuments { querySnapShot, error in
            guard error == nil else {
                print("error deleting deals of user when deleting = \(error?.localizedDescription ?? "")")
                return
            }
            for document in querySnapShot!.documents {
                document.reference.delete { error in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                    }
                }
            }
        }
        db.collection("favStoreCollection").document(userUID).delete { error in
            if error != nil {
                print("favStoreDeleting = \(error?.localizedDescription ?? "")")
            } else {
               
            }
        }
    }
    
    //MARK: - Log Out When Deleting Account
    
    func signOutForDeleteAccount(){
        let signUp = SignUp()
        let navController = UINavigationController(rootViewController: signUp)
        guard let window = self.view.window else {
            return
        }
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stopTimer"), object: nil, userInfo: nil)
        
        if #available(iOS 13.0, *) {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(navController)
            
            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil, completion: nil)
            //            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil, completion: nil)
        } else {
            // Fallback on earlier versions
            //            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            UIApplication.shared.windows.first?.rootViewController = navController
            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }

    
}
