import UIKit

//enum NetworkManagerError: Error {
//  case badResponse(URLResponse?)
//  case badData
//  case badLocalUrl
//}


//class GoogleApiManager {
//var imageView = UIImageView()
//private var images = NSCache<NSString, NSData>()
//    let localizedSearchKeyword = "store".localized()
//    let localLang = "en".localized()
//let novalueImageUrl = "https://firebasestorage.googleapis.com/v0/b/dealapp-f1ce1.appspot.com/o/no%20value.jpg?alt=media&token=df6afb68-402f-4681-ad9b-5a30532376a1"
//static let shared = GoogleApiManager()
//    func baseURL(latitude: Double, longitude: Double) -> String {
//        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?&lanugage=\(localLang)&keyword=\(localizedSearchKeyword)&location=\(latitude),\(longitude)&radius=500&key=\(K.shared.googleApiKey)"
//    }
//    func photoURL(reference: String) -> String {
//        if reference != "" {
//            return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(reference)&key=\(K.shared.googleApiKey)"
//        } else {
//            return ""
//        }
//    }
//    func getPlaceInfo(latitude: Double, longitude: Double, completionHandler: @escaping ([StoresFeedModel]) -> Void) {
//        print("longtitude = \(longitude)")
//        print("latitude = \(latitude)")
//        let url = URL(string: baseURL(latitude: latitude, longitude: longitude))
//        var request = URLRequest(url: url!)
//        request.httpMethod = "GET"
//        request.setValue("Bearer: \(K.shared.googleApiKey)", forHTTPHeaderField: "Authorization")
//        let sessionConfiguration = URLSessionConfiguration.default // 5
//        sessionConfiguration.httpAdditionalHeaders = [
//            "Authorization": "Bearer \(K.shared.googleApiKey)" // 6
//        ]
//        let session = URLSession(configuration: sessionConfiguration)
//        let task = session.dataTask(with: url!) {(data, response, error) in
//            guard error == nil else {
//                print("error?.localizedDescription =\(error?.localizedDescription)")
//                return}
//            guard let data = data else { return }
//            do {
//                let decoder = JSONDecoder()
//                let decodedData = try decoder.decode(StoreData.self, from: data)
//
//                DispatchQueue.main.async {
//                    let storesFeedModels = decodedData.results?.map {
//                       StoresFeedModel(
//                           title: $0.name ?? "",
//                           image: self.photoURL(reference: $0.photos?[0].photo_reference ?? ""),
//                           id: $0.place_id ?? "",
//                           distance: 0.0,
//                           latitude: $0.geometry?.location?.lat ?? 00,
//                           longitude: $0.geometry?.location?.lng ?? 00,
//                           address1:  $0.vicinity ?? "",
//                           address2: ""
//                       )
//                   }
//                           .removingDuplicates()
//                       completionHandler(storesFeedModels ?? [])
//                }
//            } catch {
//                print(error)
//            }
//        }
//        task.resume()
//    }
//    func getFavStoreInfo(id: String,completionHandler: @escaping (StoresFeedModel) -> Void) {
//        let baseURLFavorite = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(id)&key=\(K.shared.googleApiKey)"
//        let url = URL(string: baseURLFavorite)
//        var request = URLRequest(url: url!)
//        request.httpMethod = "GET"
//        request.setValue("Bearer: \(K.shared.googleApiKey)", forHTTPHeaderField: "Authorization")
//        let sessionConfiguration = URLSessionConfiguration.default // 5
//        sessionConfiguration.httpAdditionalHeaders = [
//            "Authorization": "Bearer \(K.shared.googleApiKey)" // 6
//        ]
//        let session = URLSession(configuration: sessionConfiguration)
//        let task = session.dataTask(with: url!) {(data, response, error) in
//            guard let data = data else { return }
//            do {
//                let decoder = JSONDecoder()
//                let decodedData = try decoder.decode(FavData.self, from: data)
//                DispatchQueue.main.async {
//                    let store = decodedData.result.map {
//                        StoresFeedModel(title: $0.name ?? "",
//                                        image: self.photoURL(reference: $0.photos?[0].photo_reference ?? ""),
//                                        id: $0.place_id ?? "",
//                                        distance: 0.0,
//                                        latitude: $0.geometry?.location?.lat ?? 0.0,
//                                        longitude: $0.geometry?.location?.lng ?? 0.0,
//                                        address1: $0.vicinity ?? "",
//                                        address2: "")
//                    }
//                    completionHandler(store ?? StoresFeedModel(title: "", image: "", id: "", distance: 0.0, latitude: 0.0, longitude: 0.0, address1: "", address2: ""))
//                }
//            } catch {
//                print(error)
//            }
//        }
//        task.resume()
//   }
//}
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
//MARK: - CACHING IMAGES:

extension UIImageView {
    private static var taskKey = 0
    private static var urlKey = 0

    private var currentTask: URLSessionTask? {
        get { objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionTask }
        set { objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var currentURL: URL? {
        get { objc_getAssociatedObject(self, &UIImageView.urlKey) as? URL }
        set { objc_setAssociatedObject(self, &UIImageView.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func loadImageAsync(with urlString: String?, placeholder: UIImage? = nil) {
        // cancel prior task, if any

        weak var oldTask = currentTask
        currentTask = nil
        oldTask?.cancel()

        // reset image view’s image

//        self.image = nil

        // allow supplying of `nil` to remove old image and then return immediately

        guard let urlString = urlString else { return }

        // check cache

        if let cachedImage = ImageCache.shared.image(forKey: urlString) {
            print("cached images")
            self.image = cachedImage
            return
        }

        // download

        let url = URL(string: urlString)
        currentURL = url
        if url != nil {
            let task = URLSession.shared.dataTask(with: url!) { [weak self] data, response, error in
                self?.currentTask = nil
                print("downloading the images")
                // error handling

                if let error = error {
                    // don't bother reporting cancelation errors

                    if (error as? URLError)?.code == .cancelled {
                        return
                    }

                    print(error)
                    return
                }

                guard let data = data, let downloadedImage = UIImage(data: data) else {
                    print("unable to extract image")
                    return
                }

                ImageCache.shared.save(image: downloadedImage, forKey: urlString)

                if url == self?.currentURL {
                    DispatchQueue.main.async {
                        self?.image = downloadedImage
                    }
                }
            }

            // save and start new task
            currentTask = task
            task.resume()
        } else {
            self.image = placeholder
        }

   
    }
}
