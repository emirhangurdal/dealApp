import Foundation
import CoreData
import UIKit

struct PlaceModel {
    var name : String?
    var address: String?
}

class YelpAPIManager {
    static let shared = YelpAPIManager()
    
    
    let clientID = "S6sOmJNG-Zz7tKpzuJEZ4Q"
    let apiKey = "ITau8YIoBuyE67gI0KYDefW4EKhwtrqbon7B9K4AGrDPiTWleRXDVebYm2jvCmRt72LjZxDcS9DVseeUKLpXPl8H8up_bhRLv9Z4-M-Oi2JtwF6zRqbt4G-rGAKmYXYx"
    let baseURL = "https://api.yelp.com/v3/businesses/search?longitude=\(StoresFeed.longtitude)&latitude=\(StoresFeed.latitude)&radius=2000"
//    let baseURL = "https://api.yelp.com/v3/businesses/search?location=NYC&categories=bars&open_now=true"
    
     func getPlaceInfo(completionHandler: @escaping ([StoresFeedModel]) -> Void) {
         
         print("StoresFeed.shared.longtitude = \(StoresFeed.longtitude)")
         print("StoresFeed.shared.latitude = \(StoresFeed.latitude)")

         
        let url = URL(string: baseURL)
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
                    for i in 0..<decodedData.businesses!.count {
        StoresFeed.shared.businessDataMain.append(StoresFeedModel(title: (decodedData.businesses?[i].name)!,
                                                                  image: (decodedData.businesses?[i].image_url)!,
                                                                  id: (decodedData.businesses?[i].id)!))
//                        print(decodedData.businesses?[i].id)
                }
                    completionHandler(StoresFeed.shared.businessDataMain.removingDuplicates())
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    func getFavStoreInfo(id: String,completionHandler: @escaping ([StoresFeedModel]) -> Void) {
        let baseURLFavorite = "https://api.yelp.com/v3/businesses/\(id)"
       let novalueImageUrl = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/no%20value.jpg?alt=media&token=df6afb68-402f-4681-ad9b-5a30532376a1"
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
                   
                StoresFeed.shared.businessDataFav.append(StoresFeedModel(title: decodedData.name ?? "Choose a Favorite Store", image: decodedData.image_url ?? novalueImageUrl, id: decodedData.id ?? "No id"))
                 
                   completionHandler(StoresFeed.shared.businessDataFav.removingDuplicates())
               }
           } catch {
               print(error)
           }
       }
       task.resume()
   }
}
