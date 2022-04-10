import Foundation
import CoreData
import UIKit
class YelpAPIManager {
    let novalueImageUrl = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/no%20value.jpg?alt=media&token=df6afb68-402f-4681-ad9b-5a30532376a1"
    static let shared = YelpAPIManager()
    private let clientID = "S6sOmJNG-Zz7tKpzuJEZ4Q"
    private let apiKey = "ITau8YIoBuyE67gI0KYDefW4EKhwtrqbon7B9K4AGrDPiTWleRXDVebYm2jvCmRt72LjZxDcS9DVseeUKLpXPl8H8up_bhRLv9Z4-M-Oi2JtwF6zRqbt4G-rGAKmYXYx"
    func baseURL(latitude: Double, longitude: Double) -> String {
            "https://api.yelp.com/v3/businesses/search?longitude=\(longitude)&latitude=\(latitude)&radius=500"
        }
    func getPlaceInfo(latitude: Double, longitude: Double, completionHandler: @escaping ([StoresFeedModel]) -> Void) {
        print("longtitude = \(longitude)")
        print("latitude = \(latitude)")
        let url = URL(string: baseURL(latitude: latitude, longitude: longitude))
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer: \(apiKey)", forHTTPHeaderField: "Authorization")
        let sessionConfiguration = URLSessionConfiguration.default // 5
        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)" // 6
        ]
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: url!) {(data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(StoresFeedData.self, from: data)
                DispatchQueue.main.async {
                    let storesFeedModels = decodedData.businesses?.map {
                        StoresFeedModel(
                            title: $0.name ?? "",
                            image: $0.image_url ?? self.novalueImageUrl,
                            id: $0.id ?? ""
                        )
                    }
                        .removingDuplicates()
                    completionHandler(storesFeedModels ?? [])
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    func getFavStoreInfo(id: String,completionHandler: @escaping (StoresFeedModel) -> Void) {
        let baseURLFavorite = "https://api.yelp.com/v3/businesses/\(id)"
        let url = URL(string: baseURLFavorite)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer: \(apiKey)", forHTTPHeaderField: "Authorization")
        let sessionConfiguration = URLSessionConfiguration.default // 5
        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(apiKey)" // 6
        ]
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: url!) {(data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(FavStoresData.self, from: data)
                DispatchQueue.main.async {
                    if decodedData.image_url != "" {
                        let storesFeedModel = StoresFeedModel(
                            title: decodedData.name ?? "Choose a Favorite Store",
                            image: decodedData.image_url ?? self.novalueImageUrl,
                            id: decodedData.id ?? "No id"
                        )
                        completionHandler(storesFeedModel)
                    } else {
                        let storesFeedModel = StoresFeedModel(
                            title: decodedData.name ?? "Choose a Favorite Store",
                            image: self.novalueImageUrl,
                            id: decodedData.id ?? "No id"
                        )
                        completionHandler(storesFeedModel)
                    }
                }
            } catch {
                print(error)
            }
        }
        task.resume()
   }
}
