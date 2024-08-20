//
//  PostsGroupViewController.swift
//  IUDI
//
//  Created by Quoc on 29/02/2024.
//

import UIKit
import Alamofire

class PostsGroupViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var groupID: Int?
    
    var placeholderLabel: UILabel!
    
    var personPost: [Post] = []
    
    var hi:ImgModel = ImgModel()
    
    var displayUrl: String?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var onOffSwitch: UISwitch!
    @IBOutlet weak var viewGroup: UIView!
    @IBOutlet weak var avatarOfThePoster: UIImageView!
    @IBOutlet weak var nameOfThePoster: UILabel!
    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var tagPersonButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var fellingButton: UIButton!
    @IBOutlet weak var fileGifButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        avatarOfThePoster.layer.cornerRadius = avatarOfThePoster.frame.width / 2
        viewGroup.layer.cornerRadius = 20
        
        //        applBorder(to: addImageButton)
        //        applBorder(to: tagPersonButton)
        //        applBorder(to: cameraButton)
        //        applBorder(to: checkInButton)
        //        applBorder(to: fellingButton)
        //        applBorder(to: fileGifButton)
        //
        //        alignTextLeft(for: addImageButton)
        //        alignTextLeft(for: tagPersonButton)
        //        alignTextLeft(for: cameraButton)
        //        alignTextLeft(for: checkInButton)
        //        alignTextLeft(for: fellingButton)
        //        alignTextLeft(for: fileGifButton)
        
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
        
        // Thiết lập nút "Đăng" làm rightBarButtonItem
        let publishButton = UIButton(type: .custom)
        publishButton.setTitle("Đăng", for: .normal)
        publishButton.addTarget(self, action: #selector(publishButtonTapped), for: .touchUpInside)
        publishButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        publishButton.setTitleColor(.blue, for: .normal)
        let publishBarButtonItem = UIBarButtonItem(customView: publishButton)
        navigationItem.rightBarButtonItem = publishBarButtonItem
        
    }
    @IBAction func uploadImageButtonTapper(_ sender: Any) {
        
    }
    
    func updateTextViewHeight(){
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textViewHeightConstraint.constant = newSize.height
        view.layoutIfNeeded()
        
    }
    
    func uploadData() {
        let url = "https://api.iudi.xyz/api/forum/add_post/118" // Địa chỉ API của server
        
        // Lấy nội dung từ textView để gửi lên server
        guard let content = textView.text else {
            print("Không có nội dung để gửi.")
            return
        }
        
        // Tạo đối tượng bài đăng với nội dung từ textView
        let param : [String: Any] = [
            "GroupID": groupID ?? "",
            "Title": "sddw",
            "Content":textView.text ?? "",
            "PostLatitude":"40",
            "PostLongitude":"50",
            "PhotoURL": [displayUrl] // Use displayUrl here
        ]
        debugPrint("url: \(displayUrl)")
        
        // Gửi dữ liệu lên server
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).validate(statusCode: 200...299).responseDecodable(of: PostData.self) { response in
            switch response.result {
            case .success(let data):
                if let dataArray = data.post {
                    self.personPost = dataArray
                    self.loadData(data: self.personPost.first)
                    debugPrint("Dữ liệu đã được gửi thành công lên server.")
                    
                }
                //                 Xử lý phản hồi thành công từ server nếu cần
            case .failure(let error):
                debugPrint("Lỗi khi gửi dữ liệu:", error.localizedDescription)
                // Xử lý lỗi nếu có
            }
        }
    }
    
    // Your existing methods
    
    func uploadImageToServer(completion: @escaping (Bool) -> Void) {
        guard let userImage = imageView.image,
              let imageData = userImage.pngData() else {
            completion(false)
            // Xử lý trường hợp không có ảnh
            return
        }
        
        // Chuyển đổi dữ liệu ảnh thành dạng base64
        let dataImage = imageData.base64EncodedString(options: .lineLength64Characters)
        
        // Gửi dữ liệu ảnh dưới dạng Data qua API
        APIServiceImage.shared.PostImageServer(param: imageData) { data, error in
            if let data = data {
                self.hi = data
                print("display_url : \(self.hi.display_url)")
                // Save the display URL
                self.displayUrl = self.hi.display_url
                self.uploadData()
            } else {
                completion(false)
            }
        }
    }
    func uploadImageToServer1(imageUrl: String) {
        let parameters: [String: Any] = [
            "PhotoURL": imageUrl,
            "SetAsAvatar":true
        ]
        APIService.share.apiHandle(method:.post ,subUrl: "profile/add_image/37", parameters: parameters, data: UserData.self) { result in
            self.showLoading(isShow: false)
            switch result {
            case .success(let data):
                print("data: \(data)")
            case .failure(let error):
                print(error.localizedDescription)
                switch error {
                case .server(let message):
                    self.showAlert(title: "lỗi1", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi", message: message)
                }
            }
        }
    }
    @objc func publishButtonTapped() {
        uploadImageToServer { success in
            if success {
                DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
                // Xử lý trường hợp tải lên không thành công nếu cần
                debugPrint("Upload failed. Unable to pop ViewController.")
            }
        }
    }
    func loadData(data: Post?) {
        textView.text = data?.content
        nameOfThePoster.text = data?.ipPosted
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
    
    @IBAction func selectImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
extension PostsGroupViewController: PostsGroupViewControllerDelegate {
    func getGroupID() -> Int? {
        return groupID
    }
}
