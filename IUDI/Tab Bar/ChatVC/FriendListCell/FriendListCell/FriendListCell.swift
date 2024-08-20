//
//  FriendListCell.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//

import UIKit

class FriendListCell: UICollectionViewCell,DateConvertFormat,ServerImageHandle {
    @IBOutlet weak var otherUserAvatar: UIImageView!
    @IBOutlet weak var otherUserName: UILabel!
    @IBOutlet weak var latestMessageDate: UILabel!
    @IBOutlet weak var latestMessageContent: UILabel!
    @IBOutlet weak var messageStatus: UIImageView!
    @IBOutlet weak var isRead: UIImageView!
    @IBOutlet weak var notSeenMessageNumber: UILabel!
    let userID = UserInfo.shared.getUserID()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        otherUserAvatar.layer.cornerRadius = otherUserAvatar.frame.height / 2
    }
    func bindData(data: ChatData){
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        let localTimeString = dateFormatter.string(from: currentTime)
        print("Local Time: \(localTimeString)")
        otherUserAvatar.image = convertStringToImage(imageString: data.otherAvatar ?? "")
        otherUserName.text = data.otherFullname
        latestMessageDate.text = convertServerTimeString(data.messageTime)
//        latestMessageDate.text = data.messageTime
        latestMessageContent.text = data.content
        let senderId = "\(data.senderID ?? 0)"
        if userID == senderId {
            messageStatus.image = UIImage(named: "sendmessage")
//            print("người gửi chính là chính mình")
            seenTextHandle(isSeen: 1)
        } else {
//            print("kiểm tra đã seen tin nhắn chưa")
            seenTextHandle(isSeen: data.isSeen ?? 0)
            messageStatus.image = UIImage(named: "receiveMessage")
        }

    }
    func seenTextHandle(isSeen: Int){
        otherUserName.textColor = (isSeen == 0) ? .black : .gray
        latestMessageDate.textColor = (isSeen == 0) ? .black : .gray
        latestMessageContent.textColor = (isSeen == 0) ? .black : .gray
        isRead.isHidden = (isSeen == 0) ? true : false
        notSeenMessageNumber.isHidden = (isSeen == 0) ? true : true
    }
}
