//
//  DownloadImage.swift
//  IUDI
//
//  Created by LinhMAC on 01/04/2024.
//

import Foundation
import UIKit
import Kingfisher

protocol DownLoadImage: AnyObject {
    func setAvatarImage(uiImage: UIImageView, url: String)
}
extension DownLoadImage {
    
    func setAvatarImage(uiImage: UIImageView, url: String,completion: @escaping (UIImage)-> Void) {
        let imageUrl = URL(string: url)
        uiImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                if let image = uiImage.image {
                    completion(image)
                    print(image)
                }
            case .failure(let error):
                // Xảy ra lỗi khi tải ảnh
                uiImage.image = UIImage(systemName: "person")
            }
        })
    }
}
