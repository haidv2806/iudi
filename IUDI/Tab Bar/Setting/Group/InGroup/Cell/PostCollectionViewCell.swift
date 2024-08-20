//
//  PostCollectionViewCell.swift
//  IUDI
//
//  Created by Quoc on 01/03/2024.
//

import UIKit
import Alamofire

class PostCollectionViewCell: UICollectionViewCell, ServerImageHandle, DateConvertFormat {
    
    @IBOutlet weak var postsImage: UIImageView!
    @IBOutlet weak var postImageSize: NSLayoutConstraint!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var deletePostBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var avatarBtn: UIButton!
    
    var postId: Int?
    var userPostId: String?
    var userID = UserInfo.shared.getUserID()
    var deletePost : (()->Void)?
    var likePost : (()->Void)?
    var commentPost : (()->Void)?
    var isLiked = false
    var avatarTapped : (()->Void)?


    override func awakeFromNib() {
        super.awakeFromNib()
//        applBorder(to: commentBtn)
    }
    
    override func layoutSubviews() {
        avatarView.layer.cornerRadius = avatarView.frame.size.width/2
//        bottomView.layer.borderWidth = 0.5
//        bottomView.layer.borderColor = UIColor.darkGray.cgColor
//        bottomView.layer.cornerRadius = 10
//        bottomView.clipsToBounds = true
    }
    
    private func applBorder(to button: UIView){
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: button.bounds.minX, y: 0, width: 0.5, height: button.bounds.height)
        bottomBorder.backgroundColor = UIColor.darkGray.cgColor
        button.layer.addSublayer(bottomBorder)
    }
    
    func blindata(data: ListPost){
        if data.photo?.count ?? 0 < 10 {
            postsImage.isHidden = true
            postImageSize.constant = 0
        } else {
            postsImage.isHidden = false
            postImageSize.constant = 315
        }
        postsLabel.text = data.content
        nameLabel.text = data.userFullName
        timeLabel.text = convertServerTimeString(data.postTime)
        
        avatarView.image = convertStringToImage(imageString: data.avatar ?? "")
        postsImage.image = convertStringToImage(imageString: data.photo ?? "")
        self.postId = data.postID
        self.userPostId = "\(data.userID ?? 0)"
        if userID == "\(data.userID ?? 0)" {
            deletePostBtn.isHidden = false
        } else {
            deletePostBtn.isHidden = true
        }
        self.isLiked = data.isFavorited ?? false
        likeBtnHandle()
    }
    
    
    func likeBtnHandle(){
//        likeBtn.isSelected = isLiked
        let image = isLiked ? UIImage(systemName: "hand.thumbsup.fill") : UIImage(systemName: "hand.thumbsup")
        let color = isLiked ? UIColor.systemBlue : UIColor.darkGray
        let title = isLiked ? "đã thích" : "thích"
        likeBtn.setImage(image, for: .normal)
        likeBtn.setTitle(title, for: .normal)
        likeBtn.tintColor = color
        print("likeBtn")
    }
    func likeBtnHandle1(){
        isLiked.toggle()

//        likeBtn.isSelected = isLiked
        let image = isLiked ? UIImage(systemName: "hand.thumbsup.fill") : UIImage(systemName: "hand.thumbsup")
        let color = isLiked ? UIColor.systemBlue : UIColor.darkGray
        let title = isLiked ? "đã thích" : "thích"
        likeBtn.setImage(image, for: .normal)
        likeBtn.setTitle(title, for: .normal)
        likeBtn.tintColor = color
        print("likeBtn1")
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case deletePostBtn:
//            likeBtnHandle1()
            deletePost?()
        case likeBtn:
//            print("Like")
//            isLiked.toggle()
//            likeBtnHandle()
            likePost?()
        case commentBtn:
            commentPost?()
            print("commentBtn")
        case avatarBtn:
            avatarTapped?()
        default:
            break
        }
    }
}

