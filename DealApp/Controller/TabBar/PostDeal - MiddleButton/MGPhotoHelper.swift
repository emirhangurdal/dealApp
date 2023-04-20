import UIKit
import Photos
import PhotosUI


protocol PushPostDeal: class {
    func pushPostDealVC(image: UIImage)
}

class MGPhotoHelper: NSObject {
    // MARK: - Properties
    var viewController = UIViewController()
    weak var delegate: PushPostDeal?
    var completionHandler: ((UIImage) -> Void)?
    static var imageSelected = UIImage() {
        didSet {
            
        }
    }
    let button = UIBarButtonItem()
    let imagePickerController = UIImagePickerController()
    var allPhotos: PHFetchResult<PHAsset>!
    
//    @available(iOS 14, *)
//    func pHImagePicker(viewcontrolller: UIViewController, configuration: PHPickerConfiguration) -> PHPickerViewController {
//        let phPicker = PHPickerViewController(configuration: configuration)
//        return phPicker
//    }

    @available(iOS 14, *)
    func allowAccessToPhotos(viewcontroller: UIViewController) {
        
        viewController = viewcontroller
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        var phpickerConfiguration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        phpickerConfiguration.filter = .images
        phpickerConfiguration.selectionLimit = 1
        
        let phPicker = PHPickerViewController(configuration: phpickerConfiguration)
        phPicker.delegate = self
        
        switch photoAuthorizationStatus {
            
        case .authorized:
            
            viewcontroller.present(phPicker, animated: true)
            print("auhtorized")
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    
                }
            }
            break
        case .restricted:
            
            print("restricted")
            break
        case .denied:
            let alert = UIAlertController(title: "Authorize The App to Access Library".localized(), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings".localized(), style: .cancel, handler: { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }))
            viewcontroller.present(alert, animated: true, completion: nil)
            
            print("denied")
            break
        case .limited:
            viewcontroller.present(phPicker, animated: true)
            print("limited")
        @unknown default:
            print("default")
        }
    }
    
    // MARK: - Helper Methods
    func presentActionSheet(from viewController: UIViewController) {
        
        imagePickerController.delegate = self
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let alertController = UIAlertController(title: nil, message: "Take Pic or Pick From Phone".localized(), preferredStyle: .alert)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let capturePhotoAction = UIAlertAction(title: "Take Photo".localized(), style: .default, handler: { action in
                    
                    self.presentImagePickerController(with: .camera, from: viewController)
                })
                alertController.addAction(capturePhotoAction)}
                let uploadAction = UIAlertAction(title: "Upload from Phone".localized(), style: .default, handler: { action in
                    
                    if #available(iOS 14, *) {
                        self.allowAccessToPhotos(viewcontroller: viewController)
                    } else {
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            self.presentImagePickerController(with: .photoLibrary, from: viewController)
                        }
                    }
                    
                })
                alertController.addAction(uploadAction)
            
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            viewController.present(alertController, animated: true)
            
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            
            let alertController = UIAlertController(title: nil, message: "Take Pic or Pick From Phone".localized(), preferredStyle: .actionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let capturePhotoAction = UIAlertAction(title: "Take Photo".localized(), style: .default, handler: { action in
                    self.presentPickerForCamera(with: .camera, from: viewController)
                })
                alertController.addAction(capturePhotoAction)
                
            }
                let uploadAction = UIAlertAction(title: "Upload from Phone".localized(), style: .default, handler: { action in
                    if #available(iOS 14, *) {
                        self.allowAccessToPhotos(viewcontroller: viewController)
                    } else {
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            
                            self.presentImagePickerController(with: .photoLibrary, from: viewController)
                        }
                    }
                  
                })
                alertController.addAction(uploadAction)
            
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            viewController.present(alertController, animated: true)
        }
    }
    
    func presentPickerForCamera(with sourceType: UIImagePickerController.SourceType, from viewController: UIViewController) {
        imagePickerController.sourceType = sourceType
        viewController.present(imagePickerController, animated: true)
    }
    
    func presentImagePickerController(with sourceType: UIImagePickerController.SourceType, from viewController: UIViewController) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .denied:
            print("denied")
            let alert = UIAlertController(title: "Authorize The App to Access Library".localized(), message: "Depple was denied to access your photo library. Please change your settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings".localized(), style: .cancel, handler: { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }))
            viewController.present(alert, animated: true, completion: nil)
        case .authorized:
            print("authorized")
            imagePickerController.sourceType = sourceType
            viewController.present(imagePickerController, animated: true)
        case .notDetermined:
            print("not determined")
        case .restricted:
            print("restricted")
        case .limited:
            print("limited")
        @unknown default:
            print("default")
        }
    }
}

extension MGPhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
    
    func photoLibraryDidBecomeUnavailable(_ photoLibrary: PHPhotoLibrary) {
        print("photoLibraryDidBecomeUnavailable")
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("photoLibraryDidChange")
    }
    
//MARK: - Handle Picking Image for iOS 14 or above
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch photoAuthorizationStatus {
        case .authorized:
            picker.dismiss(animated:true) {
                print("picker dismissed")
                guard let result = results.first else { return }
                let prov = result.itemProvider
                prov.loadObject(ofClass: UIImage.self) { imageMaybe, errorMaybe in
                    if let error = errorMaybe {
                        print("errorMaybe?.localizedDescription = \(errorMaybe?.localizedDescription)")
                        return
                    } else {
                       
                        if let image = imageMaybe as? UIImage {
                            DispatchQueue.main.async {
                                self.delegate?.pushPostDealVC(image: image)
                            }
                        }
                    }
                }
                    // ...
                }
        case .limited:
            print("limited")
            picker.dismiss(animated:true) {
                guard let result = results.first else { return }
                if let ident = result.assetIdentifier {
                    print("ident = \(ident)")
                    let result = PHAsset.fetchAssets(withLocalIdentifiers: [ident], options: nil)
                    print("asset = \(result.firstObject)")
                    if result.firstObject == nil {
                        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self.viewController)
                    } else {
                        if let asset = result.firstObject {
                            self.delegate?.pushPostDealVC(image: self.getUIImage(asset: asset) ?? UIImage(named: "no-image")!)
                        }
                    }
                   
                }
            }
            break
        @unknown default:
            print("default")
        }
    }
    
    func getUIImage(asset: PHAsset) -> UIImage? {

        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in

            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            
            picker.setNavigationBarHidden(false, animated: false)
            picker.dismiss(animated: true, completion: nil)
            self.delegate?.pushPostDealVC(image: selectedImage)
            
        } else {
            return
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

