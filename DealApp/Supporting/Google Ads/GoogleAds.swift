import UIKit
import GoogleMobileAds
import SnapKit
class GoogleAds {
    //MARK: - Banner Ad
    var bannerView: GADBannerView!
    let testUnitID = "ca-app-pub-3940256099942544/2934735716"
    let myBannerID = "ca-app-pub-8557954373328089/5863785011"
    func setUpGoogleAds(viewController: UIViewController) {
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = myBannerID
        bannerView.delegate = viewController as? GADBannerViewDelegate
        bannerView.rootViewController = viewController
        addBannerViewToView(bannerView, vc: viewController)
        bannerView.load(GADRequest())
    }
    func addBannerViewToView(_ bannerView: GADBannerView, vc: UIViewController) {
        vc.view.addSubview(bannerView)
        bannerView.snp.makeConstraints { bannerView in
            bannerView.width.equalTo(self.bannerView.snp.width)
            bannerView.height.equalTo(self.bannerView.snp.height)
            bannerView.centerX.equalTo(vc.view.safeAreaLayoutGuide)
            bannerView.bottom.equalTo(vc.view.safeAreaLayoutGuide).offset(-5)
        }
    }
}
