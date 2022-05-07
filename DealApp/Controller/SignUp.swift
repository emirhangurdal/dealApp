
import UIKit
import SnapKit
import FirebaseAuth
import Firebase

class SignUp: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
        self.view.backgroundColor = .blue
        view.addSubview(signUp)
        textFieldPass.delegate = self
        textFieldEmail.delegate = self
        configureConst()
    }
    let db = Firestore.firestore()
    
    //MARK: - Properties, Buttons, etc.
    
   private var textFieldEmail: UITextField = {
        var txt = UITextField()
        txt.font = UIFont(name: "Optima-Bold", size: 13)
        txt.backgroundColor = .white
        return txt
    }()
    private var textFieldUserName: UITextField = {
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
    private var signUp: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Sign Up", for: .normal)
        bttn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        bttn.titleLabel?.font = UIFont(name: "Optima-Bold", size: 20)
        bttn.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        return bttn
    }()
    
// MARK:- OrLogin
   lazy private var orLogin: UIButton = {
        var orlgn = UIButton()
        orlgn.setTitle("Already Member? Login!", for: .normal)
        orlgn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        orlgn.titleLabel?.font = UIFont(name: "Optima-Bold", size: 20)
        orlgn.addTarget(self, action: #selector(orLoginPressed), for: .touchUpInside)
        return orlgn
    }()
   private let errorMessageForPass: UILabel = {
        let err = UILabel()
        err.font = UIFont(name: "Optima-Bold", size: 13)
        err.textColor = .white
        err.isHidden = true
        err.numberOfLines = 0
        return err
    }()
    
    @objc func orLoginPressed() {
        let loginVC = LogIn()
        self.navigationController?.pushViewController(loginVC, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
//MARK: -Configure constraints.

    func configureConst() {
        view.addSubview(textFieldEmail)
        view.addSubview(textFieldPass)
        view.addSubview(orLogin)
        view.addSubview(errorMessageForPass)
        view.addSubview(textFieldUserName)
        let blue = UIColor(red: 49.0/255.0, green: 87.0/255.0, blue: 100.0/255.0, alpha: 0.5)
        orLogin.snp.makeConstraints { orLogin in
            orLogin.centerX.equalTo(view)
            orLogin.top.equalTo(signUp.snp.bottom).offset(10)
        }
        signUp.snp.makeConstraints { signUp in
            signUp.centerX.equalTo(view)
            signUp.top.equalTo(textFieldPass.snp.bottom).offset(10)
        }
        textFieldUserName.snp.makeConstraints { textFieldUserName in
            textFieldUserName.height.equalTo(35)
            textFieldUserName.width.equalTo(250)
            textFieldUserName.centerX.equalTo(view)
            textFieldUserName.centerY.equalTo(textFieldEmail).offset(-40)
        }

        textFieldEmail.snp.makeConstraints { textFieldEmail in
//            textFieldEmail.right.equalTo(view).offset(-50)
//            textFieldEmail.left.equalTo(view).offset(50)
//            textFieldEmail.top.equalTo(view).offset(360)
//            textFieldEmail.bottom.equalTo(view).offset(-420)
            textFieldEmail.height.equalTo(35)
            textFieldEmail.width.equalTo(250)
            textFieldEmail.centerX.equalTo(view)
            textFieldEmail.centerY.equalTo(view).offset(-50)
        }
        
        textFieldEmail.layer.cornerRadius = 4.0
        textFieldEmail.layer.borderWidth = 2.0
        textFieldEmail.layer.borderColor = blue.cgColor
        textFieldEmail.placeholder = "Email"
        
        textFieldUserName.layer.cornerRadius = 4.0
        textFieldUserName.layer.borderWidth = 2.0
        textFieldUserName.layer.borderColor = blue.cgColor
        textFieldUserName.placeholder = "User Name"
        
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
        
        errorMessageForPass.snp.makeConstraints { errorMessage in
            errorMessage.centerX.equalTo(self.view)
//            errorMessage.right.equalTo(view).offset(-50)
//            errorMessage.left.equalTo(view).offset(50)
            errorMessage.top.equalTo(self.orLogin.snp.bottom).offset(10)
        }
    }
   
}
//MARK:- Signup, Authentication, ValidPass Func.
extension SignUp: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let red = UIColor(red: 87.84/255.0, green: 23.53/255.0, blue: 19.22/255.0, alpha: 0.5)
        textFieldEmail.layer.borderColor = red.cgColor
        textFieldPass.layer.borderColor = red.cgColor
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func authenticateUser() {
        // google automatically checks
        if Auth.auth().currentUser != nil {
            print("check if matches this = \(Auth.auth().currentUser?.email)")
            DispatchQueue.main.async {
                let storesFeedVC = StoresFeed()
                let tabVC = TabBarViewController()
//             self.navigationController?.pushViewController(tabVC, animated: true)
                
                self.view.window!.rootViewController = tabVC
//                self.navigationController?.setViewControllers([tabVC], animated: false)
                self.navigationController?.popToRootViewController(animated: false)
                self.dismiss(animated: false, completion: nil)
            }
        } else {
            print("current user nil? ")
        }
    }
    @objc func signUpPressed() {
        Auth.auth().createUser(withEmail: textFieldEmail.text!, password: textFieldPass.text!) { authResult, error in
                if let e = error {
                    self.errorMessageForPass.isHidden = false
                    self.errorMessageForPass.text = "Please enter a valid email. Password must be 6 characters long at least. \(e)"
                } else {
                    let messageVC = Confirm()
                    self.navigationController?.pushViewController(messageVC, animated: true)
//                    add document of the user with its email from the start. This is updated on StoresTabCell/addfav button.
                    let changeRequest = authResult?.user.createProfileChangeRequest()
                    changeRequest?.displayName = self.textFieldUserName.text
                    changeRequest?.commitChanges(completion: { error in
                        if let err = error {
                            print("error with userName = \(err)")
                        }
                    })
                    let favDealsDocRef = self.db.collection("favStoreCollection").document(authResult?.user.uid ?? "someUid")
                    favDealsDocRef.setData(["String" : "Any"]) { error in
                        if let err = error {
                            print("error creating doc for fav store ids = \(err)")
                        } else {
                            print("successfully created user and added their favStoreCollection and document.")
                        }
                    }
                }
            }
    }
    func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8}$")
        return passwordTest.evaluate(with: password)
    }
}
    //create alert:

    //let alert = UIAlertController(title: "Alert", message: "We sent you an email. Please confirm", preferredStyle: UIAlertController.Style.alert)
    //alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    //self.present(alert, animated: true, completion: nil)
