
import UIKit
import SnapKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import WebKit
import GoogleSignIn
import FirebaseCore
import AuthenticationServices
import CryptoKit
import KeychainSwift

class SignUp: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    override func viewDidLoad() {
        super.viewDidLoad()
      
        authenticateUser()
        self.view.backgroundColor = C.shared.navColor
        textFieldPass.delegate = self
        textFieldEmail.delegate = self
        configureConst()
        configureWelcome()
        addGestureToView()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    
    let db = Firestore.firestore()
    let locale = Locale.current
    
    //MARK: - Properties, Buttons, etc.
    var spinner = SpinnerViewController()
    let keychain = KeychainSwift()
    let authorizationButton = ASAuthorizationAppleIDButton()
    fileprivate var currentNonce: String?
    var appleBool = false
    let termsVC = UIViewController()
    let actionCodeSettings = ActionCodeSettings()
    var webView: WKWebView!
    
    private var textFieldEmail: UITextField = {
        var txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 13)
        txt.backgroundColor = .white
        return txt
    }()
    private var textFieldUserName: UITextField = {
        var txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 13)
        txt.backgroundColor = .white
        return txt
    }()
    private var textFieldPass: UITextField = {
        var txt = UITextField()
        txt.font = UIFont.systemFont(ofSize: 13)
        txt.backgroundColor = .white
        txt.isSecureTextEntry = true
        return txt
    }()
    private var signUp: UIButton = {
        var bttn = UIButton()
        bttn.setTitle("Sign Up".localized(), for: .normal)
        bttn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        //        bttn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        bttn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        bttn.backgroundColor = UIColor(red: 82/255, green: 150/255, blue: 213/255, alpha: 1.0)
        bttn.layer.cornerRadius = 5
        bttn.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        return bttn
    }()
    
   
    
    private var googleSignIn: GIDSignInButton = {
        var bttn = GIDSignInButton()
        bttn.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        return bttn
    }()
    
    private var tickBox: UIButton = {
        var bttn = UIButton()
        bttn.setImage(UIImage(named: "icons8-unchecked-checkbox-50"), for: .normal)
        bttn.addTarget(self, action: #selector(tickboxTapped), for: .touchUpInside)
        return bttn
    }()
    private let yesAgreeLabel: UILabel = {
        let yes = UILabel()
        yes.font = UIFont.systemFont(ofSize: 13)
        yes.textColor = .black
        yes.numberOfLines = 0
        yes.text = "Yes, I agree"
        return yes
    }()
    private let termsAndPrivacy: UILabel = {
        let terms = UILabel()
        terms.font = UIFont.systemFont(ofSize: 13)
        terms.textColor = .black
        terms.numberOfLines = 0
        terms.textAlignment = .center
        return terms
    }()
    
    private var yesAgreeView: UIView = {
        var vw = UIView()
        return vw
    }()
    
    
    // MARK:- OrLogin
    lazy private var orLogin: UIButton = {
        var orlgn = UIButton()
        orlgn.setTitle("Login".localized(), for: .normal)
        //        orlgn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        orlgn.setTitleColor(UIColor.black, for: .normal)
        orlgn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        orlgn.addTarget(self, action: #selector(orLoginPressed), for: .touchUpInside)
        return orlgn
    }()
    private let errorMessageForPass: UILabel = {
        let err = UILabel()
        err.font = UIFont.systemFont(ofSize: 13)
        err.textColor = .black
        err.isHidden = true
        err.textAlignment = .center
        err.numberOfLines = 0
        return err
    }()
    private let welcomeMessage: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        
        lbl.numberOfLines = 0
        return lbl
    }()
    var logo : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Launch")
        return img
    }()
    func configureWelcome(){
        let welcome = "Welcome to Depple".localized()
        welcomeMessage.attributedText = NSMutableAttributedString()
            .bold("\(welcome)\n")
            .normal("Let's Get Started".localized())
    }
    
    @objc func orLoginPressed() {
        let loginVC = LogIn()
        self.navigationController?.pushViewController(loginVC, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func continueWithoutSigning() {
        print("continueWithoutSignUp")
        if #available(iOS 13, *) {
            let coupons = CategoryView()
            self.navigationController?.pushViewController(coupons, animated: true)
        }
    }
    //MARK: - Dismiss keyboard
    func addGestureToView(){
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapViewGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapViewGesture)
    }
    
    @objc func viewTapped(){
        textFieldPass.resignFirstResponder()
        textFieldEmail.resignFirstResponder()
        textFieldUserName.resignFirstResponder()
    }
    
    //MARK: - Agree to Terms
    var isSelected = false
    @objc func tickboxTapped(){
        print("tickbox Tapped")
    }
    
    
    @objc func agreeTapped(){
        print("agreeTapped")
        isSelected.toggle()
        
        print("isSelected = \(isSelected)")
        if isSelected == false {
            tickBox.setImage(UIImage(named: "icons8-unchecked-checkbox-50"), for: .normal)
            signUp.isEnabled = false
            googleSignIn.isUserInteractionEnabled = false
            googleSignIn.isEnabled = false
        
            appleBool = false
        } else {
            tickBox.setImage(UIImage(named: "icons8-checked-checkbox-50"), for: .normal)
            signUp.isEnabled = true
            googleSignIn.isUserInteractionEnabled = true
            googleSignIn.isEnabled = true
            
            appleBool = true
        }
    }
    
    func tapAgree(){
        signUp.isEnabled = false
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(agreeTapped))
        yesAgreeView.addGestureRecognizer(tapViewGesture)
    }
    func setUpAgreePrivacyTerm(){
        termsAndPrivacy.text = text()
        termsAndPrivacy.numberOfLines = 0
        let underlineAttriString = NSMutableAttributedString(string: text())
        let range1 = (text() as NSString).range(of: termsOfUse)
        let range2 = (text() as NSString).range(of: privacyPolicy)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.blue, range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.blue, range: range2)
        
        termsAndPrivacy.attributedText = underlineAttriString
        termsAndPrivacy.isUserInteractionEnabled = true
        termsAndPrivacy.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
        
    }
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        let loginRange = (text() as NSString).range(of: termsOfUse)
        let loginRange2 = (text() as NSString).range(of: privacyPolicy)
        
        if gesture.didTapAttributedTextInLabel(label: termsAndPrivacy, inRange: loginRange) {
            print("terms of use tapped")
            let myURL = "https://www.sites.google.com/view/depple/home"
            let webVC = TermsVC(myURL: myURL)
            self.navigationController?.pushViewController(webVC, animated: true)
            
        } else if gesture.didTapAttributedTextInLabel(label: termsAndPrivacy, inRange: loginRange2) {
            print("privacyPolicy tapped")
            let myURL = "https://www.sites.google.com/view/depple-privacy-policy/home"
            let webVC = TermsVC(myURL: myURL)
            self.navigationController?.pushViewController(webVC, animated: true)
        }
    }
    private var termsOfUse = "Terms of Use".localized()
    private var privacyPolicy = "Privacy Policy".localized()
    
    func text() -> String {
        let text = "You have to agree \(termsOfUse) and \(privacyPolicy) when you sign up."
        return text
    }
    
    
    //MARK: - Configure constraints.
    
    func configureConst() {
        let regionCode = locale.regionCode

        view.addSubview(signUp)
        view.addSubview(textFieldEmail)
        view.addSubview(textFieldPass)
        view.addSubview(orLogin)
        view.addSubview(logo)
        view.addSubview(errorMessageForPass)
        view.addSubview(textFieldUserName)
        view.addSubview(welcomeMessage)
        view.addSubview(yesAgreeView)
        view.addSubview(termsAndPrivacy)
        view.addSubview(googleSignIn)
        
        tapAgree()
        yesAgreeView.addSubview(yesAgreeLabel)
        yesAgreeLabel.addSubview(tickBox)
        setUpAgreePrivacyTerm()
        
        let blue = UIColor(red: 49.0/255.0, green: 87.0/255.0, blue: 100.0/255.0, alpha: 0.5)
        logo.snp.makeConstraints { logo in
            logo.height.equalTo(125)
            logo.width.equalTo(125)
            logo.centerX.equalTo(view.safeAreaLayoutGuide)
            logo.bottom.equalTo(welcomeMessage.snp.top).offset(-20)
        }
        welcomeMessage.snp.makeConstraints { welcomeMessage in
            welcomeMessage.height.equalTo(45)
            welcomeMessage.width.equalTo(275)
            welcomeMessage.centerX.equalTo(view.safeAreaLayoutGuide)
            welcomeMessage.bottom.equalTo(textFieldUserName.snp.top).offset(-40)
        }
        
        textFieldUserName.snp.makeConstraints { textFieldUserName in
            textFieldUserName.height.equalTo(35)
            textFieldUserName.width.equalTo(250)
            textFieldUserName.centerX.equalTo(view.safeAreaLayoutGuide)
            textFieldUserName.centerY.equalTo(textFieldEmail).offset(-40)
        }
        textFieldEmail.snp.makeConstraints { textFieldEmail in
            textFieldEmail.height.equalTo(35)
            textFieldEmail.width.equalTo(250)
            textFieldEmail.centerX.equalTo(view.safeAreaLayoutGuide)
            textFieldEmail.centerY.equalTo(view.safeAreaLayoutGuide).offset(-50)
        }
        textFieldPass.snp.makeConstraints { textFieldPass in
            textFieldPass.height.equalTo(35)
            textFieldPass.width.equalTo(250)
            textFieldPass.centerX.equalTo(textFieldEmail.snp.centerX)
            textFieldPass.centerY.equalTo(textFieldEmail.snp.centerY).offset(40)
        }
        
        signUp.snp.makeConstraints { signUp in
            signUp.height.equalTo(35)
            signUp.width.equalTo(250)
            signUp.centerX.equalTo(view.safeAreaLayoutGuide)
            signUp.top.equalTo(textFieldPass.snp.bottom).offset(10)
        }
        
        textFieldEmail.layer.cornerRadius = 4.0
        textFieldEmail.layer.borderWidth = 2.0
        textFieldEmail.layer.borderColor = blue.cgColor
        textFieldEmail.placeholder = "Email".localized()
        
        textFieldUserName.layer.cornerRadius = 4.0
        textFieldUserName.layer.borderWidth = 2.0
        textFieldUserName.layer.borderColor = blue.cgColor
        textFieldUserName.placeholder = "User Name".localized()

        textFieldPass.layer.cornerRadius = 4.0
        textFieldPass.layer.borderWidth = 2.0
        textFieldPass.layer.borderColor = blue.cgColor
        textFieldPass.placeholder = "Password".localized()
        
        googleSignIn.isEnabled = false
        
        googleSignIn.snp.makeConstraints { googleSignIn in
            googleSignIn.height.equalTo(35)
            googleSignIn.width.equalTo(250)
            googleSignIn.centerX.equalTo(view.safeAreaLayoutGuide)
            googleSignIn.top.equalTo(signUp.snp.bottom).offset(10)
        }
        if #available(iOS 13, *) {
            setupProviderLoginView()
        } else {
            // Fallback on earlier versions
        }

        orLogin.snp.makeConstraints { orLogin in
            orLogin.centerX.equalTo(view.safeAreaLayoutGuide)
            orLogin.top.equalTo(googleSignIn.snp.bottom).offset(50)
        }
        
        yesAgreeView.snp.makeConstraints { yesAgreeView in
            yesAgreeView.height.equalTo(30)
            yesAgreeView.width.equalTo(150)
            yesAgreeView.centerX.equalTo(view.safeAreaLayoutGuide)
            yesAgreeView.top.equalTo(orLogin.snp.bottom).offset(5)
        }
        
        tickBox.snp.makeConstraints { tickBox in
            tickBox.height.equalTo(25)
            tickBox.width.equalTo(25)
            tickBox.top.equalTo(yesAgreeView).offset(1)
            tickBox.left.equalTo(yesAgreeView).offset(-1)
        }
        yesAgreeLabel.snp.makeConstraints { yesAgreeLabel in
            yesAgreeLabel.top.equalTo(yesAgreeView)
            yesAgreeLabel.bottom.equalTo(yesAgreeView)
            yesAgreeLabel.right.equalTo(yesAgreeView)
            yesAgreeLabel.left.equalTo(tickBox.snp.right).offset(5)
        }
        termsAndPrivacy.snp.makeConstraints { termsAndPrivacy in
            termsAndPrivacy.centerX.equalTo(view.safeAreaLayoutGuide)
            termsAndPrivacy.top.equalTo(yesAgreeView.snp.bottom).offset(5)
            termsAndPrivacy.right.equalTo(view.safeAreaLayoutGuide).offset(-10)
            termsAndPrivacy.left.equalTo(view.safeAreaLayoutGuide).offset(10)
        }
        
        errorMessageForPass.snp.makeConstraints { errorMessage in
            errorMessage.centerX.equalTo(view.safeAreaLayoutGuide)
            errorMessage.top.equalTo(termsAndPrivacy.snp.bottom).offset(10)
            errorMessage.right.equalTo(view.safeAreaLayoutGuide).offset(-10)
            errorMessage.left.equalTo(view.safeAreaLayoutGuide).offset(10)
        }
    }
    
}
//MARK: - Signup, Authentication, ValidPass Func.
extension SignUp: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let red = UIColor(red: 87.84/255.0, green: 23.53/255.0, blue: 19.22/255.0, alpha: 0.5)
        textFieldEmail.layer.borderColor = red.cgColor
        textFieldPass.layer.borderColor = red.cgColor
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    //MARK: Spinner
    func addSpinner(){
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
        
    }
    func stopSpinner(){
        DispatchQueue.main.async {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
        }
    }
    
    //MARK: - Automatic Login
    func hideSignUp(){
        textFieldUserName.isHidden = true
        textFieldEmail.isHidden = true
        textFieldPass.isHidden = true
        signUp.isHidden = true
        errorMessageForPass.isHidden = true
        orLogin.isHidden = true
        welcomeMessage.isHidden = true
        logo.isHidden = true
        yesAgreeView.isHidden = true
        termsAndPrivacy.isHidden = true
        googleSignIn.isHidden = true
        authorizationButton.isHidden = true
    }
    
    func authenticateUser() {
        if Auth.auth().currentUser != nil, Auth.auth().currentUser?.isEmailVerified == true {
            hideSignUp()
            let colRef = db.collection("favStoreCollection").document(Auth.auth().currentUser?.uid ?? "").collection("blockedUserIDs")
            colRef.getDocuments { querySnapShot, error in
                if let error = error {
                    print("blocked User error signup auth = \(error.localizedDescription)")
                    return
                } else {
                    
                    ProfileDeals.shared.blockedUsersIDs.removeAll()
                    querySnapShot?.documents.enumerated().forEach { index, document in
                        print("blockedUser block works")
                        let data = document.data()
                        if let ID = data["ID"] as? String,
                           let userName = data["UserName"] as? String {
                            print("ID in auth in sign up = \(ID)")
                            ProfileDeals.shared.blockedUsersIDs.append(BlockedData(id: ID, name: userName))
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                let tabVC = TabBarViewController()
                
                if #available(iOS 13.0, *) {
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tabVC)
                    self.dismiss(animated: false, completion: nil)
                } else {
                    UIApplication.shared.windows.first?.rootViewController = tabVC
                    self.dismiss(animated: false, completion: nil)
                }
            }
        } else {
            print("current user nil? ")
        }
    }
    
    func verificationEmail(user: User?){
        if user != nil {
            if user?.isEmailVerified == false {
                user?.sendEmailVerification(completion: { error in
                    if let error = error {
                        print(error)
                        return
                    } else {
                        print("verification email sent")
                    }
                })
            }
        }
    }
    //MARK: Sign Up Tapped
    @objc func signUpPressed() {
        
        Auth.auth().createUser(withEmail: textFieldEmail.text!, password: textFieldPass.text!) { [weak self] authResult, error in
            guard let self = self else { return }
            if let e = error {
                self.errorMessageForPass.isHidden = false
                self.errorMessageForPass.text = "Please enter a valid email. Password must be 6 characters long at least. \(e.localizedDescription)"
            } else {
                let messageVC = Confirm()
                self.navigationController?.pushViewController(messageVC, animated: true)
                
                //                 // displaynamer is the username. Likes : Double in favStoreColllection must be created here first.
                let changeRequest = authResult?.user.createProfileChangeRequest()
                changeRequest?.displayName = self.textFieldUserName.text
                changeRequest?.commitChanges(completion: { error in
                    if let err = error {
                        print("error with userName = \(err)")
                        return
                    } else {
                        self.verificationEmail(user: authResult?.user)
                    }
                })
                
                // Write Likes
                
                let favDealsDocRef = self.db.collection("favStoreCollection").document(authResult?.user.uid ?? "someUid")
                favDealsDocRef.setData(["Likes" : 0, "UserName" : self.textFieldUserName.text ?? "", "BlockCounter" : 0, "About" : "About"]) { error in
                    if let err = error {
                        // add email field here.
                        
                        print("error creating doc for fav store ids, and likes data.  = \(err)")
                        return
                    } else {
                        print("successfully created user and added their favStoreCollection and document.")
                    }
                }
            }
        }
    }
    //MARK: Apple Sign In
    @available(iOS 13, *)
    func setupProviderLoginView() {
        
        view.addSubview(authorizationButton)
        
        authorizationButton.snp.makeConstraints { authorizationButton in
            authorizationButton.height.equalTo(35)
            authorizationButton.width.equalTo(250)
            authorizationButton.top.equalTo(googleSignIn.snp.bottom).offset(10)
            authorizationButton.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
    }
    @available(iOS 13, *)
    @objc func handleAuthorizationAppleIDButtonPress(){
        print("handleAuthorizationAppleIDButtonPress")
        if appleBool == true {
          
            startSignInWithAppleFlow()
        } else {
            let alert = UIAlertController(title: "You must check agree button", message: "You can't sign in unless you agree to terms of use and Privacy Policy", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
  
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            let authorizationCode = appleIDCredential.authorizationCode!
            refreshToken(authorizationCode: authorizationCode)
            
            // Sign in with Firebase.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
        
                Auth.auth().signIn(with: credential) { (authResult, error) in
                  if error != nil {
                      print(error?.localizedDescription)
                    return
                  }
                    guard authResult?.user != nil else {return}
                    
                    if authResult?.user.displayName == nil {
                        print("authResult?.user.displayName nil")
                        let changeRequest = authResult?.user.createProfileChangeRequest()
                        changeRequest?.displayName = "Apple User"
                        
                        changeRequest?.commitChanges(completion: { error in
                            if let err = error {
                                print("error with userName = \(err)")
                                return
                            } else {
                                self.writeLikesFirstTime(userName: authResult?.user.displayName ?? "aUser", uid: authResult?.user.uid ?? "")
                                self.changeRootView()
                            }
                        })
                    } else {
                        self.writeLikesFirstTime(userName: authResult?.user.displayName ?? "aUser", uid: authResult?.user.uid ?? "")
                        self.changeRootView()
                    }
                }
            
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
        default:
            break
        }
    }
    func refreshToken(authorizationCode: Data) {
        let codeString = String(data: authorizationCode, encoding: .utf8)!
        print("codeString = \(codeString)")
        
        let url = URL(string: "https://us-central1-dealapp-f1ce1.cloudfunctions.net/getRefreshToken?code=\(codeString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://apple.com")!
        
                let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                    
                    if let data = data {
                       
                        print("MyPreviousData = \(data)")
                        let refreshToken = String(data: data, encoding: .utf8) ?? ""
                        
                        print("refreshTokenSavedToKeyChain = \(refreshToken) endpoint")
                        // *For security reasons, we recommend iCloud keychain rather than UserDefaults.
                        self.keychain.set(refreshToken, forKey: "refreshToken")
                    }
                }
              task.resume()
    }
    
    //NOT USED:
    func sendAuthCodeToFunctions(authCode: String, uid: String) {
        
        let urlString = "https://us-central1-dealapp-f1ce1.cloudfunctions.net/receiveString"
        let url = URL(string: urlString)!
        let string = authCode

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = string.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error cloud function to get authcode: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status code authcode: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
       
        if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    // The user cancelled the flow
                    print("Sign in with Apple was cancelled by the user")
                default:
                    // Handle other errors here
                    print("Sign in with Apple error: \(authError.code.rawValue), \(authError.localizedDescription)")
                    self.errorMessageForPass.text = authError.localizedDescription
                }
            }
    }
    @available(iOS 13.0, *)
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()
    
      return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length
        
      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }
          
        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    //MARK: - Google Sign In
    
    @objc func googleSignInTapped(){
     
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                errorMessageForPass.text = error.localizedDescription
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    errorMessageForPass.text = error.localizedDescription
                    return
                } else {
                    
                    guard authResult?.user != nil else {
                        errorMessageForPass.text = "An error occured. Sorry."
                        return}
                    
                    // check if authresult.displayname is nil if it is nil commit change to set it to something. then do this:
                    writeLikesFirstTime(userName: authResult?.user.displayName ?? "aUser", uid: authResult?.user.uid ?? "")
                    changeRootView()
                }
            }
        }
    }
    func writeLikesFirstTime(userName: String, uid: String){
        let favDealsDocRef = self.db.collection("favStoreCollection").document(uid)
        favDealsDocRef.getDocument { docSnapShot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if docSnapShot?.exists == false {
                    favDealsDocRef.setData(["Likes" : 0, "UserName" : userName, "BlockCounter" : 0, "About" : "About"]) { error in
                        if let err = error {
                            print("error creating doc for fav store ids, and likes data.  = \(err)")
                            return
                        } else {
                            print("successfully created user and added their favStoreCollection and document.")
                        }
                    }
                }
            }
        }
    }
    func writeBlockedUsers(uid: String){
        let colRef = db.collection("favStoreCollection").document(uid).collection("blockedUserIDs")
            colRef.getDocuments { querySnapShot, error in
                if let error = error {
                    self.errorMessageForPass.text = error.localizedDescription
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
    }
    func changeRootView(){
        let tabVC = TabBarViewController()
        if #available(iOS 13.0, *) {
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tabVC)
            self.dismiss(animated: false, completion: nil)
        } else {
            UIApplication.shared.windows.first?.rootViewController = tabVC
            self.dismiss(animated: true, completion: nil)
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
