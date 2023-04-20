import UIKit
import SnapKit
import FirebaseAuth
import AuthenticationServices

class AppleAccountDelete: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraints()
    }
    private let warningText: UILabel = {
        let yes = UILabel()
        yes.font = UIFont.systemFont(ofSize: 13)
        yes.textColor = .black
        yes.numberOfLines = 0
        yes.text = "Sorry, you need to sign out and sign in with your preferred sign in method then try again.".localized()
        return yes
    }()
    private var logOut: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Log Out".localized(), for: .normal)
        bttn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        //        bttn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        bttn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        bttn.backgroundColor = UIColor(red: 82/255, green: 150/255, blue: 213/255, alpha: 1.0)
        bttn.layer.cornerRadius = 5
        bttn.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)
        return bttn
    }()
    @objc func logOutTapped() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            warningText.text = signOutError.localizedDescription
            print("Error signing out: %@", signOutError)
        }
        signOutForDeleteAccount()
    }
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
    
    func configureConstraints(){
        view.backgroundColor = .white
        view.addSubview(warningText)
        view.addSubview(logOut)
        warningText.snp.makeConstraints { warningText in
            warningText.height.equalTo(100)
            warningText.width.equalTo(250)
            warningText.centerX.equalTo(view.safeAreaLayoutGuide)
            warningText.centerY.equalTo(view.safeAreaLayoutGuide).offset(-50)
        }
        logOut.snp.makeConstraints { logOut in
            logOut.height.equalTo(35)
            logOut.width.equalTo(250)
            logOut.top.equalTo(warningText.snp.bottom).offset(5)
            logOut.centerX.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
