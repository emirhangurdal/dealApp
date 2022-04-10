
import Foundation
struct StoresFeedData: Codable {
    let businesses: [Businesses]?
    let total: Int?
    let location: [Location]?
}

struct Businesses: Codable {
    let name: String?
    let image_url: String?
    let id: String?
}

struct Location: Codable {
    let address1: String?
    let address2: String?
}

struct FavStoresData: Codable {
    let id: String?
    let name: String?
    let image_url: String?
}
