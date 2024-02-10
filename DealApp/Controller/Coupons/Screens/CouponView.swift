
import UIKit
import SnapKit
import LinkPresentation
import CoreServices
import SafariServices
import GoogleMobileAds



class CouponView: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        configCons()
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    var navTitle = String()
    var stance = Bool()
    
//    var brandDeals = [ImpactDealModel]()
    var couponBrand: CouponBrand?
    
    init(couponBrand: CouponBrand, title: String) {
        self.couponBrand = couponBrand
        navTitle = title
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = title
    }
    required init?(coder: NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    
    //MARK: CollectionView
    let googleAds = GoogleAds()
    let brandLogos = BrandLogos()
    let reuseIdentifier = "BrandDealCell"
    var aHeight = CGFloat()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    func setUpCollectionView(){
        collectionView.register(BrandCouponsCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
//        getImages()
    }
    //MARK: - Get Preview - MetaData
    @available(iOS 13.0, *)
  
   
    
    
    func returnHeight() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            aHeight = 200
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            aHeight = 125
        }
    }
    
    //MARK: ConfigureCons
    func configCons(){
        view.addSubview(collectionView)
        view.backgroundColor = .white
        
        collectionView.snp.makeConstraints { collectionView in
            collectionView.top.equalTo(view.safeAreaLayoutGuide)
            collectionView.bottom.equalTo(view.safeAreaLayoutGuide)
            collectionView.right.equalTo(view.safeAreaLayoutGuide)
            collectionView.left.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

//MARK: - Collection View Delegates
@available(iOS 13.0, *)
extension CouponView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (couponBrand?.coupons?.count)!
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let mainCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BrandCouponsCell
        
        let imageURL = couponBrand?.coupons?[indexPath.row].image
        let desc = couponBrand?.coupons?[indexPath.row].desc
        let title = couponBrand?.coupons?[indexPath.row].title
        
        mainCell.couponImage.loadImageAsync(with: imageURL)
        mainCell.desc.text = title
        return mainCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let couponDetail = CouponDetail(coupon: (couponBrand?.coupons?[indexPath.row])!, brand: navTitle)
        
        let navigationC = UINavigationController(rootViewController: couponDetail)
        navigationController?.present(navigationC, animated: true)
        
//        if url != nil, verificationofURL == true {
//
//            let config = SFSafariViewController.Configuration()
//            config.entersReaderIfAvailable = true
//
//            let weeklyads2 = URL(string: "https://www.weeklyads2.com/")
//            let vc = SFSafariViewController(url: url ?? weeklyads2!, configuration: config)
//            self.present(vc, animated: true)
//
//        } else {
//            let alert = UIAlertController(title: "Try Again Later".localized(), message: "", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
//                print("url not valid or nil")
//            }))
//            self.present(alert, animated: true, completion: nil)
//        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 4.0, bottom: 1.0, right: 4.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let widthPerItem = collectionView.frame.width / 2 - layout.minimumInteritemSpacing
        returnHeight()
        return CGSize(width: widthPerItem - 4, height: aHeight)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
    }
}
