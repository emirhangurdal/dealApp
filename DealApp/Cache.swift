import UIKit
import LinkPresentation

class DataStructHolder: NSObject {
    let thing: [StoresFeedModel]
    init(thing: [StoresFeedModel]) {
        self.thing = thing
    }
}
@available(iOS 13.0, *)
class BrandDealHolder: NSObject {
    let thing: [LPLinkMetadata]
    init(thing: [LPLinkMetadata]) {
        self.thing = thing
    }
}

class ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    private var observer: NSObjectProtocol?

    static let shared = ImageCache()

    private init() {
        // make sure to purge cache on memory pressure

        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.cache.removeAllObjects()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(observer!)
    }

    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func save(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

//final class Cache<Key: Hashable, Value> {
//    private let wrapped = NSCache<WrappedKey, Entry>()
//
//    func insert(_ value: Value, forKey key: Key) {
//         let entry = Entry(value: value)
//         wrapped.setObject(entry, forKey: WrappedKey(key))
//     }
//
//    func value(forKey key: Key) -> Value? {
//        let entry = wrapped.object(forKey: WrappedKey(key))
//        return entry?.value
//    }
//
//    func removeValue(forKey key: Key) {
//           wrapped.removeObject(forKey: WrappedKey(key))
//       }
//
//}
//
//private extension Cache {
//    final class WrappedKey: NSObject {
//        let key: Key
//        init(_ key: Key) { self.key = key }
//
//        override var hash: Int { return key.hashValue }
//
//        override func isEqual(_ object: Any?) -> Bool {
//            guard let value = object as? WrappedKey else {
//                return false
//            }
//            return value.key == key
//        }
//    }
//}
//
//private extension Cache {
//    final class Entry {
//        let value: Value
//        init(value: Value) {
//            self.value = value
//        }
//    }
//}
//
//extension Cache {
//    subscript(key: Key) -> Value? {
//        get { return value(forKey: key) }
//        set {
//            guard let value = newValue else {
//                // If nil was assigned using our subscript,
//                // then we remove any value for that key:
//                removeValue(forKey: key)
//                return
//            }
//
//            insert(value, forKey: key)
//        }
//    }
//}
