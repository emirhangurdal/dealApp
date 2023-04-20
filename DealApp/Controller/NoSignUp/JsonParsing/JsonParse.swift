
import Foundation
import Firebase
import FirebaseFirestore

class JsonParse {
    let storage = Storage.storage().reference()
    static let shared = JsonParse()
    let decoder = JSONDecoder()
     func parseDeals(completionHandler: @escaping ([ImpactDealData?]) -> Void) {
     
         let ref = storage.child("impactDeals.json")
        let downloadTask = ref.getData(maxSize: 1 * 5120 * 5120) { data, error in
             if let error = error {
                 print("please error = \(error)")
             } else {
                 guard data != nil else {return}
//                 let jsonData = String(decoding: data!, as: UTF8.self).data(using: .utf8)
//                 guard jsonData != nil else {return}
//                 do {
//                     let decodedData = try decoder.decode([ImpactDealData?].self, from: jsonData!)
//                     completionHandler(decodedData)
//                 } catch {
//                     print("error parseDeals = \(error)")
//                 }
             }
         }
         let observer = downloadTask.observe(.progress) { snapShot in
             print("downloaded = \(snapShot.progress?.completedUnitCount)")
         }
         
    }
    func parseDealsfromLocal(fileName: String, completionHandler: @escaping ([ImpactDealData?]) -> Void) {
        do {
            let decodedData = try decoder.decode([ImpactDealData?].self, from: readLocalFile(forName: fileName)!)
            completionHandler(decodedData)
        } catch {
            print("error ParseDeals = \(error.localizedDescription)")
        }
    }
    
     func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print("error readLocalFile = \(error)")
        }
        return nil
    }
}
