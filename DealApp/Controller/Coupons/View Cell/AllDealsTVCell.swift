import UIKit
import SnapKit

protocol AllDealsTVCellDelegate: AnyObject {
    func didSelectCouponBrand(_ couponBrand: CouponBrand)
}

class AllDealsTVCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
     
    }
    //MARK: - Properties
    private var middle: UIView = {
        let vw = UIView()
        vw.backgroundColor = .clear
        return vw
    }()
    
    //MARK: CollectionView That Shows Brands
    
    let identifier = "AllDealsCCell"
    weak var delegate: AllDealsTVCellDelegate?
    var couponBrands = [CouponBrand]()
    var category = CouponCategory()
    var categoryTitle = String()
    var brands = [String]()
    var section = Int()
    var collectionView: UICollectionView!
    
    func setUpCollectionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BrandCollectionCell.self, forCellWithReuseIdentifier: identifier)
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { collectionView in
            collectionView.top.equalTo(contentView)
            collectionView.bottom.equalTo(contentView)
            collectionView.right.equalTo(contentView)
            collectionView.left.equalTo(contentView)
        }
        
    }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (category.categoryBrands?.keys.count)!
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let mainCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! BrandCollectionCell
        
        if let brandValues = category.categoryBrands?.values {
            let brandAtIndex = brandValues[brandValues.index(brandValues.startIndex, offsetBy: indexPath.row)]
            let title = brandAtIndex.title
            let image = brandAtIndex.image
            
            mainCell.brandTitle.text = title
            mainCell.brandImage.image = image
        }
        
        return mainCell
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let brandValues = category.categoryBrands?.values {
            let brandAtIndex = brandValues[brandValues.index(brandValues.startIndex, offsetBy: indexPath.row)]
            delegate?.didSelectCouponBrand(brandAtIndex)
        }
    }
    
    var aHeight = CGFloat()
    func returnHeight() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            aHeight = 200
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            aHeight = contentView.frame.height
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let lay = collectionViewLayout as! UICollectionViewFlowLayout
        
        let widthPerItem = collectionView.frame.width / 2 - lay.minimumInteritemSpacing
        returnHeight()
        return CGSize(width: widthPerItem - 8, height: aHeight)
    }
    
 
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 1.0, left: 4.0, bottom: 1.0, right: 4.0)
//    }
  
}

