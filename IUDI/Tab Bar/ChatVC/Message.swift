//
//  Message.swift
//  IUDI
//
//  Created by LinhMAC on 20/03/2024.
//

import Foundation
import MessageKit


struct Sender: SenderType {
    var senderId: String

    var displayName: String

}
struct Message: MessageType {
    var sender: MessageKit.SenderType

    var messageId: String

    var sentDate: Date
    var kind: MessageKit.MessageKind

}
public struct ImageMediaItem: MediaItem {
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize

    public init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}

struct MessageUserData {
    var otherUserAvatar: UIImage
    var otherUserFullName: String
    var otherUserId: String
    var otherLastActivityTime: String
}





