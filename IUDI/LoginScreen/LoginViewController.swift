//
//  LoginViewController.swift
//  IUDI
//
//  Created by LinhMAC on 22/02/2024.

import UIKit
import Alamofire
import SwiftyJSON
//import KeychainSwift
import CoreLocation

class LoginViewController: UIViewController, UITextFieldDelegate, CheckValid {
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var userPasswordTF: UITextField!
    @IBOutlet weak var rememberPasswordBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    var isRememberPassword = false
    let locationManager = CLLocationManager()
    var userLongitude : String?
    var userLatitude : String?
    var userIpAdress : String?
    var userData : UserData?
    let userInfo = UserInfo.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        checkLocationAuthorizationStatus()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        userNameTF.delegate = self
        userPasswordTF.delegate = self
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        requestLocation()
        userPasswordTF.text = userInfo.getUserPassword()
        userNameTF.text = userInfo.getUserName()
        checkInput()
    }
    @IBAction func UserInputDidChanged(_ sender: UITextField) {
        checkInput()
        setupView()
    }
    @IBAction func handleBtn(_ sender: UIButton) {
        switch sender {
        case loginBtn :
            loginHandle()
            print("loginhandle")
        case rememberPasswordBtn :
            checkBoxHandle()
            checkInput()
        case registerBtn:
            //            loginHandle()
            goToRegisterVC()
        case forgetPasswordBtn:
            goToResetPasswordVC()
        default:
            break
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Có thể thực hiện các xử lý khác sau khi textField kết thúc editing
    }
    func goToResetPasswordVC(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(identifier: "ResetPasswordViewController") as? ResetPasswordViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    func goToRegisterVC(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(identifier: "RegisterViewController") as? RegisterViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    func setupView(){
        rememberPasswordBtn.isSelected = true
        // Đặt hình ảnh ban đầu cho nút
        let checkImage = UIImage(systemName: "checkmark.square")
        rememberPasswordBtn.setBackgroundImage(checkImage, for: .normal)
        standardBorder(textField: userNameTF)
        standardBorder(textField: userPasswordTF)
        standardBtnCornerRadius(button: loginBtn)
    }
    
    func saveUserInfo(){
        guard let userName = userNameTF.text, let password = userPasswordTF.text else {
            return
        }
        if rememberPasswordBtn.isSelected {
            userInfo.saveUserPassword(password: password)
        } else {
            userInfo.deleteUserPw()
            print("password không được lưu")
        }
        userInfo.saveUserName(userName: userName)
    }
    
    func checkBoxHandle(){
        let checkImage = UIImage(systemName: "checkmark.square")
        let uncheckImage = UIImage(systemName: "square")
        let buttonImage = rememberPasswordBtn.isSelected ? uncheckImage : checkImage
        rememberPasswordBtn.setBackgroundImage(buttonImage, for: .normal)
        print("\(rememberPasswordBtn.isSelected)")
        rememberPasswordBtn.isSelected = !rememberPasswordBtn.isSelected
    }
    
    func checkInput() {
        guard let userName = userNameTF.text, let userPassword = userPasswordTF.text else {
            loginBtn.isEnabled = false
            loginBtn.layer.opacity = 0.5
            print("fail")
            return
        }
        if checkUserNameValid(userName: userName) && passwordValidator(password: userPassword){
            loginBtn.isEnabled = true
            loginBtn.layer.opacity = 1
            print("true")
        }else {
            loginBtn.isEnabled = false
            loginBtn.layer.opacity = 0.5
            print("userName:\(userName)")
            print("fail \(checkUserNameValid(userName: userName)),\(passwordValidator(password: userPassword)) ")
        }
    }
    func loginHandle() {
        showLoading(isShow: true)
        guard let username = userNameTF.text,
              let password = userPasswordTF.text,
              let longitude = userLongitude,
              let latitude = userLatitude,
              let ipAdress = userIpAdress else {
            print("user nil")
            showLoading(isShow: false)
            showAlert(title: "Lỗi", message: "Vui lòng thử lại sau")
            return
        }
        let parameters: [String: Any] = [
            "Username": username,
            "Password": password,
            "Latitude": latitude,
            "Longitude": longitude,
            "LastLoginIP": ipAdress
        ]
        print("parameters: \(parameters)")
        APIService.share.apiHandle(method:.post ,subUrl: "login", parameters: parameters, data: UserData.self) { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            switch result {
            case .success(let data):
                showLoading(isShow: false)
                guard let userID = data.user?.users?.first?.userID else {
                    print("user data nil")
                    return
                }
                userInfo.saveUserID(userID: String(userID))
                self.saveUserInfo()
                UserDefaults.standard.didLogin = true
//                self.showLoading(isShow: false)
                guard let userBio = data.user?.users?.first?.bio else {
                    AppDelegate.scene?.goToProfile()
                    return
                }
                UserDefaults.standard.didOnMain = true
                AppDelegate.scene?.setupTabBar()
            case .failure(let error):
                showLoading(isShow: false)
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
}
// MARK: - Các hàm liên quan vị trí
extension LoginViewController: CLLocationManagerDelegate {
    
    func fetchCurrentLocation() {
        showLoading(isShow: true)
        // check xem có đia điểm hiện tại không,nếu không thì không làm gì cả
        guard let currentLocation = locationManager.location else {
            print("Current location not available.")
            showLoading(isShow: false)
            return
        }
        APIService.share.getLocationByAPI { [weak self] (longtitude, latitude, ipAdress) in
            guard let self = self else {
                return
            }
            self.userIpAdress = ipAdress
        }
        let geocoder = CLGeocoder()
        // lấy placemark
        geocoder.reverseGeocodeLocation(currentLocation) { [weak self] (placemarks, error) in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                self?.showLoading(isShow: false)
                return
            }
            let currentLongitude = currentLocation.coordinate.longitude
            let currentLatitude = currentLocation.coordinate.latitude
            self?.userLongitude = String(Int(currentLongitude))
            self?.userLatitude = String(Int(currentLatitude))
            self?.showLoading(isShow: false)
        }
    }
    
    func requestLocation() {
        print("requestLocation")
        // đưa nó vào một luồng khác để tránh làm màn hình người dùng đơ
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                // khai báo delegate để nhận thông tin thay đổi trạng thái vị trí
                self.locationManager.delegate = self
                // yêu cầu độ chính xác khi dò vi trí
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                // update vị trí cho các hàm của CLLocationManager
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func checkLocationAuthorizationStatus() {
        if #available(iOS 14.0, *) {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                // Yêu cầu quyền sử dụng vị trí khi ứng dụng đang được sử dụng
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                APIService.share.getLocationByAPI { [weak self] (longtitude, latitude, ipAdress) in
                    guard let self = self else {
                        return
                    }
                    self.userLongitude = longtitude
                    self.userLatitude = latitude
                    self.userIpAdress = ipAdress
                }
                break
            case .authorizedWhenInUse, .authorizedAlways:
                // Bắt đầu cập nhật vị trí và gọi api nếu được cấp quyền
                locationManager.startUpdatingLocation()
                fetchCurrentLocation()
            @unknown default:
                break
            }
        } else {
            // Fallback on earlier versions
        }
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Kiểm tra lại trạng thái ủy quyền khi nó thay đổi
        checkLocationAuthorizationStatus()
    }
}
