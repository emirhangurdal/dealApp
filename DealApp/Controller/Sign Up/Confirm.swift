
import UIKit
import SnapKit

class Confirm: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = C.shared.navColor
        configureMessage()
        configureConst()
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    
    private var confirmationMessage = UILabel()
    private var loginText = "Login Now.".localized()
    private var textBeginning = "An email sent to you. Please check junk/spam folder, too. You can log in after you verify your email.".localized()
    func text() -> String {
        let text = "\(textBeginning) \(loginText)"
        return text
    }
    
    func configureMessage() {
        confirmationMessage.text = text()
        confirmationMessage.numberOfLines = 0
        self.confirmationMessage.textColor = .black
        let underlineAttriString = NSMutableAttributedString(string: text())
        let range1 = (text() as NSString).range(of: loginText)
        
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.red, range: range1)
        confirmationMessage.attributedText = underlineAttriString
        confirmationMessage.isUserInteractionEnabled = true
        confirmationMessage.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
    }
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
    let loginRange = (text() as NSString).range(of: loginText)
    if gesture.didTapAttributedTextInLabel(label: confirmationMessage, inRange: loginRange) {
        let loginVC = LogIn()
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    }
    private var loginNow: UIButton = {
        var lgn = UIButton()
        lgn.setTitle("Login Now", for: .normal)
        lgn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        lgn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        lgn.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        return lgn
    }()
    @objc func goToLogin(){
    let loginVC = LogIn()
    self.navigationController?.pushViewController(loginVC, animated: true)
    self.dismiss(animated: true, completion: nil)
    }
 
    func configureConst(){
        self.view.addSubview(confirmationMessage)
        confirmationMessage.snp.makeConstraints { lbl in
            lbl.right.equalTo(view.safeAreaLayoutGuide).offset(-20)
            lbl.left.equalTo(view.safeAreaLayoutGuide).offset(20)
            lbl.centerY.equalTo(view.safeAreaLayoutGuide)
            lbl.centerX.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}




