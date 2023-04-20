
import Foundation
import LinkPresentation

struct ImpactDealData: Codable {
    var Name: String?
    var TrackingLink: String?
    var Description: String?
    var LinkText: String?
    var LandingPage: String? //use for image preview
    var CampaignId: Int? // brand indicator
    var AdId: Int? // deal indicator
    var AdType: String?
    var Season: String?
}
@available(iOS 13.0, *)
struct ImpactDealModel {
    var Name: String?
    var TrackingLink: String?
    var Description: String?
    var LinkText: String?
    var image: Data?
    var metaData: LPLinkMetadata?
    var LandingPage: String? //use for image preview
    var CampaignId: Int? // brand indicator
    var AdId: Int? // deal indicator
    var AdType: String?
    var Season: String?
//    init(Name: String?,
//     TrackingLink: String?,
//     Description: String?,
//     LinkText: String?,
//     image: Data?,
//     metadata: LPLinkMetadata?,
//     LandingPage: String?,
//     CampaignId: Int?,
//     AdId: Int?,
//     AdType: String?,
//     Season: String?) {
//        self.Name = Name
//        self.TrackingLink = TrackingLink
//        self.Description = Description
//        self.LinkText = LinkText
//        self.image = image
//        self.metadata = metadata
//        self.LandingPage = LandingPage
//        self.CampaignId = CampaignId
//        self.AdId = AdId
//        self.AdType = AdType
//        self.Season = Season
//    }
    
}


struct Brand: Hashable {
    var campaignID: Int?
    var brand: String?
}
@available(iOS 13.0, *)

class Impact {
    let cache = NSCache<NSString, BrandDealHolder>()
    var cacheCounter = 0
    static let shared = Impact()
    
    var impactDeals = [ImpactDealModel]()
    
    var brands = [Brand]()
    let campaignIDs = bIDs()
    var linkMetaDataArray = [LPLinkMetadata]()
}
