import Foundation

struct StoreData: Codable {
    let results: [Business]?
}
struct Business: Codable {
    let geometry: Geometry?
    let name: String?
    let photos: [Photos]?
    let place_id: String?
    let vicinity: String?
}
struct Photos: Codable {
    let photo_reference: String?
}

struct Geometry: Codable {
    let location: Loc?
}
struct Loc: Codable {
    let lat: Double?
    let lng: Double?
}
//MARK: - Favorite Store Data
struct FavData: Codable {
    let result: Business?
}

