
import UIKit
import SnapKit
import LinkPresentation
import CoreServices
import SafariServices
import GoogleMobileAds
@available(iOS 13.0, *)
class BrandDealsCollection: UIViewController {
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
    var brandDeals = [ImpactDealModel]()
    init(brandDeals: [ImpactDealModel], title: String) {
        self.brandDeals = brandDeals
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
        //layout.itemSize = CGSize(width: 60, height: 120)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
//     collectionView.isScrollEnabled = true
//     collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView
    }()
    
    func setUpCollectionView(){
        collectionView.register(BrandDealsCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
//        getImages()
    }
    //MARK: - Get Preview - MetaData
    @available(iOS 13.0, *)
    func setupImagePreview(index: Int, url: String?) {
        guard url != nil else {return}
        guard verifyUrl(urlString: url) == true else {return}
        let url = URL(string: url!)
        
        LPMetadataProvider().startFetchingMetadata(for: url!) { [weak self] linkMetaData, error in
            guard let self = self else {return}
            guard linkMetaData != nil else {return}
            self.brandDeals[index].metaData = linkMetaData
            self.stance = false
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.stance = true
            }
        }
    }
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    func getImages(){
        brandDeals.enumerated().forEach { index, deal in
            setupImagePreview(index: index, url: deal.LandingPage!)
        }
    }
    
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
extension BrandDealsCollection: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return brandDeals.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let mainCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BrandDealsCell
        print("cell for item")
        let linkText = brandDeals[indexPath.row].LinkText
        let desc = "\(brandDeals[indexPath.row].Description!) \(linkText!)"
        let name = brandDeals[indexPath.row].Name
        let link = brandDeals[indexPath.row].LandingPage
        let campaignID = brandDeals[indexPath.row].CampaignId
        let brandLogo = brandLogos.brandLogosDict[campaignID ?? 0000] as? UIImage
        
        if desc.isEmpty == true {
            mainCell.desc.text = name
            mainCell.urlString = link
            mainCell.link.text = link
            mainCell.brandLogo.image = brandLogo
        } else {
            mainCell.desc.text = desc
            mainCell.urlString = link
            mainCell.link.text = link
            mainCell.brandLogo.image = brandLogo
        }

        return mainCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let link = brandDeals[indexPath.row].TrackingLink else {return}
        
        let url = URL(string: link)
        let verificationofURL = verifyUrl(urlString: url?.absoluteString)
        
        if url != nil, verificationofURL == true {
            
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let weeklyads2 = URL(string: "https://www.weeklyads2.com/")
            let vc = SFSafariViewController(url: url ?? weeklyads2!, configuration: config)
            self.present(vc, animated: true)
      
        } else {
            let alert = UIAlertController(title: "Try Again Later".localized(), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                print("url not valid or nil")
            }))
            self.present(alert, animated: true, completion: nil)
        }
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
