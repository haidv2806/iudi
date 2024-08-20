//
//  MessageViewController.swift
//  IUDI
//
//  Created by LinhMAC on 20/03/2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import UniformTypeIdentifiers
import SwiftyJSON

class MessageViewController: MessagesViewController,MessagesLayoutDelegate, UIDocumentPickerDelegate, MessagesDisplayDelegate {
    var userID = UserInfo.shared.getUserID()
    var currentUser = Sender(senderId: UserInfo.shared.getUserID() ?? "", displayName: "")
    
    var messages = [MessageType]()
    var imagePicker = UIImagePickerController()
    var chatHistory = [SingleChat]()
    
    var messageUserData : MessageUserData?
    var userAvatar = UIImageView()
    var userFullName: String?

    var isSeen : String = ""
    var moreDate = 0
    var isMaxData = false
    private var refeshControl = UIRefreshControl()
    var backIntroductVC = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserProfile()
        sendUserId()
        SocketIOManager.sharedInstance.establishConnection()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.showsVerticalScrollIndicator = false
        messagesCollectionView.delegate = self

        messageInputBar.delegate = self
        addCameraBarButton()
        getAllChatData()
        subviewHandle()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        pullToRefesh()
        self.messagesCollectionView.scrollToLastItem(animated: true)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        SocketIOManager.shared.establishConnection()
        SocketIOManager.shared.mSocket.on("connect") {data, ack in
            self.sendUserId() // Gọi hàm sendUserId() khi kết nối thành công
        }
        reloadNewMessage()
        listentSeenMessageEvent()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocketIOManager.shared.mSocket.off("seen")
        SocketIOManager.shared.mSocket.off("check_message")

        if isMovingFromParent || isBeingDismissed || isMovingToParent {
            // Kiểm tra nếu view controller sẽ bị loại bỏ khỏi cấu trúc view controller cha
            // hoặc sẽ được hiển thị root view controller
            
            SocketIOManager.shared.mSocket.off("seen")
        }
    }

    @objc func getAllChatData(){
        guard let userID = UserInfo.shared.getUserID() else {
            print("userID Nil")
            return
        }
        guard let otherUserID = messageUserData?.otherUserId else {
            print("otherUserID")
            return
        }
        showLoading(isShow: true)
        let apiService = APIService.share
        let subUrl = "pairmessage/\(userID)?other_userId=\(otherUserID)"
        print("url:\(subUrl)")
        apiService.apiHandleGetRequest(subUrl: subUrl,data: AllSingleChatData.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                print("data.data.count: \(data.data.count)")
                
                let chatData = data.data
                print("chatData: \(chatData.first?.otherUsername ?? "")")

                self.chatHistory = chatData
                self.seenMessage(MessageID: chatData.first?.messageID ?? 0)
                self.loadChatHistory(data: chatData)
                self.showLoading(isShow: false)
                DispatchQueue.main.async {
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }            case .failure(let error):
                print("error: \(error.localizedDescription)")
                self.showLoading(isShow: false)
                switch error{
                case .server(let message):
                    self.showAlert(title: "lỗi", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi", message: message)
                }
            }
        }
    }
    func loadChatHistory(data: [SingleChat]){
        // xử lí data nhận được từ server, đảo thứ tự tin nhắn
        guard !self.isMaxData else {
//                    showLoading(isShow: false)
            return}
        var maxEndIndex = (10 + self.moreDate)
        if maxEndIndex >= data.count {
            print("hết data")
            maxEndIndex = (data.count)
            self.isMaxData = true
            messagesCollectionView.bounces = false
            print("cập nhật isMaxData :\(isMaxData)")

        }
        let endIndex = min(maxEndIndex, data.count) // Lấy tối đa 10 phần tử
        let startIndex = min((0 + self.moreDate), data.count) // Bắt đầu từ phần tử thứ 5
        let newData = Array(data.suffix(from: startIndex).prefix(endIndex-startIndex))
        
        for data in newData {
            // khử optional
            let displayName1 = data.otherUsername
            guard let messageText = data.content,
            let senderId = data.senderID,
            let messageId = data.messageID,
                  let messageDate = data.messageTime else {return}
            var displayName : String = ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz" // Specify the format of the string date
            let sentDate = dateFormatter.date(from: messageDate) ?? Date()
            // kiểm tra xem có tin nhắn hình ảnh không
            
            if "\(senderId)" == userID {
                displayName = data.username ?? ""
            } else {
                displayName = data.otherUsername ?? ""
            }
            if let messageImage = data.image {
                let image = self.convertBase64StringToImage(imageBase64String: messageImage)
                let mediaItem = ImageMediaItem(image: image)
                let newMessage = Message(sender: Sender(senderId: "\(senderId)", displayName: displayName),
                                         messageId: "\(senderId)",
                                         sentDate: sentDate,
                                         kind: .photo(mediaItem))
                self.messages.insert(newMessage, at: 0)

//                self.messages.append(newMessage)
            } else {
                let newMessage = Message(sender: Sender(senderId: "\(senderId)", displayName: displayName),
                                         messageId: "\(messageId)",
                                         sentDate: sentDate,
                                         kind: .text(messageText))
                self.messages.insert(newMessage, at: 0)
//                self.messages.append(newMessage)
            }
        }
        // reload data sau khi kết thúc vòng lặp
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.moreDate += 10
//            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
}
// MARK: - xử lí seenMessage
extension MessageViewController {
    func seenMessage(MessageID: Int){
//        if SocketIOManager.shared.mSocket.status == .connected {
            let messageData: [String: Any] = [
                "MessageID": MessageID
            ]
            SocketIOManager.shared.mSocket.emit("seen", messageData)
            print("gửi seen lên server")
//        }
    }
    func listentSeenMessageEvent(){
        SocketIOManager.shared.mSocket.on("seen") { data, ack in
            guard let messageDatas = data[0] as? [String: Any] else { return }
            guard let messageData = messageDatas["data"] as? [String: Any] else {return}
            let senderID = messageData["SenderID"] as? Int ?? 0
            let otherUserID = "\(senderID)"
            print("otherUserID: \(otherUserID) ")
            // Trong closure của listentSeenMessageEvent
            guard otherUserID == self.userID else {
                print("không phải người dùng này ")
                DispatchQueue.main.async {
                    self.isSeen = ""
                    let lastSection = self.messagesCollectionView.numberOfSections - 1
                    if lastSection >= 0 {
                        self.messagesCollectionView.reloadSections(IndexSet(integer: lastSection))
                    }
                }
                return
            }
            print("người dùng seen tin nhắn")
            DispatchQueue.main.async {
                self.isSeen = "đã xem"
                let lastSection = self.messagesCollectionView.numberOfSections - 1
                if lastSection >= 0 {
                    self.messagesCollectionView.reloadSections(IndexSet(integer: lastSection))
                }
            }
        }
    }

}

// MARK: - xử lí subview
extension MessageViewController {
    
    func subviewHandle(){
        var safeAreaHeight : CGFloat
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                safeAreaHeight = window.safeAreaInsets.top// + window.safeAreaInsets.bottom
                print("Chiều cao của safe area: \(safeAreaHeight)")
            } else {
                safeAreaHeight = 60
                print("Không thể lấy được window")
            }
        } else {
            safeAreaHeight = 60
            
            print("Không thể lấy được window scene")
        }
        
        let userSubview = UIView()
        view.addSubview(userSubview)
        userSubview.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50 + safeAreaHeight)
        messagesCollectionView.contentInset.top = userSubview.frame.height
        
        let childVC = ConverseViewController()
        addChild(childVC)
//        childVC.messageUserData = messageUserData
        childVC.bindData(data: messageUserData)
        childVC.didSelectBtn = { [weak self] in
            guard let self = self else {return}
            if self.backIntroductVC {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.goToIntroductVC()

            }
        }
//        childVC.otherUserName = chatHistory.first?.otherUsername
        userSubview.addSubview(childVC.view)
        childVC.view.frame = userSubview.bounds
        childVC.didMove(toParent: self)
    }
    func goToIntroductVC(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "UserIntroduceViewController") as! UserIntroduceViewController
        vc.otherUserName = chatHistory.first?.otherUsername
        vc.otherUserID = chatHistory.first?.otherUserID
        vc.navigationFromChatVC = true
        navigationController?.pushViewController(vc, animated: true)
    }

}
// MARK: - download UserProfile
extension MessageViewController: ServerImageHandle {
    func getUserProfile(){
        let userInfo = UserInfoCoreData.shared.fetchProfileFromCoreData()
        self.userAvatar.image = convertStringToImage(imageString: userInfo?.userAvatarUrl ?? "")
        self.userFullName = userInfo?.userFullName
        self.currentUser = Sender(senderId: UserInfo.shared.getUserID() ?? "", displayName: self.userFullName ?? "KGsdgha")
    }
    
}

// MARK: - testing
extension MessageViewController {
    @objc func sendUserId(){
        guard let sendID = Int(userID ?? "0") else {
            print("---userNil---")
            return
        }
        if SocketIOManager.shared.mSocket.status == .connected {
            print("Socket is connected")
            let messageData: [String: Int] = [
                "userId": sendID
            ]
            SocketIOManager.shared.mSocket.emit("userId", messageData)
        } else {
            print("Socket is not connected")
        }
    }
    func reloadNewMessage(){
        // lắng nghe event check_message
        SocketIOManager.shared.mSocket.on("check_message") { data, ack in
            print("co tin nhan moi reloadNewMessage")
            guard let messageDatas = data[0] as? [String: Any] else { return }
            guard let messageData = messageDatas["data"] as? [String: Any] else {return}

            guard let displayName = self.messageUserData?.otherUserFullName else {
                print("===displaynamenil===")
                return
            }
            let senderId = messageData["SenderID"] as? Int ?? 0
            let otherUserID = "\(senderId)"
            print("otherUserID:\(otherUserID)")
            print("self.messageUserData?.otherUserId:\(self.messageUserData?.otherUserId)")
            let messageText = messageData["Content"] as? String ?? ""
            let messageID = messageData["MessageID"] as? Int ?? 0
            print("messageText:\(messageText)")
            print("messageID:\(messageID)")


            guard otherUserID == self.messageUserData?.otherUserId else {return}

            self.seenMessage(MessageID: messageID)
            // kiểm tra xem id người dguiwr có trùng với id người hiện tại đang nhắn tin không, nếu không return
            // kiểm tra nếu tin nhắn có chứa image
            if let messageImage = messageData["Image"] as? String {
                let image = self.convertBase64StringToImage(imageBase64String: messageImage)
                let mediaItem = ImageMediaItem(image: image)
                let newMessage = Message(sender: Sender(senderId: otherUserID, displayName: displayName),
                                         messageId: otherUserID,
                                         sentDate: Date(),
                                         kind: .photo(mediaItem))
                self.messages.append(newMessage)
            } else {
                let newMessage = Message(sender: Sender(senderId: otherUserID, displayName: displayName),
                                         messageId: otherUserID,
                                         sentDate: Date(),
                                         kind: .text(messageText))
                self.messages.append(newMessage)

            }
            // reloadData sau khi load xong dữ liệu
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }

}

// MARK: - Xử lí khi tin nhắn text
extension MessageViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        self.isSeen = ""

        // Tạo một tin nhắn mới từ người dùng hiện tại và văn bản đã nhập
        guard let idReceive = messageUserData?.otherUserId else {
            print("---userNil---")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        
        // Lấy thời gian hiện tại
        let currentTime = Date()
        // Định dạng thời gian hiện tại thành chuỗi
        let MessageTime = dateFormatter.string(from: currentTime)
        if SocketIOManager.shared.mSocket.status == .connected {
            let messageData: [String: Any] = [
                "content": text,
                "idReceive": idReceive,
                "idSend": userID ?? ""
            ]
            SocketIOManager.shared.mSocket.emit("send_message", messageData)
            let newMessage = Message(sender: currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
            print("newMessage:\(newMessage)")
            // Thêm tin nhắn mới vào mảng messages và reload dữ liệu hiển thị
            messages.append(newMessage)
            messagesCollectionView.reloadData()
            // Xóa văn bản đã nhập từ thanh nhập liệu
            inputBar.inputTextView.text = ""
            // Cuộn xuống cuối danh sách tin nhắn để hiển thị tin nhắn mới nhất
            messagesCollectionView.scrollToLastItem(animated: true)
        } else {
            print("Socket is not connected")
            showAlert(title: "Socket is not connected", message: "Socket is not connected")
        }
    }
    
}
// MARK: - Xử lí khi chọn ảnh và tệp
extension MessageViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
        
    // convertImageToBase64String
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.1)?.base64EncodedString() ?? ""
    }
    // convertImageToBase64String
    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.isSeen = ""

        if let image = info[.originalImage] as? UIImage {
            let mediaItem = ImageMediaItem(image: image)
            let imageBase64 = convertImageToBase64String(img: image)
            print("---imageBase64--- :\(imageBase64)")
                guard let otherUserId = self.messageUserData?.otherUserId else {
                    print("---userNil---")
                    return
                }
                if SocketIOManager.shared.mSocket.status == .connected {
                    let messageData: [String: Any] = [
                        "idSend": userID ?? "",
                        "idReceive": otherUserId,
                        "content": "",
                        "Image": imageBase64
                    ]
                    SocketIOManager.shared.mSocket.emit("send_message", messageData)
                    let newMessage = Message(sender: self.currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .photo(mediaItem))
                    self.messages.append(newMessage)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                } else {
                    print("Socket is not connected")
                }
            }
            
            dismiss(animated: true, completion: nil)
        }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if (urls.first?.lastPathComponent) != nil {
            for url in urls {
                let newMessage = Message(sender: currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .custom(url.self))
                messages.append(newMessage)
            }
            // Reload the collection view to display the new messages
            messagesCollectionView.reloadData()
            // Dismiss the document picker
            dismiss(animated: true, completion: nil)
        }
    }
}
// MARK: - thêm icon vào right bar
extension MessageViewController {
    
    func addBarItem(size: CGSize, image: String, action: Selector) -> InputBarButtonItem{
        let item = InputBarButtonItem(type: .system)
        item.image = UIImage(systemName: image)
        item.tintColor = Constant.mainBorderColor
        item.addTarget(
            self,
            action: action,
            for: .primaryActionTriggered)
        item.setSize(size, animated: false)
        return item
    }
    
    private func addCameraBarButton() {
        let itemSize = CGSize(width: 24, height: 24)
        let itemSpacing: CGFloat = 15 // Khoảng cách giữa các mục
        let itemNumber :CGFloat = 3
        
        let photoLibrary = addBarItem(size: itemSize, image: "photo", action: #selector(photoButtonPressed))
        let camera = addBarItem(size: itemSize, image: "camera", action: #selector(openCamera))
        let paperclip = addBarItem(size: itemSize, image: "paperclip", action: #selector(sendFile))
        let micro = addBarItem(size: itemSize, image: "mic.fill", action: #selector(getAllChatData))
        
        messageInputBar.sendButton.image = UIImage(named: "sendmsgicon")
        messageInputBar.sendButton.setSize(itemSize, animated: true)
        messageInputBar.sendButton.title = nil
        
        messageInputBar.rightStackView.alignment = .center
        messageInputBar.rightStackView.spacing = itemSpacing // Đặt khoảng cách giữa các mục
        let messageInputBarSize = (itemSize.width * itemNumber) + (itemSpacing * (itemNumber - 1)) // Tính kích thước của thanh input bar
//        messageInputBar.heightAnchor.constraint(equalToConstant: 80).isActive = true
        messageInputBar.setRightStackViewWidthConstant(to: messageInputBarSize, animated: false)
        messageInputBar.setStackViewItems([messageInputBar.sendButton, photoLibrary, camera], forStack: .right, animated: false)
    }
    @objc private func photoButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc fileprivate func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            /// Cho phép edit ảnh hay là không
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let errorText = NSLocalizedString("Error", comment: "")
            let errorMessage = NSLocalizedString("Divice not have camera", comment: "")
            
            let alertWarning = UIAlertController(title: errorText,
                                                 message: errorMessage,
                                                 preferredStyle: .alert)
            let cancelText = NSLocalizedString("Cancel", comment: "")
            let cancel = UIAlertAction(title: cancelText,
                                       style: .cancel) { (_) in
                print("Cancel")
            }
            alertWarning.addAction(cancel)
            self.present(alertWarning, animated: true, completion: nil)
        }
    }
    
    @objc private func sendFile() {
        if #available(iOS 14.0, *) {
            let contentTypes: [UTType] = [
                .init(filenameExtension: "doc")!,
                .init(filenameExtension: "docx")!,
                .pdf,
                .presentation,
                .spreadsheet,
                .plainText,
                .text
            ]
            let documentPicker: UIDocumentPickerViewController
            
                documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
//            } else {
//                documentPicker = UIDocumentPickerViewController(documentTypes: contentTypes.map({$0.identifier}), in: .import)
//            }
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            present(documentPicker, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
        
    }
}

// MARK: - Cấu hình UI của MessageViewController
extension MessageViewController: MessagesDataSource {
    func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemBlue : .lightGray
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = self.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }
    
    func getAvatarFor(sender: SenderType) -> Avatar {
        let firstName = sender.displayName.components(separatedBy: " ").first?.uppercased()
        let lastName = sender.displayName.components(separatedBy: " ").last?.uppercased()
        let initials = "\(firstName?.first ?? " ")\(lastName?.first ?? " ")"
        
        if userID == sender.senderId{
            return Avatar(image:userAvatar.image, initials: initials)
        }else{
            return Avatar(image:messageUserData?.otherUserAvatar, initials: initials)
        }
    }
    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        switch message.kind {
        case .photo(let media):
            if let imageURL = media.url {
                imageView.kf.setImage(with: imageURL)
            }else{
                imageView.kf.cancelDownloadTask()
            }
        default:
            break
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        //let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .topRight : .bottomRight
        return .bubble
//                return .bubbleTail(corner, .curved)
    }
}

// MARK: - Cấu hình UI của MessageViewController
extension MessageViewController: DateConvertFormat {
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Format thời gian gửi của tin nhắn
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz" // Định dạng 24 giờ
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Đặt múi giờ của định dạng là GMT

        let sentDate1 = dateFormatter.string(from: message.sentDate)
        let sentDate = convertServerTimeStringVN(sentDate1)
        // Tạo văn bản được định dạng cho thời gian gửi
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray // Màu xám
        ]
        return NSAttributedString(string: sentDate, attributes: attributes)
    }

        func cellBottomLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm" // Định dạng 24 giờ
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Đặt múi giờ của định dạng là GMT

            let sentDate = dateFormatter.string(from: message.sentDate)
            // Tạo văn bản được định dạng cho thời gian gửi
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray // Màu xám
            ]
            return NSAttributedString(string: sentDate, attributes: attributes)
        }
        func messageTopLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
    //
//    func messageBottomLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let name = message.sender.displayName
//        return NSAttributedString(string: name,attributes: [NSAttributedString.Key.font: UIFont(name: "Roboto-Regular",
//                                                                                                size: 10) ?? UIFont.preferredFont(forTextStyle: .caption1),
//                                                            NSAttributedString.Key.foregroundColor: UIColor.gray])
//        //        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
//    }

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
        func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            return 10
        }
    //
        func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            return 20
        }
    //
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    
}
extension MessageViewController {
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Kiểm tra xem tin nhắn có phải là tin nhắn cuối cùng không
        if isLastMessage(at: indexPath) {
            let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.gray]
            return NSAttributedString(string: isSeen, attributes: attrs)
        } else {
            return nil
        }
    }

    func isLastMessage(at indexPath: IndexPath) -> Bool {
        // Thực hiện logic kiểm tra xem tin nhắn có phải là tin nhắn cuối cùng không
        return indexPath.section == messages.count - 1
    }
}

extension MessageViewController {
        func pullToRefesh(){
            refeshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
            messagesCollectionView.addSubview(refeshControl)
        }
        @objc func reloadData(send: UIRefreshControl){
            guard !self.isMaxData else {
                print("đã hết data để Refesh")
                self.refeshControl.endRefreshing()
                return}
            print("Refesh isMaxData:\(isMaxData)")
            DispatchQueue.main.async {
                self.loadChatHistory(data: self.chatHistory)
//                self.getAllChatData()
                print("đã scroll hết")
                self.refeshControl.endRefreshing()
            }
        }

}






