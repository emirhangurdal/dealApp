//
//  DownloadImage.swift
//  DealApp
//
//  Created by Emir Gurdal on 5.02.2024.
//

import Foundation
import UIKit

//MARK: - Download Image with Completion Handler using URL String
extension UIImageView {
    func downloadImage(from URLString: String, with completion: @escaping (_ response: (status: Bool, image: UIImage? ) ) -> Void) {
        guard let url = URL(string: URLString) else {
            completion((status: false, image: nil))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion((status: false, image: nil))
                return
            }
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let data = data else {
                completion((status: false, image: nil))
                return
            }
            let image = UIImage(data: data)
            completion((status: true, image: image))
        }.resume()
    }
}
