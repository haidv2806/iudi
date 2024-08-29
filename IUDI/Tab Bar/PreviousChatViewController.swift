//
//  PreviousChatViewController.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//

import UIKit
import KeychainSwift

class PreviousChatViewController: UIViewController, ServerImageHandle {
    @IBOutlet weak var userAvatar: UIImageView!
//    @IBOutlet weak var userHeartImg: UIImageView!
    @IBOutlet weak var targetAvatar: UIImageView!
//    @IBOutlet weak var targetHeartImg: UIImageView!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    let keychain = KeychainSwift()
    var testImage : UIImage?
//    var userProfile : User?
    var dataUser : Distance?
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        setupView()
//        targetAvatar.image = testImage
        getUserProfile()
        
    }
    
    func rotationImage(angle: CGFloat) -> CGFloat {
        let angleInDegrees: CGFloat = angle // Điều chỉnh góc theo nhu cầu của bạn
        let angleInRadians = angleInDegrees * .pi / 180.0
        return angleInRadians
    }
    func setupView(){
//        userAvatar.layer.cornerRadius = 8
//        targetAvatar.layer.cornerRadius = 8
//        userAvatar.frame.size = CGSize(width: 165, height: 165)
//        userAvatar.layer.cornerRadius = userAvatar.frame.size.width / 2
//        userAvatar.contentMode = .scaleAspectFit
//        userAvatar.clipsToBounds = true
//        userAvatar.transform = CGAffineTransform(rotationAngle: rotationImage(angle: -19))
//        userHeartImg.transform = CGAffineTransform(rotationAngle: rotationImage(angle: -19))
        
//        targetAvatar.frame.size = CGSize(width: 165, height: 165)
//        targetAvatar.layer.cornerRadius = targetAvatar.frame.size.width / 2
//        targetAvatar.contentMode = .scaleAspectFit
//        targetAvatar.clipsToBounds = true
        
        
        // Set the image to the UIImageView
//        self.userAvatar.image = resizedImage
//        self.userAvatar.layer.cornerRadius = 140 / 2
//        self.userAvatar.clipsToBounds = true
//        targetAvatar.transform = CGAffineTransform(rotationAngle: rotationImage(angle: 10))
//        targetHeartImg.transform = CGAffineTransform(rotationAngle: rotationImage(angle: 10))
        standardBtnCornerRadius(button: chatBtn)
        standardBtnCornerRadius(button: backBtn)
//        backBtn.layer.borderColor = Constant.mainBorderColor.cgColor
//        backBtn.layer.borderWidth = Constant.borderWidth
        backBtn.clipsToBounds = true
    }
    
    func getUserProfile(){
        showLoading(isShow: true)
        guard let userName = keychain.get("username") else {
            print("không có userName")
            return
        }
        let url = "profile/" + userName
        APIService.share.apiHandleGetRequest(subUrl: url, data: User.self) {  [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            switch result {
            case .success(let data):
                guard let userData = data.users?.first else {
                    return
                }
                guard let avatarUrl = userData.avatarLink else {
                    print("dữ liệu nil")
                    return
                }
                self.userName = userData.fullName
                DispatchQueue.main.async {
//                    self.userAvatar.image = self.convertStringToImage(imageString: avatarUrl)
                    
//                    self.convertUrlToImage(url: avatarUrl) { image in
//                        DispatchQueue.main.async {
//                            if let image = image {
//                                // Set the image to the UIButton
//                                self.userAvatar.image = image
//                            } else {
//                                // Handle the case where the image could not be loaded
//                                print("Failed to load image.")
//                            }
//                        }
//                    }
                    
                    self.convertUrlToImage(url: avatarUrl) { image in
                        DispatchQueue.main.async {
                            if let image = image {
                                // Resize the image to 140x140 pixels
                                let resizedImage = image.resize(to: CGSize(width: 165, height: 165))
                                
                                // Set the image to the UIImageView
                                self.userAvatar.image = resizedImage
                                self.userAvatar.layer.cornerRadius = 165 / 2
                                self.userAvatar.clipsToBounds = true
                            } else {
                                // Handle the case where the image could not be loaded
                                print("Failed to load image.")
                            }
                        }
                    }
                    
                }
                self.showLoading(isShow: false)
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
    
    func gotoChatVC(){
        let vc = MessageViewController()
        // Khởi tạo một instance của struct MessageUserData
        let messageUserData = MessageUserData(
            otherUserAvatar: targetAvatar.image!, // Ảnh đại diện của người dùng khác
            
            otherUserFullName: dataUser?.fullName ?? "",
            otherUserId: "\(dataUser?.userID ?? 0)", otherLastActivityTime: dataUser?.lastActivityTime ?? "Wed, 27 Mar 2024 11:43:58 GMT"
        )
        vc.messageUserData = messageUserData
        vc.backIntroductVC = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case chatBtn :
            print("chatBtn")
            gotoChatVC()
        case backBtn:
            print("backBtn")
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
}


