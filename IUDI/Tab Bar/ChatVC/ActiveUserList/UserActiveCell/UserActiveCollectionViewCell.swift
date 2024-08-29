//
//  UserActiveCollectionViewCell.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//

import UIKit

class UserActiveCollectionViewCell: UICollectionViewCell,ServerImageHandle {
    @IBOutlet weak var otherUserAvatar: UIImageView!
    @IBOutlet weak var otherUserName: UILabel!
    @IBOutlet weak var otherUserStatus: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        otherUserStatus.layer.cornerRadius = otherUserStatus.frame.width / 2
        otherUserStatus.isHidden = false
        otherUserAvatar.layer.cornerRadius = otherUserAvatar.frame.width / 2
    }
    func bindData(data: ChatData){
//        otherUserAvatar.image = convertStringToImage(imageString: data.otherAvatar ?? "")
        
        convertUrlToImage(url: data.otherAvatar ?? "") { image in
            DispatchQueue.main.async {
                if let image = image {
                    // Set the image to the UIButton
                    self.otherUserAvatar.image = image
                } else {
                    // Handle the case where the image could not be loaded
                    print("Failed to load image.")
                }
            }
        }

        otherUserName.text = data.otherFullname
    }
}
