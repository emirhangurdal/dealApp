import UIKit
import SnapKit
import LinkPresentation
@available(iOS 13.0, *)
class BrandDealsCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let separator = UIView()
    let colors = C()
    
    lazy var brandLogo: UIImageView = {
        var img = UIImageView()
        img.backgroundColor = .clear
        img.contentMode = .scaleAspectFit
        img.isUserInteractionEnabled = true
        return img
    }()
    
    var urlString: String?
    
    var desc : VerticalTopAlignLabel = {
        let lbl = VerticalTopAlignLabel()
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = .blue
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        lbl.numberOfLines = 0
        lbl.sizeToFit()
        return lbl
    }()
    var link : VerticalTopAlignLabel = {
        let lbl = VerticalTopAlignLabel()
        lbl.font = UIFont.systemFont(ofSize: 10)
        lbl.textColor = .blue
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 5
        lbl.numberOfLines = 0
        lbl.sizeToFit()
        return lbl
    }()
    
    //MARK: - Constraints
    @available(iOS 13.0, *)
    func configureConstraints(){
        contentView.addSubview(separator)
        contentView.addSubview(desc)
        contentView.addSubview(brandLogo)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            separator.snp.makeConstraints { separator in
                separator.width.equalTo(1)
                separator.height.equalTo(1)
                separator.centerX.equalTo(contentView)
                separator.centerY.equalTo(contentView)
            }
            desc.font = UIFont.systemFont(ofSize: 20)
            brandLogo.snp.makeConstraints { brandLogo in
                brandLogo.width.equalTo(contentView)
                brandLogo.height.equalTo(50)
                brandLogo.top.equalTo(contentView)
                brandLogo.centerX.equalTo(contentView)
            }
            desc.snp.makeConstraints { desc in
                desc.top.equalTo(brandLogo.snp.bottom).offset(2)
                desc.bottom.equalTo(contentView)
                desc.right.equalTo(contentView)
                desc.left.equalTo(contentView)
            }
            
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            
            separator.snp.makeConstraints { separator in
                separator.width.equalTo(1)
                separator.height.equalTo(1)
                separator.centerX.equalTo(contentView)
                separator.centerY.equalTo(contentView)
            }
            brandLogo.snp.makeConstraints { brandLogo in
                brandLogo.width.equalTo(contentView)
                brandLogo.height.equalTo(25)
                brandLogo.top.equalTo(contentView)
                brandLogo.centerX.equalTo(contentView)
            }
            desc.snp.makeConstraints { desc in
                desc.top.equalTo(brandLogo.snp.bottom).offset(2)
                desc.bottom.equalTo(contentView)
                desc.right.equalTo(contentView)
                desc.left.equalTo(contentView)
            }
        }
    }
}

