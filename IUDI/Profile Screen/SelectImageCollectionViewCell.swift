//
//  SelectImageCollectionViewCell.swift
//  IUDI
//
//  Created by LinhMAC on 28/02/2024.
//

import UIKit
import Kingfisher

class SelectImageCollectionViewCell: UICollectionViewCell, ServerImageHandle {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = 10
    }
    func blinData(data: Photo ,width: CGFloat){
        
        imageWidth.constant = CGFloat(Int(width))
        if let url = data.photoURL{
//            userImage.image = convertStringToImage(imageString: url)
            convertUrlToImage(url: url) { image in
                DispatchQueue.main.async {
                    if let image = image {
                        // Set the image to the UIButton
                        self.userImage.image = image
                    } else {
                        // Handle the case where the image could not be loaded
                        print("Failed to load image.")
                    }
                }
            }
            
        }
//        userImage.image = UIImage(systemName: "person.fill")
    }
    func transData(image: UIImage){
        let image = userImage.image
    }
    @IBAction func btnHandle(_ sender: Any) {
        print("???")
    }
}
