//
//  CouponWebView.swift
//  DealApp
//
//  Created by Emir Gurdal on 1.02.2024.
//

import Foundation
import UIKit
import WebKit
import SnapKit

class CouponWebView: UIViewController {
    override func viewDidLoad() {
        webView.load(URLRequest(url: urlToGo!))
        configureConstraints()
    }
    
    let webView = WKWebView()
    var urlToGo: URL?
    
    var close: UIButton = {
        let btn = UIButton()
        btn.setTitle("Close", for: .normal)
        return btn
    }()
        
    init(url: String) {
        urlToGo = URL(string: url)!
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    func configureConstraints() {
        view.addSubview(webView)
        webView.snp.makeConstraints { webView in
            webView.right.equalTo(view)
            webView.left.equalTo(view)
            webView.top.equalTo(view)
            webView.bottom.equalTo(view)
        }
    }
}
