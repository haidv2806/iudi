//
//  SelectImageViewController.swift
//  IUDI
//
//  Created by LinhMAC on 28/02/2024.
//

import UIKit
import Alamofire
import iOSDropDown
import KeychainSwift
import SwiftyJSON

class SelectImageViewController: UIViewController {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    let keychain = KeychainSwift()
    var userPhotos = [Photo]()
    let itemNumber = 4.0
    let minimumLineSpacing = 5.0
    private var refeshControl = UIRefreshControl()
    var loadImage : ((String, Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionView()
        setupCollectionView()
        pullToRefesh()
    }
    override func viewWillAppear(_ animated: Bool) {
        getAllImage()
    }
    private func setupCollectionView() {
        if let flowLayout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = minimumLineSpacing
            flowLayout.minimumInteritemSpacing = minimumLineSpacing
        }
    }
    func registerCollectionView(){
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        let cell = UINib(nibName: "SelectImageCollectionViewCell", bundle: nil)
        imageCollectionView.register(cell, forCellWithReuseIdentifier: "SelectImageCollectionViewCell")
    }
    //https://api.iudi.xyz/api/profile/viewAllImage/37
    func getAllImage(){
        showLoading(isShow: true)
        guard let userID = keychain.get("userID") else {
            showLoading(isShow: false)
            print("userID rỗng")
            return
        }
        let url = Constant.baseUrl + "profile/viewAllImage/" + userID
        print("\(url)")
        AF.request(url, method: .get)
            .validate(statusCode: 200...299)
            .responseDecodable(of: GetPhotos.self) { response in
                switch response.result {
                    // Xử lý dữ liệu nhận được từ phản hồi (response)
                case .success(let data):
                    if let userdata = data.photos {
                        print("userdata: \(userdata.count)")
                        self.userPhotos = userdata
                        DispatchQueue.main.async {
                            self.imageCollectionView.reloadData()
                            self.showLoading(isShow: false)
                        }
                    } else {
                        print("data nill")
                    }
                case .failure(let error):
                    self.showLoading(isShow: false)
                    print("\(error.localizedDescription)")
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            let errorMessage = json["message"].stringValue
                            print(errorMessage)
                            self.showAlert(title: "Lỗi", message: errorMessage + "1")
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                            self.showAlert(title: "Lỗi", message: "Đã xảy ra lỗi, vui lòng thử lại sau.")
                        }
                    } else {
                        print("Không có dữ liệu từ server")
                        self.showAlert(title: "Lỗi", message: "Đã xảy ra lỗi, vui lòng thử lại sau.")
                    }
                }
            }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
extension SelectImageViewController : UICollectionViewDataSource, UICollectionViewDelegate,CellSizeCaculate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("userPhotos.count: \(userPhotos.count)")
        return userPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectImageCollectionViewCell", for: indexPath) as! SelectImageCollectionViewCell
        // trả về kích thước ảnh quyết định màn hình sẽ load bao nhiêu ảnh theo chiều ngang
        let data = userPhotos[indexPath.item]
        let indexNumber = Double(userPhotos.count)
//        let frameSize = UIScreen.main.bounds.width
        let frameSize = imageCollectionView.frame.width
        let imageSize = caculateSize(indexNumber: indexNumber,
                                     frameSize: frameSize,
                                     defaultNumberItemOneRow: 4,
                                     minimumLineSpacing: minimumLineSpacing)
        cell.blinData(data: data, width: imageSize)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photoID = userPhotos[indexPath.item].photoID, let photoUrl = userPhotos[indexPath.item].photoURL else{
            print("ảnh không có url và ID")
            return
        }
        loadImage?(photoUrl, photoID)
        navigationController?.popViewController(animated: true)
    }
    
}
extension SelectImageViewController: UIScrollViewDelegate {
    func pullToRefesh(){
        refeshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        imageCollectionView.addSubview(refeshControl)
    }
    @objc func reloadData(send: UIRefreshControl){
        DispatchQueue.main.async {
            self.getAllImage()
            print("đã scroll hết")
            self.refeshControl.endRefreshing()
        }
    }
}
