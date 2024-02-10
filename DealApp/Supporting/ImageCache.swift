import UIKit
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
