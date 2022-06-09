import UIKit
import Firebase
import FirebaseAuth
class ProfilePicPhotoHelper: NSObject { 
    // MARK: - Properties
    var completionHandler: ((UIImage) -> Void)?
    private let storage = Storage.storage()
    // MARK: - Helper Methods
    func presentActionSheet(from viewController: UIViewController) {
        let alertController = UIAlertController(title: nil, message: "Change Your Profile Picture", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { action in
                self.presentImagePickerController(with: .camera, from: viewController)
            })
            alertController.addAction(capturePhotoAction)}
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let uploadAction = UIAlertAction(title: "Upload from Library", style: .default, handler: { action in
                self.presentImagePickerController(with: .photoLibrary, from: viewController)
            })
            alertController.addAction(uploadAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true)
    }
    func presentImagePickerController(with sourceType: UIImagePickerController.SourceType, from viewController: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        viewController.present(imagePickerController, animated: true)
        imagePickerController.delegate = self
    }
}
extension ProfilePicPhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
