//
//  Confirm.swift
//  DealApp
//
//  Created by Emir Gurdal on 18.11.2021.
//

import UIKit
import SnapKit

class Confirm: UIViewController {
    var confirmationMessage = UILabel()
    let text = "An email sent to you. Login Now."
    func configureMessage() {
        confirmationMessage.text = text
        self.confirmationMessage.textColor =  UIColor.white
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Login Now.")
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.red, range: range1)
        confirmationMessage.attributedText = underlineAttriString
        confirmationMessage.isUserInteractionEnabled = true
        confirmationMessage.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
    }
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
    let loginRange = (text as NSString).range(of: "Login Now.")
        
    if gesture.didTapAttributedTextInLabel(label: confirmationMessage, inRange: loginRange) {
        let loginVC = LogIn()
        self.navigationController?.pushViewController(loginVC, animated: true)
        
    }
    }
    
    var loginNow: UIButton = {
        var lgn = UIButton()
        lgn.setTitle("Login Now", for: .normal)
        lgn.setTitleColor(UIColor.init(white: 1, alpha: 0.3), for: .highlighted)
        lgn.titleLabel?.font = UIFont(name: "Optima-Bold", size: 20)
        lgn.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        return lgn
    }()
    
    @objc func goToLogin(){
    let loginVC = LogIn()
    self.navigationController?.pushViewController(loginVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        configureMessage()
        configureConst()
    }
    
    func configureConst(){
        self.view.addSubview(confirmationMessage)
        confirmationMessage.snp.makeConstraints { lbl in
            lbl.right.equalTo(view).offset(-20)
            lbl.left.equalTo(view).offset(20)
            lbl.centerY.equalTo(view)
            lbl.centerX.equalTo(view)
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




