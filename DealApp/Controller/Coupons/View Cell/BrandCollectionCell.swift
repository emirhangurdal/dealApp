import UIKit
import SnapKit
class BrandCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let colors = C()
    var campaignId = Int()
    
    let brandImage : UIImageView = {
    let imgView = UIImageView()
    imgView.contentMode = .scaleAspectFit
    imgView.clipsToBounds = true
    imgView.layer.cornerRadius = 8.0
    imgView.backgroundColor = .white
    return imgView
    }()
    
    var brandTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15)
        lbl.textColor = .black
        lbl.layer.masksToBounds = true
        lbl.textAlignment = .center
        return lbl
    }()
    
    //MARK: - Constraints
    func configureConstraints(){
        contentView.addSubview(brandImage)
        contentView.addSubview(brandTitle)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            brandImage.snp.makeConstraints { brandImage in
                brandImage.height.equalTo(contentView.frame.size.height * 0.40)
                brandImage.width.equalTo(contentView.frame.size.width * 0.40)
                brandImage.centerX.equalTo(contentView)
                brandImage.centerY.equalTo(contentView)
            }
            brandTitle.snp.makeConstraints { brandTitle in
                brandTitle.width.equalTo(contentView)
                brandTitle.height.equalTo(15)
                brandTitle.top.equalTo(brandImage.snp.bottom).offset(2)
            }
            
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            brandImage.snp.makeConstraints { brandImage in
                brandImage.height.equalTo(contentView.frame.size.height * 0.50)
                brandImage.width.equalTo(contentView.frame.size.width * 0.50)
                brandImage.centerX.equalTo(contentView)
                brandImage.centerY.equalTo(contentView).offset(-10)
            }
            brandTitle.snp.makeConstraints { brandTitle in
                brandTitle.width.equalTo(contentView)
                brandTitle.height.equalTo(15)
                brandTitle.top.equalTo(brandImage.snp.bottom).offset(2)
            }
        }
    }
}
