import UIKit
import SnapKit

class ListCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureConst()
    }
    override func prepareForReuse() {
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var userName : UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.systemFont(ofSize: 16)
    lbl.textAlignment = .natural
    lbl.numberOfLines = 0
    lbl.textColor = .black
    lbl.textAlignment = .left
    lbl.backgroundColor = .clear
    return lbl
    }()
    
    func configureConst(){
        contentView.addSubview(userName)
        userName.snp.makeConstraints { userName in
            userName.top.equalTo(contentView)
            userName.bottom.equalTo(contentView)
            userName.right.equalTo(contentView)
            userName.left.equalTo(contentView).offset(5)
        }
    }
}
