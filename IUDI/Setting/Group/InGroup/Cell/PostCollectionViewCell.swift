//
//  PostCollectionViewCell.swift
//  IUDI
//
//  Created by Quoc on 01/03/2024.
//

import UIKit
import Alamofire

protocol PostCollectionViewCellDelegate: AnyObject {
    func didTapDeleteButton(for postId: Int)
}

class PostCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: PostCollectionViewCellDelegate?
    var didSelectItem: (() -> Void)?
    var deleteCompletion: (() -> Void)?
    
    @IBOutlet weak var postsImage: UIImageView!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var hideSubViewBtn: UIButton!
    
    var postId: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.layer.cornerRadius = avatarView.frame.size.width/2
    }
    
    func setAvatarImage(data: String) {
        //        guard let url = data.avatar else {
        //            return
        //        }
        let imageUrl = URL(string: data)
        avatarView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                
                break
            case .failure(let error):
                // Xảy ra lỗi khi tải ảnh
                self.avatarView.image = UIImage(systemName: "person")
                //                print("Lỗi khi tải ảnh: \(error.localizedDescription)")
            }
        })
    }
    
    func setPostsImage(data: String) {
        //        guard let url = data.avatar else {
        //            return
        //        }
        let imageUrl = URL(string: data)
        postsImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "person"), options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                
                break
            case .failure(let error):
                // Xảy ra lỗi khi tải ảnh
                self.postsImage.image = UIImage(systemName: "person")
                //                print("Lỗi khi tải ảnh: \(error.localizedDescription)")
            }
        })
    }
    
    
    @IBAction func deletePosts(_ sender: Any) {
        guard let postId = postId else {
            return
        }
        delegate?.didTapDeleteButton(for: postId)
    }
}

