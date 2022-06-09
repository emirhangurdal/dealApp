import UIKit

enum NetworkManagerError: Error {
  case badResponse(URLResponse?)
  case badData
  case badLocalUrl
}

class GoogleApiManager {
var imageView = UIImageView()
private var images = NSCache<NSString, NSData>()
let novalueImageUrl = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/no%20value.jpg?alt=media&token=df6afb68-402f-4681-ad9b-5a30532376a1"
static let shared = GoogleApiManager()
    func baseURL(latitude: Double, longitude: Double) -> String {
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=store&location=\(latitude),\(longitude)&radius=1000&key=\(K.shared.googleApiKey)"
    }
    func photoURL(reference: String) -> String{
        if reference != "" {
            return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(reference)&key=\(K.shared.googleApiKey)"
        } else {
            return ""
        }
    }
    func getPlaceInfo(latitude: Double, longitude: Double, completionHandler: @escaping ([StoresFeedModel]) -> Void) {
        print("longtitude = \(longitude)")
        print("latitude = \(latitude)")
        let url = URL(string: baseURL(latitude: latitude, longitude: longitude))
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer: \(K.shared.googleApiKey)", forHTTPHeaderField: "Authorization")
        let sessionConfiguration = URLSessionConfiguration.default // 5
        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(K.shared.googleApiKey)" // 6
        ]
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: url!) {(data, response, error) in
            guard error == nil else {
                print("error?.localizedDescription =\(error?.localizedDescription)")
                return}
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(StoreData.self, from: data)
                
                DispatchQueue.main.async {
                    let storesFeedModels = decodedData.results?.map {
                       StoresFeedModel(
                           title: $0.name ?? "",
                           image: self.photoURL(reference: $0.photos?[0].photo_reference ?? ""),
                           id: $0.place_id ?? "",
                           distance: 0.0,
                           latitude: $0.geometry?.location?.lat ?? 00,
                           longitude: $0.geometry?.location?.lng ?? 00,
                           address1:  $0.vicinity ?? "",
                           address2: ""
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
        let baseURLFavorite = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(id)&key=\(K.shared.googleApiKey)"
        let url = URL(string: baseURLFavorite)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer: \(K.shared.googleApiKey)", forHTTPHeaderField: "Authorization")
        let sessionConfiguration = URLSessionConfiguration.default // 5
        sessionConfiguration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(K.shared.googleApiKey)" // 6
        ]
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: url!) {(data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(FavData.self, from: data)
                DispatchQueue.main.async {
                    let store = decodedData.result.map {
                        StoresFeedModel(title: $0.name ?? "",
                                        image: self.photoURL(reference: $0.photos?[0].photo_reference ?? ""),
                                        id: $0.place_id ?? "",
                                        distance: 0.0,
                                        latitude: $0.geometry?.location?.lat ?? 0.0,
                                        longitude: $0.geometry?.location?.lat ?? 0.0,
                                        address1: $0.vicinity ?? "",
                                        address2: "")
                    }
                    completionHandler(store ?? StoresFeedModel(title: "", image: "", id: "", distance: 0.0, latitude: 0.0, longitude: 0.0, address1: "", address2: ""))
                }
           
            } catch {
                print(error)
            }
        }
        task.resume()
   }
}
//MARK: - Extension UIImageView
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        if let cachedImageData = StoresData.shared.images.object(forKey: url.absoluteString as NSString) {
            DispatchQueue.main.async {
                print("using cached image")
                self.image = UIImage(data: cachedImageData as Data)
            }
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                else {  return }
                StoresData.shared.images.setObject(data as NSData, forKey: url.absoluteString as NSString)
                        DispatchQueue.main.async() { [weak self] in
                        print("downloaded image?")
                        self?.image = image
                    }
            }.resume()
        }
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
