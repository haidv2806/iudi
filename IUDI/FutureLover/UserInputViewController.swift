//
//  UserInputViewController.swift
//  IUDI
//
//  Created by LinhMAC on 27/05/2024.
//

import UIKit
import Alamofire
import Kingfisher

struct SwapImage: Codable {
    let images: [String]
}

class UserInputViewController: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var pickDateBtn: UIButton!
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var otherGenderBtn: UIButton!
    @IBOutlet weak var matchBtn: UIButton!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userMiniImage: UIImageView!
    @IBOutlet weak var userBirthDate: UITextField!
    @IBOutlet weak var imageLeading: NSLayoutConstraint!
    
    let datePicker = UIDatePicker()
    let imagePicker = UIImagePickerController()
    var gender = "nam"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        createDatePicker()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            imageLeading.constant = 70
        } else {
            imageLeading.constant = 30
        }
    }
    @IBAction func textDidChange(_ sender: Any) {
        checkUserInfo()
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case backBtn:
            self.navigationController?.popToRootViewController(animated: true)
        case addImageBtn:
            creatPickImageSheet()
        case pickDateBtn:
            userBirthDate.becomeFirstResponder()
        case maleBtn:
            genderBtnHandle(selectBtn: maleBtn,
                            otherBtn: [femaleBtn,otherGenderBtn])
            self.gender = "nam"

        case femaleBtn:
            genderBtnHandle(selectBtn: femaleBtn,
                            otherBtn: [maleBtn,otherGenderBtn])
            self.gender = "nu"

        case otherGenderBtn:
            genderBtnHandle(selectBtn: otherGenderBtn,
                            otherBtn: [femaleBtn,maleBtn])
        case matchBtn:
            pushImageToServer()
        default:
            break
        }
        
    }
    
    func setupView(){
        userImage.layer.cornerRadius = 10
        userImage.clipsToBounds = true
        addImageBtn.layer.cornerRadius = addImageBtn.bounds.width / 2
        addImageBtn.clipsToBounds = true
        genderBtn.layer.cornerRadius = 5
        genderBtn.clipsToBounds = true
        matchBtn.layer.cornerRadius = 8
        matchBtn.clipsToBounds = true
        userBirthDate.layer.cornerRadius = 5
        userBirthDate.layer.borderWidth = 1
        let color = UIColor(red: 0/255.0, green: 135/255.0, blue: 72/255.0, alpha: 1.0)
        userBirthDate.layer.borderColor = color.cgColor
        userBirthDate.clipsToBounds = true
        
        genderBtnHandle(selectBtn: maleBtn,
                        otherBtn: [femaleBtn,otherGenderBtn])
        matchBtn.isEnabled = false
        matchBtn.layer.opacity = 0.5
    }
    func genderBtnHandle(selectBtn: UIButton, otherBtn: [UIButton]){
        let seletedImage = UIImage(systemName: "circle.fill")
        let unSeletedImage = UIImage(systemName: "circle")
        selectBtn.setImage(seletedImage, for: .normal)
        for button in otherBtn {
            button.setImage(unSeletedImage, for: .normal)
        }
    }
    func checkUserInfo() {
        if userImage.image != nil && userBirthDate.text?.count ?? 0 > 0 {
            matchBtn.isEnabled = true
            matchBtn.layer.opacity = 1
        } else {
            matchBtn.isEnabled = false
            matchBtn.layer.opacity = 0.5
        }
    }
    
}
// MARK: - Tạo Toolbar khi chọn ngày sinh
extension UserInputViewController: DateConvertFormat {
    func createDatePicker(){
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            // Fallback on earlier versions
        }
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        userBirthDate.inputView = datePicker
        userBirthDate.inputAccessoryView = createToolbar()
    }
    func createToolbar() -> UIToolbar {
        let toolbar =  UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtn))
        let middleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBtn))
        toolbar.setItems([doneBtn, middleSpace, cancelBtn], animated: true)
        return toolbar
    }
    @objc func doneBtn(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.userBirthDate.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
        self.checkUserInfo()
    }
    @objc func cancelBtn() {
        self.view.endEditing(true)
    }
}
// MARK: - Tạo ImagePicker
extension UserInputViewController {
    func pushImageToServer() {
        guard let image = userImage.image else { return }
        let url = "https://databaseswap.mangasocial.online/upload-gensk/3?type=src_\(gender.lowercased())"
        //        print("url: \(url)")
        
        // Chuyển đổi UIImage thành Data
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        // Các headers cho yêu cầu
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]

        let jsonString = "{\"message\":\"We cannot identify the face in the photo you provided, please upload another photo\"}"
        
        // Tạo yêu cầu tải lên với Alamofire
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "src_img", fileName: "userImage.jpg", mimeType: "image/jpeg")
        }, to: url, headers: headers)
        .validate(statusCode: 200...299)
        .responseString { response in
            switch response.result {
            case .success(let data):
                print("Raw Response: \(data)")
                if data == jsonString {
                    self.showAlert(title: "Lỗi", message: "Không thể nhận diện khuôn mặt, xin vui lòng chọn ảnh khác")
                } else {
                    self.getImageSwap(urlImage: data)
                }
            case .failure(let error):
                print("Upload failed with error: \(error)")
            }
        }
    }
    
    func getImageSwap(urlImage: String) {
        showLoading(isShow: true)
        let formattedUrlImage = urlImage.replacingOccurrences(of: "\"", with: "")
        let url = "https://thinkdiff.us/getdata/swap/event_iudi?id_user=279&gioi_tinh=\(gender.lowercased() )"
        let header : HTTPHeaders = [
            "link1": formattedUrlImage
        ]
        print("url: \(url)")
        print("header: \(header)")
        AF.request(url, method: .get, headers: header)
            .validate(statusCode: 200...299)
            .responseDecodable(of: SwapImage.self) { response in
                switch response.result {
                case .success(let data):
                    print("data: \(data.images.count)")
                    self.showLoading(isShow: false)
                    let vc = PredictLoverResultViewController()
                    vc.image = data
                    self.navigationController?.pushViewController(vc, animated: true)
                case .failure(let error):
                    self.showLoading(isShow: false)
                    print("error getImageSwap: \(error.localizedDescription)")
                    self.showAlert(title: "Lỗi", message: error.localizedDescription)
                }
            }
    }
    
}
// MARK: - Tạo ImagePicker
extension UserInputViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        userImage.image = image
        checkUserInfo()
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    func creatPickImageSheet(){
        let aleartVC = UIAlertController(title: "Chọn ảnh", message: "Chọn ảnh", preferredStyle: .alert)
        let openCamera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.openCamera()
        }
        let openGallary = UIAlertAction(title: "Thư viện", style: .default) { _ in
            self.openGallary()
        }
        let cancelBtn = UIAlertAction(title: "Hủy", style: .default)
        aleartVC.addAction(openCamera)
        aleartVC.addAction(openGallary)
        aleartVC.addAction(cancelBtn)
        
        present(aleartVC, animated: true)
    }
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        } else {
            showAlert(title: "Lỗi", message: "Thiết bị lỗi camera")
        }
    }
    func openGallary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        } else {
            showAlert(title: "Lỗi", message: "Không truy cập được thư viện")
        }
    }
    
}

