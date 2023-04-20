import UIKit
import Firebase
import FirebaseAuth
import Photos
import PhotosUI

class ProfilePicPhotoHelper: NSObject { 
    // MARK: - Properties
    var completionHandler: ((UIImage) -> Void)?
    private let storage = Storage.storage()
    var viewController = UIViewController()
    // MARK: - Helper Methods
    func presentActionSheet(from viewController: UIViewController) {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let alertController = UIAlertController(title: nil, message: "Change Your Profile Picture".localized(), preferredStyle: .alert)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let capturePhotoAction = UIAlertAction(title: "Take Photo".localized(), style: .default, handler: { action in
                    self.presentPickerForCamera(with: .camera, from: viewController)
                })
                alertController.addAction(capturePhotoAction)}
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let uploadAction = UIAlertAction(title: "Upload from Library".localized(), style: .default, handler: { action in
                    if #available(iOS 14, *) {
                        self.allowAccessToPhotos(viewcontroller: viewController)
                    } else {
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            self.presentImagePickerController(with: .photoLibrary, from: viewController)
                        }
                    }
                })
                alertController.addAction(uploadAction)
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            viewController.present(alertController, animated: true)
     
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            let alertController = UIAlertController(title: nil, message: "Change Your Profile Picture".localized(), preferredStyle: .actionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let capturePhotoAction = UIAlertAction(title: "Take Photo".localized(), style: .default, handler: { action in
                    self.presentPickerForCamera(with: .camera, from: viewController)
                    
                })
                alertController.addAction(capturePhotoAction)}
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let uploadAction = UIAlertAction(title: "Upload from Library".localized(), style: .default, handler: { action in
                    if #available(iOS 14, *) {
                        self.allowAccessToPhotos(viewcontroller: viewController)
                    } else {
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            self.presentImagePickerController(with: .photoLibrary, from: viewController)
                        }
                    }
                })
                alertController.addAction(uploadAction)
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            viewController.present(alertController, animated: true)
        }
      
    }
    //MARK: - Present Picker Methods:
    func presentPickerForCamera(with sourceType: UIImagePickerController.SourceType, from viewController: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        viewController.present(imagePickerController, animated: true)
    }
    
    func presentImagePickerController(with sourceType: UIImagePickerController.SourceType, from viewController: UIViewController) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        let imagePickerController = UIImagePickerController()

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
//        imagePickerController.sourceType = sourceType
//        viewController.present(imagePickerController, animated: true)
//        imagePickerController.delegate = self
    }
    //MARK: for ios14 or above
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
}
extension ProfilePicPhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
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
                                self.getImageiOs14andUpper(image: image)
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
                            self.getImageiOs14andUpper(image: self.getUIImage(asset: asset) ?? UIImage(named: "no-image")!)
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
    
    func getImageiOs14andUpper(image: UIImage){
        completionHandler?(image)
        guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? TabBarViewController else {return}
        guard let profileNav = tabBarController.viewControllers?[3] as? UINavigationController else {return}
        guard let profile = profileNav.viewControllers.first as? Profile else {return}
        guard let profileImageData = image.jpeg(.lowest) else {
            return
        }
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        let dealImageRef = storage.reference().child("/ProfilePics/\(userUID)/profilepic")
        let uploadTask = dealImageRef.putData(profileImageData, metadata: nil) { metadata, error in
            if error != nil {
                print("uploading image error = \(error)")
            } else {
                print("sucessfully uploaded image")
            }
        }
        uploadTask.observe(.progress) { snapshot in
            print("snapshot.progress?.completedUnitCount = \(snapshot.progress?.completedUnitCount)")
        }
        uploadTask.observe(.success) { snapshot in
            dealImageRef.downloadURL { url, error in
                guard error == nil else {
                    print("error downloading image = \(error)")
                    return
                }
                let profileImageView = UIImageView()
                profileImageView.downloadImage(from: "\(url!)") { response in
                    DispatchQueue.main.async {
                        profile.profilePic.image = response.image
                    }
                }
            }
        }
    }
    
    //MARK: - Old Image Picker for Camera:
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            completionHandler?(selectedImage)
            guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? TabBarViewController else {return}
            guard let profileNav = tabBarController.viewControllers?[3] as? UINavigationController else {return}
            guard let profile = profileNav.viewControllers.first as? Profile else {return}
            let profileImageToBeUploaded = selectedImage
            guard let dealImageData = profileImageToBeUploaded.jpeg(.lowest) else {
                return
            }
            guard let userUID = Auth.auth().currentUser?.uid else {return}
            let dealImageRef = storage.reference().child("/ProfilePics/\(userUID)/profilepic")
            let uploadTask = dealImageRef.putData(dealImageData, metadata: nil) { metadata, error in
                if error != nil {
                    print("uploading image error = \(error)")
                } else {
                    print("sucessfully uploaded image")
                }
            }
            uploadTask.observe(.progress) { snapshot in
                print("snapshot.progress?.completedUnitCount = \(snapshot.progress?.completedUnitCount)")
            }
            uploadTask.observe(.success) { snapshot in
                dealImageRef.downloadURL { url, error in
                    guard error == nil else {
                        print("error downloading image = \(error)")
                        return
                    }
                    let profileImageView = UIImageView()
                    profileImageView.downloadImage(from: "\(url!)") { response in
                        DispatchQueue.main.async {
                            profile.profilePic.image = response.image
                        }
                    }
                }
            }
            picker.setNavigationBarHidden(false, animated: false)
            picker.dismiss(animated: true) {
            }
        } else {
            print("no selected image or")
        }
    }
 
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
