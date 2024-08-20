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
        otherUserAvatar.image = convertStringToImage(imageString: data.otherAvatar ?? "")

        otherUserName.text = data.otherFullname
    }
}
