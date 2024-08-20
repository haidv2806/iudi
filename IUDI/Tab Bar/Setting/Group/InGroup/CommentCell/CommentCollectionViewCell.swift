//
//  CommentCollectionViewCell.swift
//  IUDI
//
//  Created by LinhMAC on 17/05/2024.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell, ServerImageHandle, DateConvertFormat {
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var commentContent: UILabel!
    @IBOutlet weak var commentPhoto: UIImageView!
    @IBOutlet weak var commentPhotoSize: NSLayoutConstraint!
    @IBOutlet weak var themeView: UIView!
    
    @IBOutlet weak var dateComment: UILabel!
    @IBOutlet weak var likeCommentBtn: UIButton!
    @IBOutlet weak var numbersOfLike: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var avatarBtn: UIButton!
    @IBOutlet weak var userNameBtn: UIButton!
    
    @IBOutlet weak var themeViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageToContent: NSLayoutConstraint!
    
    var likeNumbers = 0
    var isLiked = false
    var gotoUserProfile: (()->Void)?
    var likeComment : (() -> Void)?
    var showSubView : (() -> Void)?
    var hideSubView : (() -> Void)?
    var timer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        longPress.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPress)
        // Initialization code
    }

    @objc func longPressGesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            hideSubView?()
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.showSubView?()
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timer?.invalidate()
            timer = nil
        }
    }

    
    func bindDataComment(data: Comment, favoriteCount: Int){
        if let photoUrl = data.photoURL {
            commentPhoto.image = convertStringToImage(imageString: photoUrl)
            commentPhotoSize.constant = 200
        } else {
            commentPhotoSize.constant = 1
        }
        userAvatar.image = convertStringToImage(imageString: data.avatar)
        userName.text = data.fullName
        commentContent.text = data.content
        
        let commentContentSize = commentContent.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: commentContent.bounds.height))
        let fullNameSize = userName.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: userName.bounds.height))
        
        imageToContent.constant = (data.content.count < 1) ? 5 : 5

        if commentContentSize.width > fullNameSize.width {
            themeViewWidth.constant = commentContentSize.width + 10
        } else {
            themeViewWidth.constant = fullNameSize.width + 10
        }
        self.likeNumbers = data.favoriteCount ?? 0
        
        dateComment.text = convertServerTimeString(data.commentTime)
        self.isLiked = data.isFavorited
        likeHandle()
    }
    
    func likeHandle(){
        numbersOfLike.text = "\(likeNumbers)"
        if isLiked {
            likeCommentBtn.tintColor = UIColor.systemBlue
        } else {
            likeCommentBtn.tintColor = UIColor.darkGray
        }
        if likeNumbers > 0 {
            numbersOfLike.isHidden = false
            likeImage.isHidden  = false
        } else {
            numbersOfLike.isHidden = true
            likeImage.isHidden  = true
        }
    }
    
    func setupView(){
        userAvatar.layer.cornerRadius = userAvatar.bounds.width / 2
        userAvatar.clipsToBounds = true
        commentPhoto.layer.cornerRadius = 10
        commentPhoto.clipsToBounds = true
        themeView.layer.cornerRadius = 10
        themeView.clipsToBounds = true
//        likeImage.layer.cornerRadius = likeImage.bounds.width / 2
//        likeImage.clipsToBounds = true
    }
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case likeCommentBtn:
            if isLiked {
                likeNumbers -= 1
            }else {
                likeNumbers += 1
            }
            isLiked.toggle()
            likeHandle()
            likeComment?()
        case avatarBtn:
            gotoUserProfile?()
            print("gotoUserProfile")
        case userNameBtn:
            gotoUserProfile?()
            print("gotoUserProfile")
        default:
            break
        }
    }
    
    
}
