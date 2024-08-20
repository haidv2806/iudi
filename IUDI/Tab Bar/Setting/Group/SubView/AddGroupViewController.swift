//
//  AddGroupViewController.swift
//  IUDI
//
//  Created by LinhMAC on 15/04/2024.
//

import UIKit

class AddGroupViewController: UIViewController, ServerImageHandle {

    @IBOutlet weak var groupNameTF: UITextField!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var addGroupBtn: UIButton!
    
    var hideSubview : (()-> Void)?
    var recallData : (()-> Void)?

    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        groupImageTap()
        // Do any additional setup after loading the view.
    }

    func setupView(){
        addGroupBtn.isEnabled = false
        addGroupBtn.tintColor = .lightGray
        
        groupNameTF.layer.cornerRadius = groupNameTF.frame.height / 2
        groupNameTF.layer.borderWidth = 1
        groupNameTF.layer.borderColor = UIColor.black.cgColor
        groupNameTF.clipsToBounds = true
        
        cancelBtn.layer.cornerRadius = cancelBtn.frame.height / 2
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.systemBlue.cgColor
        cancelBtn.clipsToBounds = true
        
        addGroupBtn.layer.cornerRadius = addGroupBtn.frame.height / 2
        addGroupBtn.layer.borderWidth = 1
        addGroupBtn.layer.borderColor = UIColor.systemBlue.cgColor
        addGroupBtn.clipsToBounds = true
        
    }
    func groupImageTap(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer: )))
        groupImage.isUserInteractionEnabled = true
        groupImage.addGestureRecognizer(tapGesture)
        print("groupImageTap")
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        print("groupImageTap")

        showAleartSheet()
    }
    
    func creatNewGroup(groupName: String?){
        struct CreatNewGroupRespone: Codable {
            let message: String?
            let status: Int?
        }
        
        guard let userID = UserInfo.shared.getUserID() else {return}
        let subUrl = "forum/group/add_group/\(userID)"
        let avatarLink = convertImageToString(img: groupImage.image!)
        guard let groupName = groupName else {return}
        let param : [String: Any] = [
            "GroupName": groupName,
            "avatarLink": avatarLink,
            "userNumber": 100
        ]
        APIService.share.apiHandle(method: .post, subUrl: subUrl,parameters: param ,data: CreatNewGroupRespone.self) { [weak self] result in
            guard let self = self else{return}
            switch result {
            case .success(let data):
                print("success")
                showAlert(title: "Thông báo", message: "Đã tạo nhóm thành công", completionHandler: { self.hideSubview?() })
                self.recallData?()
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

    @IBAction func textDidChanged(_ sender: UITextField) {
        if sender.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 < 1 {
            addGroupBtn.isEnabled = false
            addGroupBtn.tintColor = .lightGray
        } else {
            addGroupBtn.isEnabled = true
            addGroupBtn.tintColor = .systemBlue

        }
    }
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case cancelBtn :
            hideSubview?()
            print("cancel")
        case addGroupBtn:
            creatNewGroup(groupName: groupNameTF.text)
        default:
            break
        }
    }
}
// Mark: - image picker
extension AddGroupViewController:UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func showAleartSheet() {
        let aleartSheet = UIAlertController(title: "Chọn ảnh nhóm", message: "Chọn ảnh nhóm", preferredStyle: .alert)
        let openCamera = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openCamera()
        }
        let openGallary = UIAlertAction(title: "Thư viện ảnh", style: .default) { (_) in
            self.openGallary()
        }
        let cancel = UIAlertAction(title: "Hủy", style: .cancel)
        aleartSheet.addAction(openCamera)
        aleartSheet.addAction(openGallary)
        aleartSheet.addAction(cancel)
        self.present(aleartSheet, animated: true, completion: nil)

    }
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        } else {
            let alertVC = UIAlertController(title: "Lỗi", message: "Thiết bị không có camera", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Hủy", style: .cancel)
            alertVC.addAction(cancel)
            self.present(alertVC, animated: true)
        }
    }
    func openGallary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        } else {
            let alertVC = UIAlertController(title: "Lỗi", message: "Thiết bị không có camera", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Hủy", style: .cancel)
            alertVC.addAction(cancel)
            self.present(alertVC, animated: true)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        groupImage.image = pickedImage
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
