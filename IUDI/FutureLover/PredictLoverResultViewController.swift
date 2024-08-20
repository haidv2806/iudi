//
//  PredictLoverResultViewController.swift
//  IUDI
//
//  Created by LinhMAC on 28/05/2024.
//

import UIKit
import Kingfisher
import Photos

class PredictLoverResultViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var meetTitleLb: UILabel!
    @IBOutlet weak var meetLb: UILabel!
    @IBOutlet weak var meetImage: UIImageView!
    @IBOutlet weak var meetImageBtn: UIButton!
    
    @IBOutlet weak var confessTitle: UILabel!
    @IBOutlet weak var confessLb: UILabel!
    @IBOutlet weak var confessImage: UIImageView!
    @IBOutlet weak var confessImageBtn: UIButton!
    
    @IBOutlet weak var happyDaytitle: UILabel!
    @IBOutlet weak var happyDayLb: UILabel!
    @IBOutlet weak var happyDayImage: UIImageView!
    @IBOutlet weak var happyDayImageBtn: UIButton!
    
    @IBOutlet weak var proposalDayTitle: UILabel!
    @IBOutlet weak var proposalDayLb: UILabel!
    @IBOutlet weak var proposalDayImage: UIImageView!
    @IBOutlet weak var proposalDayImageBtn: UIButton!
    
    @IBOutlet weak var weddingDaytitle: UILabel!
    @IBOutlet weak var weddingDayLb: UILabel!
    @IBOutlet weak var weddingDayImage: UIImageView!
    @IBOutlet weak var weddingDayImageBtn: UIButton!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var downloadBtnConstant: NSLayoutConstraint!
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var fullsizeImage: UIImageView!
    @IBOutlet weak var exitFullSizeImage: UIButton!
    @IBOutlet weak var fullsizeImageScrollView: UIScrollView!
    
    var image : SwapImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetechData(titleLb: meetLb, content: DataTable.meet.rawValue)
        fetechData(titleLb: confessLb, content: DataTable.confess.rawValue)
        fetechData(titleLb: happyDayLb, content: DataTable.happyDay.rawValue)
        fetechData(titleLb: proposalDayLb, content: DataTable.proposal.rawValue)
        fetechData(titleLb: weddingDayLb, content: DataTable.weddingDay.rawValue)
        scrollview.delegate = self
        setupZoomImage()
        fullsizeImageHandle(isHidden: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        applBorderWidth(to: meetLb)
        applBorderHeight(to: meetLb)
        applBorderWidth(to: confessLb)
        applBorderHeight(to: confessLb)
        applBorderWidth(to: happyDayLb)
        applBorderHeight(to: happyDayLb)
        applBorderWidth(to: proposalDayLb)
        applBorderHeight(to: proposalDayLb)
        applBorderWidth(to: weddingDayLb)
        applBorderHeight(to: weddingDayLb)
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender{
        case meetImageBtn:
            fullsizeImage.image = meetImage.image
            fullsizeImageHandle(isHidden: false)
        case confessImageBtn:
            fullsizeImage.image = confessImage.image
            fullsizeImageHandle(isHidden: false)
        case happyDayImageBtn:
            fullsizeImage.image = happyDayImage.image
            fullsizeImageHandle(isHidden: false)
        case proposalDayImageBtn:
            fullsizeImage.image = proposalDayImage.image
            fullsizeImageHandle(isHidden: false)
        case weddingDayImageBtn:
            fullsizeImage.image = weddingDayImage.image
            fullsizeImageHandle(isHidden: false)
        case downloadBtn:
            saveImageToPhotosLibrary(meetImage.image!)
        case exitFullSizeImage:
            fullsizeImageHandle(isHidden: true)
        default:
            break
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        AppDelegate.scene?.goToLogin()
        UserDefaults.standard.hasOnboarded = true
    }
    @objc func hideSubview(){
        print("hideSubview")
        UIView.animate(withDuration: 0.5, animations: {
            self.downloadBtn.alpha = 0
            self.downloadBtn.isEnabled = false
        })
    }
    func fullsizeImageHandle(isHidden: Bool){
        fullsizeImage.isHidden = isHidden
        exitFullSizeImage.isHidden = isHidden
        exitFullSizeImage.backgroundColor = .lightGray
        //            self.exitFullSizeImage.layer.opacity = 0.5
        backBtn.isHidden = !isHidden
        fullsizeImageScrollView.isHidden = isHidden
        downloadBtn.alpha = isHidden ? 0 : 1
        downloadBtn.isEnabled = !isHidden
        fullsizeImageScrollView.zoomScale = 1
    }
    
    func setupView(){
        meetTitleLb.sizeToFit()
        meetLb.sizeToFit()
        downloadImage(uiImage: meetImage, imageUrl: image?.images[0])
        downloadImage(uiImage: confessImage, imageUrl: image?.images[1])
        downloadImage(uiImage: happyDayImage, imageUrl: image?.images[2])
        downloadImage(uiImage: proposalDayImage, imageUrl: image?.images[3])
        downloadImage(uiImage: weddingDayImage, imageUrl: image?.images[4])
        meetImage.layer.cornerRadius = 20
        meetImage.clipsToBounds = true
        confessImage.layer.cornerRadius = 20
        confessImage.clipsToBounds = true
        happyDayImage.layer.cornerRadius = 20
        happyDayImage.clipsToBounds = true
        proposalDayImage.layer.cornerRadius = 20
        proposalDayImage.clipsToBounds = true
        weddingDayImage.layer.cornerRadius = 20
        weddingDayImage.clipsToBounds = true
        nextBtn.layer.cornerRadius = 10
        nextBtn.clipsToBounds = true
        downloadBtn.alpha = 0
        downloadBtn.isEnabled = false
    }
    func applBorderWidth(to label: UILabel) {
        let themeWidth = UIView()
        themeWidth.frame = CGRect(x: -15, y: -5, width: Int(label.bounds.width) + 30, height: Int(label.bounds.height) + 10 )
        label.addSubview(themeWidth)
        themeWidth.backgroundColor = .clear
        themeWidth.layer.borderColor = UIColor.darkGray.cgColor
        themeWidth.layer.borderWidth = 2
        themeWidth.clipsToBounds = true
    }
    func applBorderHeight(to label: UILabel) {
        let themeWidth = UIView()
        themeWidth.frame = CGRect(x: -5, y: -15, width: Int(label.bounds.width) + 10 , height: Int(label.bounds.height) + 30)
        label.addSubview(themeWidth)
        themeWidth.backgroundColor = .clear
        themeWidth.layer.borderColor = UIColor.darkGray.cgColor
        themeWidth.layer.borderWidth = 2
        themeWidth.clipsToBounds = true
    }
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        hideSubview()
    //    }
    
    func downloadImage(uiImage: UIImageView, imageUrl: String?){
        let imageUrl = URL(string: imageUrl ?? "")
        uiImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder_image"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                // Ảnh đã tải thành công
                break
            case .failure(_):
                // Xảy ra lỗi khi tải ảnh
                uiImage.image = UIImage(systemName: "person")
                //                print("Lỗi khi tải ảnh: \(error.localizedDescription)")
            }
        })
    }
    func fetechData(titleLb: UILabel, content: DataTable.RawValue){
        let databaseManager = DatabaseManager.shared
        let stories = databaseManager.fetchDataStory(table: content)
        if let randomStory = stories.randomElement() {
            titleLb.text = randomStory.content
        } else {
            print("No stories found")
        }
    }
    
    //    func saveImageToPhotosLibrary(_ image: UIImage) {
    //        PHPhotoLibrary.requestAuthorization { status in
    //            guard status == .authorized else {
    //                self.showErrorAlert(message: "Photo library access is required to save the image.")
    //                return
    //            }
    //
    //            DispatchQueue.main.async {
    //                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    //            }
    //        }
    //    }
    func saveImageToPhotosLibrary(_ image: UIImage) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .authorized, .limited:
                    DispatchQueue.main.async {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                default:
                    self.showErrorAlert(message: "Vui lòng cấp quyền truy cập để lưu ảnh")
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    self.showErrorAlert(message: "Vui lòng cấp quyền truy cập để lưu ảnh")
                    return
                }
                
                DispatchQueue.main.async {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showErrorAlert(message: error.localizedDescription)
        } else {
            showSuccessAlert(message: "Ảnh đã được lưu vào thư viện")
        }
    }
    
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Thành công", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
extension PredictLoverResultViewController {
    func setupZoomImage(){
        fullsizeImageScrollView.delegate = self
        // Thiết lập thuộc tính zoom của scroll view
        fullsizeImageScrollView.minimumZoomScale = 1.0
        fullsizeImageScrollView.maximumZoomScale = 6.0
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullsizeImage
    }
    func setupFullSizeImage() {
        // Thiết lập thuộc tính contentMode của fullsizeImage
        fullsizeImage.contentMode = .scaleAspectFit
    }
}
