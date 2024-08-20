//
//  SettingViewController.swift
//  IUDI
//
//  Created by Quoc on 27/02/2024.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var IntroduceAboutUsButton: UIButton!
    @IBOutlet weak var privacyTermsButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.layer.cornerRadius = 8
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        applBorder(to: privacyButton)
        applBorder(to: IntroduceAboutUsButton)
        applBorder(to: groupButton)
        applBorder(to: notificationButton)
        applBorder(to: privacyTermsButton)
        applBorder(to: privacyPolicyButton)
        
        alignTextLeft(for: privacyButton)
        alignTextLeft(for: IntroduceAboutUsButton)
        alignTextLeft(for: groupButton)
        alignTextLeft(for: notificationButton)
        alignTextLeft(for: privacyTermsButton)
        alignTextLeft(for: privacyPolicyButton)
        // Do any additional setup after loading the view.
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
    
    @IBAction func groupTapper(_ sender: Any) {
        let vc = GroupViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Privacy(_ sender: Any) {
        let vc = PrivacyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Notification(_ sender: Any) {
        let vc = NotificationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func privacyTermsTapper(_ sender: Any) {
        let vc = AboutViewController()
            navigationController?.pushViewController(vc, animated: true)
            vc.title = "Điều khoản bảo mật"
        
    }
    
    @IBAction func privacyPolicyTapper(_ sender: Any) {
        let vc = AboutViewController()
            navigationController?.pushViewController(vc, animated: true)
            vc.title = "Chính sách bảo mật"
        
    }
    
    @IBAction func introduceAboutUsTapper(_ sender: Any) {
        let vc = AboutViewController()
            navigationController?.pushViewController(vc, animated: true)
            vc.title = "Giới thiệu về chúng tôi"
    }
}
