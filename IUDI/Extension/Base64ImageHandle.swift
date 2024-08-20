//
//  base64Image.swift
//  IUDI
//
//  Created by LinhMAC on 08/04/2024.
//

import Foundation
import UIKit

protocol ServerImageHandle {
    func convertImageToString (img: UIImage) -> String
    func convertStringToImage (imageString:String) -> UIImage
}
extension ServerImageHandle {
    
    func convertImageToString (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
    }
    // convertImageToBase64String
    func convertStringToImage (imageString:String) -> UIImage {
        if let imageData = Data(base64Encoded: imageString) {
//            print("convertStringToImage ok")
            if let image = UIImage(data: imageData) {
                return image
            } else {
//                print("lỗi string không đúng định dạng base64")
                return UIImage(systemName: "person.fill")!
            }
        } else {
//            print("lỗi imageString rỗng")
            return UIImage(systemName: "person.fill")!
        }
    }
    //        let imageUrl = URL(string: data.avatarLink ?? "")
    //        userImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder_image"), options: nil, completionHandler: { result in
    //            switch result {
    //            case .success(_):
    //                // Ảnh đã tải thành công
    //                break
    //            case .failure(_):
    //                // Xảy ra lỗi khi tải ảnh
    //                self.userImage.image = UIImage(systemName: "person")
    ////                print("Lỗi khi tải ảnh: \(error.localizedDescription)")
    //            }
    //        })
}
