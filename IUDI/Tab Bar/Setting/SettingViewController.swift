//
//  SettingViewController.swift
//  IUDI
//
//  Created by Quoc on 27/02/2024.
//

import UIKit

class SettingViewController: UIViewController, ServerImageHandle {
    
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var IntroduceAboutUsButton: UIButton!
    @IBOutlet weak var privacyTermsButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userAvatarHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    let userID = UserInfo.shared.getUserID()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
        setupView()


        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        userAvatarHeight.constant = view.frame.width / 2
        let logoutButtonOrigin = logoutButton.convert(logoutButton.bounds.origin, to: view)
//        print("Tọa độ của logoutButton đối với superview: \(logoutButtonOrigin.y)")
        scrollViewHeight.constant = logoutButtonOrigin.y + 60
    }
    override func viewDidLayoutSubviews() {
        let cornerRadius = userAvatar.bounds.width
        userAvatar.layer.cornerRadius = cornerRadius / 2
        userAvatar.clipsToBounds = true
        print("frame width: \(cornerRadius)")
        print("frame width: \(cornerRadius/2)")
    }
    
    func setupView(){
        logoutButton.layer.cornerRadius = 8
        applBorder(to: privacyButton)
        applBorder(to: IntroduceAboutUsButton)
        applBorder(to: groupButton)
        applBorder(to: notificationButton)
        applBorder(to: privacyTermsButton)
        applBorder(to: privacyPolicyButton)
    }
    
    func loadUserInfo(){
        let userInfo = UserInfoCoreData.shared.fetchProfileFromCoreData()
        userAvatar.image = convertStringToImage(imageString: userInfo?.userAvatarUrl ?? "")
        userFullName.text = userInfo?.userFullName
        userEmail.text = userInfo?.userEmail
    }
    
    private func applBorder(to button: UIButton){
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: button.bounds.height + 10.0, width: button.bounds.width, height: 0.5)
        bottomBorder.backgroundColor = UIColor.black.cgColor
        button.layer.addSublayer(bottomBorder)
    }
    
    func goToGroupViewController() {
        guard let tabBarController = self.tabBarController else {
            print("lỗi tabBarController")
            return
        }
        if let viewControllers = tabBarController.viewControllers {
            for (index, viewController) in viewControllers.enumerated() {
                if let navController = viewController as? UINavigationController,
                   navController.viewControllers.first is GroupViewController {
                    tabBarController.selectedIndex = index
                    break
                }
            }
        }
    }
    
    func logoutHandle(){
        struct LogoutResponse: Codable {
            let isLoggedIn: Bool?
            let lastActivityTime: String?
            enum CodingKeys: String, CodingKey {
                case isLoggedIn = "IsLoggedIn"
                case lastActivityTime = "LastActivityTime"
            }
        }
        guard let userID = userID else {return}
        let subUrl = "logout/\(userID)"
        APIService.share.apiHandle(method: .post, subUrl: subUrl,data: LogoutResponse.self) { [weak self] result in
            guard let self = self else{return}
            switch result {
            case .success(let data):
                print("success")
                UserDefaults.standard.didLogin = false
                UserDefaults.standard.didOnMain = false
                emitOffline()
                AppDelegate.scene?.goToLogin()
            case .failure(let error):
                switch error {
                case .network(let message):
                    showAlert(title: "Lôi", message: message)
                case .server(let message):
                    showAlert(title: "Lôi", message: message)
                }
            }
        }
    }
    
    func emitOffline() {
        print("emitOnline")
        let messageData: [String: Any] = [
            "userId": userID ?? ""
        ]
        SocketIOManager.shared.mSocket.emit("offline", messageData)
    }
    
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case groupButton :
            goToGroupViewController()
        case privacyButton:
            let vc = PrivacyViewController()
            navigationController?.pushViewController(vc, animated: true)
        case notificationButton:
            let vc = NotificationViewController()
            navigationController?.pushViewController(vc, animated: true)
        case privacyTermsButton:
            let vc = AboutViewController()
            navigationController?.pushViewController(vc, animated: true)
            vc.title = "Điều khoản bảo mật"
        case privacyPolicyButton:
            let vc = AboutViewController()
            navigationController?.pushViewController(vc, animated: true)
            vc.title = "Chính sách bảo mật"
        case IntroduceAboutUsButton:
            let vc = AboutViewController()
            navigationController?.pushViewController(vc, animated: true)
            vc.title = "Giới thiệu về chúng tôi"
        case logoutButton:
            logoutHandle()
        default:
            break
        }
    }
}
