import UIKit
import SnapKit
class AllDealsCCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let colors = C()
    var campaignId = Int()
    let categoryImage : UIImageView = {
    let imgView = UIImageView()
    imgView.contentMode = .scaleAspectFit
    imgView.clipsToBounds = true
    imgView.layer.cornerRadius = 8.0
    imgView.backgroundColor = .white
    return imgView
    }()
    
    var brandTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .black
        lbl.layer.masksToBounds = true
        lbl.textAlignment = .center
        return lbl
    }()
    
    //MARK: - Constraints
    func configureConstraints(){
        contentView.addSubview(categoryImage)
        contentView.addSubview(brandTitle)
       
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            categoryImage.snp.makeConstraints { categoryImage in
                categoryImage.height.equalTo(contentView.frame.size.height * 0.85)
                categoryImage.width.equalTo(contentView.frame.size.width * 0.70)
                categoryImage.centerX.equalTo(contentView)
                categoryImage.centerY.equalTo(contentView)
            }
            brandTitle.snp.makeConstraints { brandTitle in
                brandTitle.width.equalTo(150)
                brandTitle.height.equalTo(150)
                brandTitle.top.equalTo(categoryImage.snp.bottom).offset(5)
            }
            
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            categoryImage.snp.makeConstraints { categoryImage in
                categoryImage.height.equalTo(contentView.frame.size.height * 0.75)
                categoryImage.width.equalTo(contentView.frame.size.width * 0.75)
                categoryImage.centerX.equalTo(contentView)
                categoryImage.centerY.equalTo(contentView)
            }
            brandTitle.snp.makeConstraints { brandTitle in
                brandTitle.width.equalTo(contentView)
                brandTitle.height.equalTo(20)
                brandTitle.top.equalTo(categoryImage.snp.bottom).offset(5)
            }
        }
    }
}
