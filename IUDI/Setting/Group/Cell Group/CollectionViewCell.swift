//
//  CollectionViewCell.swift
//  IUDI
//
//  Created by Quoc on 28/02/2024.
//

import UIKit
import Alamofire

class CollectionViewCell: UICollectionViewCell {
    
    var didSelectItem: (() -> Void)?
    var groupName: String?
    
    @IBOutlet weak var numberOfMembers: UILabel!
    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var imageGroup: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var collectionView: UIView!
    @IBOutlet weak var groupIDLabel: UILabel!
    var groupData: GroupData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageGroup.layer.cornerRadius = imageGroup.frame.size.width / 2
        collectionView.layer.cornerRadius = 20
        collectionView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGesture)
        
    }
    func setImage(fromURL url: String) {
        AF.download(url).responseData { response in
            switch response.result {
            case .success(let imageData):
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.imageGroup.image = image
                    }
                }
            case .failure(let error):
                print("Error downloading image: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func cellTapped() {
        // Gọi closure để xử lý việc push sang màn hình đích
        didSelectItem?()
    }
    //    func getGroupDatas(){
    //        let url = "https://api.iudi.xyz/api/forum/group/all_group"
    //        AF.request(url, method: .get).validate(statusCode: 200...299).responseDecodable(of: GroupData.self) { datas in
    //            switch datas.result {
    //            case .success(let data):
    //                self.groupData = data
    //            case .failure(let error):
    //                print("error: \(error.localizedDescription)")
    //            }
    //        }
    //
    //    }
    
    
    
}
