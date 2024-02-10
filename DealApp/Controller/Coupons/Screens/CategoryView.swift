import UIKit
import SnapKit
import Foundation
import LinkPresentation
import CoreServices
import GoogleMobileAds
import Firebase
import RxSwift
import RxCocoa
import RxDataSources

protocol CategoryViewDelegate: AnyObject {
    func passcouponBrands(_ couponBrands: [String:CouponBrand])
}

@available(iOS 13.0, *)

class CategoryView: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, AllDealsTVCellDelegate, CouponDataDelegate, UITextFieldDelegate {
    
    func didSelectCouponBrand(_ couponBrand: CouponBrand) {
        let couponView = CouponView(couponBrand: couponBrand, title: couponBrand.title ?? "")
        self.navigationController?.pushViewController(couponView, animated: true)
        self.dismiss(animated: true)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configCons()
        setupTableView()
        configureNavBar()
        addSpinner()
        getData()
        couponModel.presentAlertDelegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait)
    }
    weak var delegate:CategoryViewDelegate?
   
    lazy var goToHelp = UIBarButtonItem(title: "Help".localized(), style: .plain, target: self, action: #selector(gotoHelp))
    let couponModel = CouponData()
    var sectn = Int()
    var sectionDidChange: ((Int) -> Void)?
    let searchCoupon = SearchCoupon()
    let googleAds = GoogleAds()
    var unfilteredCoupons: SectionOfCouponBrand?
    private var searchText: UITextField = {
        var txt = UITextField()
        let blue = UIColor(red: 49.0/255.0, green: 87.0/255.0, blue: 100.0/255.0, alpha: 0.5)
        txt.font = UIFont.boldSystemFont(ofSize: 13)
        txt.backgroundColor = .white
        txt.placeholder = "Search A Coupon with Product Name".localized()
        txt.textAlignment = .center
        txt.layer.borderWidth = 2.0
        txt.layer.cornerRadius = 4.0
        txt.textColor = .black
        txt.layer.borderColor = blue.cgColor
        txt.clearButtonMode = .whileEditing
        return txt
    }()
    //MARK: TableView
    let tvCellReuseIdentifier = "AllDealsTVCell"
    var tableView = UITableView()
    
    func getData() {
        couponModel.getData { data in
            self.unfilteredCoupons = data
            if data != nil {
                data?.categories.map({ categories in
                    categories.map { category in
                        self.stopSpinner()
                    }
                })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.searchText.delegate = self
                }
            } else {
                self.presentAlert(error: "Data is kaput.")
            }
        }
    }
    func presentAlert(error: String) {
        let alert = UIAlertController(title: "Sorry. An error occured. Try closing app and opening again".localized(), message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AllDealsTVCell.self, forCellReuseIdentifier: tvCellReuseIdentifier)
        tableView.register(MyCustomHeader.self,
                           forHeaderFooterViewReuseIdentifier: "sectionHeader")
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionsNumber = couponModel.couponData?.categories?.count
        return sectionsNumber!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchText.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tvCellReuseIdentifier, for: indexPath) as! AllDealsTVCell
        
        cell.delegate = self
        let category = couponModel.couponData?.categories![indexPath.section]
        cell.category = category!
        cell.collectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                                                                "sectionHeader") as! MyCustomHeader
        
        view.title.text = couponModel.couponData?.categories?[section].categoryTitle
        
        return view
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
    func addSpinner() {
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
    func configCons(){
        
        view.addSubview(tableView)
        view.backgroundColor = .white
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        view.addSubview(searchText)
        googleAds.setUpGoogleAds(viewController: self)
        searchText.snp.makeConstraints { searchText in
            searchText.top.equalTo(view.safeAreaLayoutGuide)
            searchText.bottom.equalTo(tableView.snp.top)
           
            searchText.width.equalTo(view.safeAreaLayoutGuide).offset(-15)
            searchText.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.snp.makeConstraints { tableView in
            tableView.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            tableView.bottom.equalTo(googleAds.bannerView.snp.top).offset(-1)
            tableView.right.equalTo(view)
            tableView.left.equalTo(view)
        }
    }
    
    func configureNavBar(){
        self.navigationController?.navigationBar.backgroundColor = C.shared.navColor
        let helpButton = UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(helpButton))
        self.navigationItem.rightBarButtonItem = helpButton
        self.navigationItem.title = "Coupons".localized()
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
    
    //MARK: - Go to help
    @objc func helpButton() {
        let help = Help()
        self.navigationController?.pushViewController(help, animated: true)
    }
    //MARK: Search - Textfield Methods
    func addGestureToView(){
        let tapViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapViewGesture)
    }
    @objc func viewTapped(){
        searchText.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let currentText = textField.text as NSString? {
            // Construct the new text after replacing characters
            let searchTerm = currentText.replacingCharacters(in: range, with: string)
            
            let filteredData = searchCoupon.filterCoupons(originalDataModel: couponModel.couponData!, for: searchTerm)
            couponModel.couponData = filteredData
            tableView.reloadData()
            if searchTerm == "" {
                couponModel.couponData = unfilteredCoupons
                tableView.reloadData()
            }
            print("currentText: \(currentText)")
            print("search: \(filteredData.categories?.count)")
            print("searchTerm: \(searchTerm)")
        }
     
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            switch reason {
            case .committed:
                print("Editing ended because user committed the change.")
               
            case .cancelled:
                print("Editing ended because user cancelled the change.")
            @unknown default:
                print("default")
            }
        }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
            // This method is called when the user taps the clear button on the text field
            print("searchTerm: \(textField.text)")
            couponModel.couponData = unfilteredCoupons
            tableView.reloadData()
            // Return true to allow the clear action to proceed, false to prevent it
            return true
        }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
        searchText.resignFirstResponder()
    }

}
