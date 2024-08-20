//
//  PostsGroupViewController.swift
//  IUDI
//
//  Created by Quoc on 29/02/2024.
//

import UIKit
import Alamofire

class PostsGroupViewController: UIViewController, UITextViewDelegate {
    
    var groupID: Int?
    var placeholderLabel: UILabel!
    var personPost: [Post] = []
    var imagePicker = UIImagePickerController()
    weak var postsGroupVCDelegate : PostsGroupVCDelegate?

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var onOffSwitch: UISwitch!
    @IBOutlet weak var viewGroup: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var postbBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var imageLeadingConstant: NSLayoutConstraint!
    @IBOutlet weak var imageTrailingConstant: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad {
            imageLeadingConstant.constant = 50
            imageTrailingConstant.constant = 50
        } else {
            // Nếu không, giả sử đây là iPhone
            imageLeadingConstant.constant = 15
            imageTrailingConstant.constant = 15
        }
        loadUserInfo()
        textView.delegate = self
        userAvatar.layer.cornerRadius = userAvatar.frame.width / 2
        viewGroup.layer.cornerRadius = 20
        
        //Tạo label placeholder
        placeholderLabel = UILabel()
        placeholderLabel.text = "Nhập nội dung..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 18) // Font của placeholder
        placeholderLabel.textColor = UIColor.gray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize ?? 16) / 2) // Vị trí của placeholder
        
        //Thêm label placeholder vào UITextView
        textView.addSubview(placeholderLabel)
        
        // Ẩn hiện placeholder tùy thuộc vào nội dung của UITextView
        placeholderLabel.isHidden = !textView.text.isEmpty
        self.navigationController?.isNavigationBarHidden = true

    }
    func loadUserInfo(){
        let userInfo = UserInfoCoreData.shared.fetchProfileFromCoreData()
        userAvatar.image = convertStringToImage(imageString: userInfo?.userAvatarUrl ?? "")
    }
    
    func updateTextViewHeight(){
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textViewHeightConstraint.constant = newSize.height
        view.layoutIfNeeded()
    }
    private func applBorder(to button: UIButton){
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: button.bounds.height + 10.0, width: button.bounds.width, height: 0.5)
        bottomBorder.backgroundColor = UIColor.black.cgColor
        button.layer.addSublayer(bottomBorder)
    }
    
    private func alignTextLeft(for button: UIButton) {
        button.contentHorizontalAlignment = .left
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        //updateTextViewHeight()
    }

    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case backBtn :
            navigationController?.popViewController(animated: true)
        case postbBtn:
            uploadData()
        case addImageBtn:
            pickImage()
        default:
            break
        }
    }
}
// MARK: - Load image slectecd
extension PostsGroupViewController: ServerImageHandle {
    func uploadData() {
        guard let userID = UserInfo.shared.getUserID() else {return}
        let subUrl = "forum/add_post/\(userID)" // Địa chỉ API của server
        var param : [String: Any]
        var imageUrl = String()
        if let image = postImage.image {
            imageUrl = convertImageToString(img: image)
            print(" có image")
             param = [
                "GroupID": groupID ?? "",
                "Title": "sddw",
                "Content":textView.text ?? "",
                "PostLatitude":"40",
                "PostLongitude":"50",
                "PhotoURL": [imageUrl] // Use displayUrl here
            ]
        } else {
            print("không có image")
            param = [
               "GroupID": groupID ?? "",
               "Title": "sddw",
               "Content":textView.text ?? "",
               "PostLatitude":"40",
               "PostLongitude":"50"
           ]
        }
//        print("param:\(param)")
        APIService.share.apiHandle(method: .post, subUrl: subUrl, parameters: param, data: PostData.self) { result in
            switch result {
            case .success(let data):
                print("uploadData sucess")
                self.navigationController?.popViewController(animated: true)
                self.postsGroupVCDelegate?.loadPostGroupFrombegin()
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                self.showLoading(isShow: false)
                switch error{
                case .server(let message):
                    self.showAlert(title: "lỗi", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi", message: message)
                }
            }
        }
    }
}

// MARK: - Load image slectecd
extension PostsGroupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        // Update the UI with the picked image
        
        postImage.image = pickedImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func pickImage1() {
        let titleAlert = NSLocalizedString("Choose Image", comment: "")
        let messageAlert = NSLocalizedString("Choose your option", comment: "")
        let alertViewController = UIAlertController(title: titleAlert,
                                                    message: messageAlert,
                                                    preferredStyle: .alert)
        
        // Thêm actions cho iPhone và iPad
        let galleryText = NSLocalizedString("Gallery", comment: "")
        let gallery = UIAlertAction(title: galleryText,
                                    style: .default) { (_) in
            self.openGallary()
        }
        alertViewController.addAction(gallery)
        
        // Kiểm tra xem thiết bị hỗ trợ camera hay không
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraText = NSLocalizedString("Camera", comment: "")
            let camera = UIAlertAction(title: cameraText,
                                       style: .default) { (_) in
                self.openCamera()
            }
            alertViewController.addAction(camera)
        }
        
        let cancelText = NSLocalizedString("Cancel", comment: "")
        let cancel = UIAlertAction(title: cancelText, style: .cancel) { (_) in
        }
        alertViewController.addAction(cancel)
        
        // Nếu là iPad, thêm actions khác để hiển thị dưới dạng popover
        if let popoverPresentationController = alertViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        
        present(alertViewController, animated: true, completion: nil)
    }


    func pickImage() {
        let titleAlert = NSLocalizedString("Choose Image", comment: "")
        let messageAlert = NSLocalizedString("Choose your option", comment: ""
        )
        let alertViewController = UIAlertController(title: titleAlert,
                                                    message: messageAlert,
                                                    preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera",
                                   style: .default) { (_) in
            self.openCamera()
        }
        let galleryText = NSLocalizedString("Gallery", comment: "")
        let gallery = UIAlertAction(title: galleryText,
                                    style: .default) { (_) in
            self.openGallary()
        }
        let cancelText = NSLocalizedString("Cancel", comment: "")
        let cancel = UIAlertAction(title: cancelText, style: .cancel) { (_) in
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(cancel)
        present(alertViewController, animated: true, completion: nil)
    }
}
// MARK: - Alert Choose image
extension PostsGroupViewController {
    fileprivate func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            /// Cho phép edit ảnh hay là không
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let errorText = NSLocalizedString("Error", comment: "")
            let errorMessage = NSLocalizedString("Device does not have a camera", comment: "")
            
            let alertWarning = UIAlertController(title: errorText,
                                                 message: errorMessage,
                                                 preferredStyle: .alert)
            let cancelText = NSLocalizedString("Cancel", comment: "")
            let cancel = UIAlertAction(title: cancelText,
                                       style: .cancel) { (_) in
                print("Cancel")
            }
            alertWarning.addAction(cancel)
            self.present(alertWarning, animated: true, completion: nil)
        }
    }

    fileprivate func openCamera1() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            /// Cho phép edit ảnh hay là không
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let errorText = NSLocalizedString("Error", comment: "")
            let errorMessage = NSLocalizedString("Divice not have camera", comment: "")
            
            let alertWarning = UIAlertController(title: errorText,
                                                 message: errorMessage,
                                                 preferredStyle: .alert)
            let cancelText = NSLocalizedString("Cancel", comment: "")
            let cancel = UIAlertAction(title: cancelText,
                                       style: .cancel) { (_) in
                print("Cancel")
            }
            alertWarning.addAction(cancel)
            self.present(alertWarning, animated: true, completion: nil)
        }
    }
    fileprivate func openGallary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .photoLibrary
            /// Cho phép edit ảnh hay là không
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        }
    }
}
