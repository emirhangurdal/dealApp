import UIKit
import SnapKit

class Help: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHelp()
    }
    var help : VerticalTopAlignLabel = {
        let lbl = VerticalTopAlignLabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .black
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        lbl.textAlignment = .justified
        lbl.numberOfLines = 0
        lbl.sizeToFit()
        return lbl
    }()
    func configureHelp(){
        view.backgroundColor = .white
        self.navigationItem.title = "Help".localized()
        view.addSubview(help)
        help.snp.makeConstraints { help in
            help.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            help.bottom.equalTo(view.safeAreaLayoutGuide).offset(-5)
            help.right.equalTo(view.safeAreaLayoutGuide).offset(-5)
            help.left.equalTo(view.safeAreaLayoutGuide).offset(5)
        }
        help.text = "Depple doesn't only have local deals. Here, you can find affiliated links to some popular major stores in USA. You can browse the latest deals for special holidays. Target, Walmart, Best Buys, and many more major retailers can be seen here. If you buy through these links, Depple might earn a commission.\nAll the links are affiliate links provided by impact.com. These are general sales often particularly prepared for novelty items of Christmas, Valentine's Day, and similar occasions. And sometimes they have clearance deals or a special discount on clothes.\nAll we have here are brands. Tap on the brands and you will see the latest deals of them. The list will be updated when new major deals are available."
    }
}
