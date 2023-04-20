

import UIKit
import SnapKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class LogIn: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldPass.delegate = self
        textFieldEmail.delegate = self
        configureConst()
        addGestureToView()
        savedEmailandPass()
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
   
    //MARK: - Gesture to View
    func addGestureToView(){
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapViewGesture)
    }
    @objc func viewTapped(){
        textFieldPass.resignFirstResponder()
        textFieldEmail.resignFirstResponder()
    }
//MARK: - Properties, Buttons, etc.
    let db = Firestore.firestore()
    private var textFieldEmail: UITextField = {
        var txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 13)
        txt.backgroundColor = .white
        txt.textColor = .black
        return txt
    }()
    private var textFieldPass: UITextField = {
        var txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 13)
        txt.backgroundColor = .white
        txt.textColor = .black
        txt.isSecureTextEntry = true
        return txt
    }()
    
    private let sendAgainText = "Send confirmation email again?".localized()
    private let emailNotVerified = "Your Email isn't verified.".localized()
    
    func text() -> String {
        let text = "\(emailNotVerified) \(sendAgainText)"
        return text
    }
    private var message: UILabel = {
        var lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textColor = .black
        lbl.isHidden = true
        return lbl
    }()
    private func configureMessage(){
        message.isHidden = false
        let underlineAttriString = NSMutableAttributedString(string: (text()))
        let range1 = (text() as NSString).range(of: sendAgainText)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.red, range: range1)
        message.attributedText = underlineAttriString
        message.isUserInteractionEnabled = true
        message.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(messageTapped(gesture:))))
    }
    @objc func messageTapped(gesture: UITapGestureRecognizer) {
        let confirmationEmailSendQuestion = (text() as NSString).range(of: sendAgainText)
        if gesture.didTapAttributedTextInLabel(label: message, inRange: confirmationEmailSendQuestion) {
            print("confirmation has been sent again")
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                if let error = error {
                    self.message.text = error.localizedDescription
                    print("error sending verificiation = \(error.localizedDescription)")
                    return
                } else {
                    print("verification email sent")
                }
            })
        }
    }
    
    private var LogIn: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Log In".localized(), for: .normal)
        bttn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        bttn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        bttn.backgroundColor = UIColor(red: 82/255, green: 150/255, blue: 213/255, alpha: 1.0)
        bttn.layer.cornerRadius = 5
        bttn.addTarget(self, action: #selector(logInPressed), for: .touchUpInside)
        return bttn
    }()
    private var passResetButton: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Forgot Password".localized(), for: .normal)
//        bttn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        bttn.setTitleColor(UIColor.black, for: .normal)
        bttn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        bttn.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        return bttn
    }()
    private var signUp: UIButton = {
        var orlgn = UIButton()
        orlgn.setTitle("Not a member? Sign Up!".localized(), for: .normal)
//        orlgn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        orlgn.setTitleColor(UIColor.black, for: .normal)
        orlgn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        orlgn.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        return orlgn
    }()
    @objc func signUpPressed() {
        let signUpVC = SignUp()
//        self.navigationController?.pushViewController(signUpVC, animated: true)
//        self.dismiss(animated: true, completion: nil)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    @objc func forgotPassword(){
        let alert = UIAlertController(title: "Reset Your Password?".localized(), message: "", preferredStyle: .alert)
        let alertPasswordEmail = UIAlertController(title: "Check Your Email".localized(), message: "Password Reset Email Has Been Sent".localized(), preferredStyle: .alert)
        alertPasswordEmail.addAction(UIAlertAction(title: "Done".localized(), style: .default, handler: { action in
            
        }))
        alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default, handler: { action in
            Auth.auth().sendPasswordReset(withEmail: self.textFieldEmail.text!) { error in
                if let error = error {
                    self.message.text = error.localizedDescription
                    return
                } else {
                    self.present(alertPasswordEmail, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    let userDefaults = UserDefaults.standard
    func savedEmailandPass(){
        let savedEmail = userDefaults.object(forKey: "email") as? String
        let savedPassword = userDefaults.object(forKey: "password") as? String
        textFieldEmail.text = savedEmail
        textFieldPass.text = savedPassword
    }
    
//MARK: - Configure constraints.

    func configureConst() {
        self.view.backgroundColor = C.shared.navColor
        view.addSubview(LogIn)
        view.addSubview(textFieldEmail)
        view.addSubview(textFieldPass)
        view.addSubview(signUp)
        view.addSubview(message)
        view.addSubview(passResetButton)
        textFieldEmail.snp.makeConstraints { textFieldEmail in
            textFieldEmail.height.equalTo(35)
            textFieldEmail.width.equalTo(250)
            textFieldEmail.centerX.equalTo(view)
            textFieldEmail.centerY.equalTo(view).offset(-50)
        }
        textFieldEmail.layer.cornerRadius = 4.0
        textFieldEmail.layer.borderWidth = 2.0
        let blue = UIColor(red: 49.0/255.0, green: 87.0/255.0, blue: 100.0/255.0, alpha: 0.5)
        textFieldEmail.layer.borderColor = blue.cgColor
        textFieldEmail.placeholder = "Email"
        
        textFieldPass.snp.makeConstraints { textFieldPass in
            textFieldPass.height.equalTo(35)
            textFieldPass.width.equalTo(250)
            textFieldPass.centerX.equalTo(textFieldEmail.snp.centerX)
            textFieldPass.centerY.equalTo(textFieldEmail.snp.centerY).offset(40)
        }
        textFieldPass.layer.cornerRadius = 4.0
        textFieldPass.layer.borderWidth = 2.0
        textFieldPass.layer.borderColor = blue.cgColor
        textFieldPass.placeholder = "Password"
        
        LogIn.snp.makeConstraints { LogIn in
            LogIn.height.equalTo(35)
            LogIn.width.equalTo(250)
            LogIn.centerX.equalTo(view.safeAreaLayoutGuide)
            LogIn.top.equalTo(textFieldPass.snp.bottom).offset(10)
        }
        signUp.snp.makeConstraints { orLogin in
            orLogin.centerX.equalTo(view.safeAreaLayoutGuide)
            orLogin.top.equalTo(LogIn.snp.bottom).offset(7)
        }
        passResetButton.snp.makeConstraints { passResetButton in
            passResetButton.centerX.equalTo(view.safeAreaLayoutGuide)
            passResetButton.top.equalTo(signUp.snp.bottom).offset(7)
        }
        message.snp.makeConstraints { message in
            message.centerX.equalTo(view.safeAreaLayoutGuide)
            message.top.equalTo(passResetButton.snp.bottom).offset(7)
            message.right.equalTo(view.safeAreaLayoutGuide).offset(-20)
            message.left.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
    }
}
//MARK:- Signup, Authentication, ValidPass Func.
extension LogIn: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let red = UIColor(red: 87.84/255.0, green: 23.53/255.0, blue: 19.22/255.0, alpha: 0.5)
        textFieldEmail.layer.borderColor = red.cgColor
        textFieldPass.layer.borderColor = red.cgColor
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @objc func logInPressed() {
        userDefaults.set(textFieldEmail.text ?? "", forKey: "email")
        userDefaults.set(textFieldPass.text ?? "", forKey: "password")
        
        Auth.auth().signIn(withEmail: textFieldEmail.text!, password: textFieldPass.text!) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if let error = error {
                print("Error \(error)")
                DispatchQueue.main.async {
                    strongSelf.message.isHidden = false
                    strongSelf.message.text = error.localizedDescription
                }
            
               return
            } else {
                
                if authResult?.user != nil && authResult?.user.isEmailVerified == true {
                    
                    let colRef = strongSelf.db.collection("favStoreCollection").document(Auth.auth().currentUser?.uid ?? "").collection("blockedUserIDs")
                    colRef.getDocuments { querySnapShot, error in
                        if let error = error {
                            strongSelf.message.text = error.localizedDescription
                            return
                        } else {
                            ProfileDeals.shared.blockedUsersIDs.removeAll()
                            querySnapShot?.documents.enumerated().forEach { index, document in
                                let data = document.data()
                                if let ID = data["ID"] as? String,
                                let userName = data["UserName"] as? String {
                                    ProfileDeals.shared.blockedUsersIDs.append(BlockedData(id: ID, name: userName))
                                }
                            }
                        }
                    }
                    
                    let tabVC = TabBarViewController()
                    if #available(iOS 13.0, *) {
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tabVC)
                        strongSelf.dismiss(animated: false, completion: nil)
                    } else {
                        UIApplication.shared.windows.first?.rootViewController = tabVC
                        strongSelf.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("Auth.auth().currentUser?.email = \(Auth.auth().currentUser?.email)")
                    
                    strongSelf.configureMessage()
                    
                    print("Your account is nil or not verified.")
                }
//                    guard let window = self?.view.window else {
//                           return
//                       }
//
//                        window.rootViewController = tabVC
//                        window.makeKeyAndVisible()
//                        window.rootViewController?.dismiss(animated: false, completion: nil)
//                        self?.dismiss(animated: false, completion: nil)
                
            }
        }
    }
}

