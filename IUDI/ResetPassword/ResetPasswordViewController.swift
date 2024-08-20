//
//  ResetPasswordViewController.swift
//  IUDI
//
//  Created by LinhMAC on 12/03/2024.
//

import UIKit

class ResetPasswordViewController: UIViewController,CheckValid {
    @IBOutlet weak var userEmailTF: UITextField!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        standardBorder(textField: userEmailTF)
        standardBtnCornerRadius(button: resetBtn)
        checkInput()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    func checkInput() {
        guard let userEmail = userEmailTF.text else {
            resetBtn.isEnabled = false
            resetBtn.layer.opacity = 0.5
            print("fail")
            return
        }
        if emailValidator(email: userEmail){
            resetBtn.isEnabled = true
            resetBtn.layer.opacity = 1
            print("true")
        }else {
            resetBtn.isEnabled = false
            resetBtn.layer.opacity = 0.5
            print("fail")
        }
    }
    func resetBtnHandle() {
        struct ResetResponse: Codable {
            let message: String?
            let status: Int?
        }
        showLoading(isShow: true)
        guard let userEmail = userEmailTF.text else {
            showLoading(isShow: false)
            showAlert(title: "Lỗi", message: "Vui lòng thử lại sau")
            return
        }
        let parameters: [String: Any] = [
            "Email": userEmail
        ]
        
        APIService.share.apiHandle(method: .post ,subUrl: "forgotPassword", parameters: parameters, data: ResetResponse.self) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showLoading(isShow: false)
                switch result {
                case .success(_):
                    self.showLoading(isShow: false)
                    self.showAlert(title: "Thông báo", message: "Cài lại mật khẩu thành công")
                case .failure(let error):
                    self.showLoading(isShow: false)
                    switch error {
                    case .server(let message), .network(let message):
                        self.showAlert(title: "Lỗi", message: message)
                        print("message:\(message)")
                    }
                }
            }
        }
    }
    
    
    @IBAction func emailDidChanged(_ sender: UITextField) {
        checkInput()
    }
    @IBAction func handleBtn(_ sender: UIButton) {
        switch sender {
        case resetBtn :
            resetBtnHandle()
        case loginBtn:
            navigationController?.popToRootViewController(animated: true)
        default:
            break
        }
    }
}
