import UIKit
import SnapKit
import Foundation
import LinkPresentation
import CoreServices
import GoogleMobileAds
import Firebase
@available(iOS 13.0, *)
class AllDealsVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configCons()
        setUpCollectionView()
        getData()
        configureNavBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    
    lazy var goToHelp = UIBarButtonItem(title: "Help".localized(), style: .plain, target: self, action: #selector(gotoHelp))
    
    let jsonParse = JsonParse()
    let impact = Impact()
    var metadata: LPLinkMetadata?
    let logos = BrandLogos()
    let brandNames = bIDs()
    let googleAds = GoogleAds()
    
    //MARK: CollectionView
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        //layout.itemSize = CGSize(width: 60, height: 120)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        //collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView
    }()
    let reuseIdentifier = "AllDealsCCell"
    
    func setUpCollectionView(){
        collectionView.register(AllDealsCCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        self.navigationItem.rightBarButtonItem = goToHelp

    }
    
    //MARK: Get Data from Json File
    
    func getData(){
        jsonParse.parseDealsfromLocal(fileName: "impactDeals") { [weak self] impactDeals in
            guard let self = self else {return}
            self.impact.impactDeals.removeAll()
            impactDeals.map { impactDealData in
                
                let deal = ImpactDealModel(Name: impactDealData?.Name,
                                               TrackingLink: impactDealData?.TrackingLink,
                                               Description: impactDealData?.Description,
                                               LinkText: impactDealData?.LinkText,
                                               image: nil,
                                               metaData: nil,
                                               LandingPage: impactDealData?.LandingPage,
                                               CampaignId: impactDealData?.CampaignId,
                                               AdId: impactDealData?.AdId,
                                               AdType: impactDealData?.AdType,
                                               Season: impactDealData?.Season)
                self.impact.impactDeals.append(deal)
               
                self.impact.brands.removeAll()
                let id = impactDealData?.CampaignId ?? 0000
                let brandT = self.impact.campaignIDs.campaignIDsDict[impactDealData?.CampaignId ?? 0000]
                let brand = Brand(campaignID: id, brand: brandT)
                
                DispatchQueue.main.async {
                    self.impact.brands.append(brand)
                    self.impact.brands = self.impact.brands.removingDuplicates()
                    self.collectionView.reloadData()
                }
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
    
    @objc func gotoHelp() {
        let help = Help()
        self.navigationController?.pushViewController(help, animated: true)
    }

    
    //MARK: - Spinner
    var spinner = SpinnerViewController()
    func addSpinner(){
        print("addspinner")
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    func stopSpinner(){
        DispatchQueue.main.async {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
        }
    }
    //MARK: - Configure Constraints
    var aHeight = CGFloat()

    func configCons(){
        view.addSubview(collectionView)
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        googleAds.setUpGoogleAds(viewController: self)
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)

        collectionView.snp.makeConstraints { collectionView in
            collectionView.top.equalTo(view.safeAreaLayoutGuide)
            collectionView.bottom.equalTo(googleAds.bannerView.snp.top).offset(-1)
            collectionView.right.equalTo(view)
            collectionView.left.equalTo(view)
        }
    }
    func returnHeight() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            aHeight = 225
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            aHeight = 125
        }
    }
    func configureNavBar(){
        self.navigationController?.navigationBar.backgroundColor = C.shared.navColor
        self.navigationItem.title = "All Brands".localized()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = C.shared.navColor
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        // Customizing our navigation bar
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
    }
}
@available(iOS 13.0, *)
extension AllDealsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        impact.brands.removingDuplicates().count 
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let mainCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AllDealsCCell
        let campaignID = impact.brands[indexPath.row].campaignID
        let brandLogo = logos.brandLogosDict[campaignID ?? 0000] as? UIImage
        if brandLogo == nil {
            mainCell.categoryImage.image = logos.brandLogosDict[0000] as? UIImage
        } else {
            mainCell.categoryImage.image = brandLogo!
        }
        return mainCell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let id = impact.brands[indexPath.row].campaignID
        let brand = brandNames.campaignIDsDict[id ?? 0000]
        let filteredDeals = impact.impactDeals.filter { $0.CampaignId == id }
//        let brandDeals = BrandDeals(brandDeals: filteredDeals, title: "\(brand ?? "Store")")
        let brandDeals = BrandDealsCollection(brandDeals: filteredDeals, title: brand ?? "Store")
        
        self.navigationController?.pushViewController(brandDeals, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 1.0, left: 4.0, bottom: 1.0, right: 4.0)
        }

        
        func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let lay = collectionViewLayout as! UICollectionViewFlowLayout
            
            let widthPerItem = collectionView.frame.width / 2 - lay.minimumInteritemSpacing
            returnHeight()
            return CGSize(width: widthPerItem - 8, height: aHeight)
        }
}
