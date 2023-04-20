import UIKit
import WebKit
import SnapKit

class TermsVC: UIViewController, WKUIDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        
    }
    var myURL = String()
    var webView: WKWebView!
    
    func setupWebView(){
        super.viewDidLoad()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view.backgroundColor = .white
        
        view.addSubview(webView)
        webView.snp.makeConstraints { webView in
            webView.height.equalTo(view.safeAreaLayoutGuide)
            webView.width.equalTo(view.safeAreaLayoutGuide)
        }
        
        let myRequest = URLRequest(url: URL(string: myURL) ?? URL(string: "https://www.apple.com/maps/")!)
        webView.load(myRequest)
    }
    init(myURL: String) {
        self.myURL = myURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
