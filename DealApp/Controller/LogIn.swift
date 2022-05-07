

import UIKit
import SnapKit
import FirebaseAuth
import Firebase



class LogIn: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        view.addSubview(LogIn)
        textFieldPass.delegate = self
        textFieldEmail.delegate = self
        view.addSubview(textFieldEmail)
        view.addSubview(textFieldPass)
        view.addSubview(signUp)
        //        view.addSubview(errorMessageForPass)
        configureConst()
       
    }
//MARK:- Properties, Buttons, etc.
   let db = Firestore.firestore()
   private var textFieldEmail: UITextField = {
        var txt = UITextField()
        txt.font = UIFont(name: "Optima-Bold", size: 13)
        txt.backgroundColor = .white
        
        return txt
    }()
   private var textFieldPass: UITextField = {
        var txt = UITextField()
        txt.font = UIFont(name: "Optima-Bold", size: 13)
        txt.backgroundColor = .white
        txt.isSecureTextEntry = true
        return txt
    }()
   private var LogIn: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Log In", for: .normal)
        bttn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        bttn.titleLabel?.font = UIFont(name: "Optima-Bold", size: 20)
        bttn.addTarget(self, action: #selector(logInPressed), for: .touchUpInside)
        return bttn
    }()
// MARK:- OrLogin
    private var signUp: UIButton = {
        var orlgn = UIButton()
        orlgn.setTitle("Not a member? Sign Up!", for: .normal)
        orlgn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        orlgn.titleLabel?.font = UIFont(name: "Optima-Bold", size: 20)
        orlgn.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        return orlgn
    }()
    @objc func signUpPressed() {
        let signUpVC = SignUp()
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
//MARK: -Configure constraints.

    func configureConst() {
        signUp.snp.makeConstraints { orLogin in
            orLogin.centerX.equalTo(view)
            orLogin.top.equalTo(LogIn.snp.bottom).offset(10)
        }
        LogIn.snp.makeConstraints { titleLabel in
            titleLabel.centerX.equalTo(view)
            titleLabel.top.equalTo(textFieldPass.snp.bottom).offset(10)
        }
        textFieldEmail.snp.makeConstraints { textFieldEmail in
//            textFieldLogin.right.equalTo(view).offset(-50)
//            textFieldLogin.left.equalTo(view).offset(50)
//            textFieldLogin.top.equalTo(view).offset(360)
//            textFieldLogin.bottom.equalTo(view).offset(-420)
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
    //        errorMessageForPass.snp.makeConstraints { errorMessage in
    //            errorMessage.centerX.equalTo(self.view)
    //            errorMessage.right.equalTo(view).offset(-50)
    //            errorMessage.left.equalTo(view).offset(50)
    //            errorMessage.top.equalTo(self.signUp.snp.bottom).offset(10)
    //        }
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
        Auth.auth().signIn(withEmail: textFieldEmail.text!, password: textFieldPass.text!) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if error != nil {
                print("Error \(error?.localizedDescription)")
               return
            } else {
                    let storesFeedVC = StoresFeed()
                    let tabVC = TabBarViewController()
    //             self.navigationController?.pushViewController(tabVC, animated: true)
                    
                    self?.view.window!.rootViewController = tabVC
    //             self.navigationController?.setViewControllers([tabVC], animated: false)
                    self?.navigationController?.popToRootViewController(animated: false)
                    self?.dismiss(animated: false, completion: nil)
                
            }
        }
    }
}
    //create alert:
    //let alert = UIAlertController(title: "Alert", message: "We sent you an email. Please confirm", preferredStyle: UIAlertController.Style.alert)
    //alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    //self.present(alert, animated: true, completion: nil)
