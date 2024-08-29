//
//  CollectionViewCell.swift
//  IUDI
//
//  Created by Quoc on 28/02/2024.
//

import UIKit
import Alamofire

class CollectionViewCell: UICollectionViewCell, ServerImageHandle, DateConvertFormat {
    
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
        collectionView.layer.cornerRadius = 20
        collectionView.isUserInteractionEnabled = true
    }
    override func layoutSubviews() {

    }
    func bindData(data: Datum){
        groupName = data.groupName
        groupName = "\(data.groupID)"

        numberOfMembers.text = "\(data.userNumber ?? 0) Thành viên"
        nameGroup.text = data.groupName ?? ""
//        imageGroup.image = convertStringToImage(imageString: data.avatarLink ?? "")
        convertUrlToImage(url: data.avatarLink ?? "") { image in
            DispatchQueue.main.async {
                if let image = image {
                    // Set the image to the UIButton
                    self.imageGroup.image = image
                } else {
                    // Handle the case where the image could not be loaded
                    print("Failed to load image.")
                }
            }
        }
        time.text = convertDate(date: data.createAt ?? "", inputFormat: "EEE, dd MMM yyyy HH:mm:ss zzz", outputFormat: "yyyy-MM-dd")
//        time.text = data.createAt ?? ""
//        groupIDLabel.text = "\(data.groupID ?? 0)"
        imageGroup.layer.cornerRadius = imageGroup.frame.size.width / 2
        imageGroup.clipsToBounds = true
    }
}
