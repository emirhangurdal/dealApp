import UIKit
import SnapKit
import LinkPresentation
@available(iOS 13.0, *)
//where coupons of the brands like Walgreens, CVS shown
class BrandCouponsCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let separator = UIView()
    let colors = C()
    
    lazy var couponImage: UIImageView = {
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
  
    
    //MARK: - Constraints
    @available(iOS 13.0, *)
    func configureConstraints(){
        contentView.addSubview(separator)
        contentView.addSubview(desc)
        contentView.addSubview(couponImage)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            separator.snp.makeConstraints { separator in
                separator.width.equalTo(1)
                separator.height.equalTo(1)
                separator.centerX.equalTo(contentView)
                separator.centerY.equalTo(contentView)
            }
            desc.font = UIFont.systemFont(ofSize: 20)
            
            couponImage.snp.makeConstraints { couponImage in
                couponImage.width.equalTo(contentView.frame.width * 0.75)
                couponImage.height.equalTo(contentView.frame.height * 0.75)
                couponImage.top.equalTo(contentView)
                couponImage.centerX.equalTo(contentView)
            }
            desc.snp.makeConstraints { desc in
                desc.top.equalTo(couponImage.snp.bottom).offset(2)
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
            couponImage.snp.makeConstraints { couponImage in
                couponImage.width.equalTo(contentView.frame.width * 0.75)
                couponImage.height.equalTo(contentView.frame.height * 0.75)
                couponImage.top.equalTo(contentView)
                couponImage.centerX.equalTo(contentView)
            }
            
            desc.snp.makeConstraints { desc in
                desc.top.equalTo(couponImage.snp.bottom).offset(2)
                desc.bottom.equalTo(contentView)
                desc.right.equalTo(contentView)
                desc.left.equalTo(contentView)
            }
        }
    }
}

