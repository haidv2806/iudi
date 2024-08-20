//
//  InGroupSubViewController.swift
//  IUDI
//
//  Created by LinhMAC on 17/05/2024.
//

import UIKit

enum ViewHeight: CGFloat {
    case notcomment = 65
    case textComment = 90
    case imageComment = 200
}

class CommentsViewController: UIViewController, ServerImageHandle, UITextViewDelegate {
    
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var postNumberOfLikes: UILabel!
    @IBOutlet weak var commentCollectionView: UICollectionView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var imagePickBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var commentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageComment: UIImageView!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var subViewLocation: NSLayoutConstraint!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var placeholderLabel: UILabel!
    var isLiked = false
    var postID : Int?
    var commentData = [Comment]()
    var imagePicker = UIImagePickerController()
    var favoriteCount : Int?
    var didPickImage = false
    var likeComment : (() -> Void)?
    var commentID: Int?
    var commentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addSwipeGesture()
        registerCell()
        getCommentData()
        setupScrollView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        commentCollectionView.addGestureRecognizer(tapGesture)
        commentTextView.delegate = self
        // Do any additional setup after loading the view.
    }
    @objc func dismissKeyboard() {
        showInputBar(isHidden: true)
        commentViewHandle(type: ViewHeight.notcomment)
        subviewHandle(willShow: false)
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let superview = scrollView.superview {
            let superviewHeight = superview.bounds.height
            let safeAreaInsets = superview.safeAreaInsets
            let heightWithoutSafeArea = superviewHeight - safeAreaInsets.top - safeAreaInsets.bottom
            //            let heightWithoutSafeArea = superviewHeight - safeAreaInsets.top
            viewHeight.constant = heightWithoutSafeArea
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        commentViewHandle(type: ViewHeight.notcomment)
        likeBtnHandle()
        
    }
    func addSwipeGesture(){
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePan.edges = .left
        self.view.addGestureRecognizer(edgePan)
    }
    
    @objc func handleSwipeDown() {
        print("người dùng vuốt xuống ")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            print("người dùng vuốt trái ")
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    func setupView(){
        commentTextView.layer.cornerRadius = 5
        commentTextView.clipsToBounds = true
        placeholderLabel = UILabel()
        placeholderLabel.text = "Nhập nội dung..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 14) // Font của placeholder
        placeholderLabel.textColor = UIColor.white
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 15, y: (commentTextView.font?.pointSize ?? 16) / 2) // Vị trí của placeholder
        //Thêm label placeholder vào UITextView
        commentTextView.addSubview(placeholderLabel)
        
        // Ẩn hiện placeholder tùy thuộc vào nội dung của UITextView
        placeholderLabel.isHidden = !commentTextView.text.isEmpty
        showInputBar(isHidden: true)
        imageComment.layer.cornerRadius = 10
        imageComment.clipsToBounds = true
        removeBtn.isHidden = true
        likeImage.layer.cornerRadius = likeImage.bounds.width / 2
        likeImage.clipsToBounds = true
        subViewLocation.constant = 0
    }
    
    func showInputBar(isHidden : Bool){
        imagePickBtn.isHidden = isHidden
        sendBtn.isHidden = isHidden
        imageComment.isHidden = isHidden
    }
    func commentViewHandle(type: ViewHeight){
        commentViewHeight.constant = type.rawValue
        self.commentView.setNeedsLayout()
        self.commentView.layoutIfNeeded()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func likeBtnHandle(){
        print("likeBtnHandle\(isLiked)")
        likeBtn.isSelected = isLiked
        let image = isLiked ? UIImage(systemName: "hand.thumbsup.fill") : UIImage(systemName: "hand.thumbsup")
        let color = isLiked ? UIColor.systemBlue : UIColor.darkGray
        let title = isLiked ? "đã thích" : "thích"
        likeBtn.setImage(image, for: .normal)
        likeBtn.setTitle(title, for: .normal)
        likeBtn.tintColor = color
        postNumberOfLikes.text = "\(favoriteCount ?? 0)"
    }
    
    func likePost(){
        //"https://api.iudi.xyz/forum/favorite/<userID>/<postID>"
        guard let userID = UserInfo.shared.getUserID(), let postID = postID else {
            return
        }
        let subUrl = "forum/favorite/\(userID)/\(postID)"
        APIService.share.apiHandle(method: .post ,subUrl: subUrl, data: PostData.self) { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            switch result {
            case .success(let data):
                print("success")
            case .failure(let error):
                print(error.localizedDescription)
                switch error {
                case .server(let message):
                    self.showAlert(title: "lỗi server", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi mạng", message: message)
                }
            }
        }
    }
    
    func sendComment(){
        guard let userID = UserInfo.shared.getUserID(), let postID = postID, let comment = commentTextView.text else {
            print("thiếu thông tin")
            return}
        let subUrl = "forum/add_comment/\(userID)/\(postID)"
        var parameters : [String: Any]
        if let imageUrl =  imageComment.image {
            parameters = [
                "Content":comment,
                "PhotoURL": [convertImageToString(img: imageUrl)]
            ]
            print(" có ảnh")
        } else {
            parameters = [
                "Content" : comment
            ]
            print("không có ảnh")
        }
        
        APIService.share.apiHandle(method: .post ,subUrl: subUrl, parameters: parameters ,data: PostData.self) { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            switch result {
            case .success(let data):
                print("success")
                getCommentData()
                imageComment.image = nil
                commentTextView.text = ""
                commentTextView.resignFirstResponder()
                dismissKeyboard()
                commentViewHandle(type: ViewHeight.notcomment)
            case .failure(let error):
                print(error.localizedDescription)
                switch error {
                case .server(let message):
                    self.showAlert(title: "lỗi server", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi mạng", message: message)
                }
            }
        }
    }
    
    func deleteComment(){
        struct DeleteComment: Codable {
            let message: String
            let status: Int
        }
        
        guard let commentID = commentID, let commentIndex = commentIndex  else {
            print("thiếu commentID")
            return
        }
        let subUrl = "forum/comment/remove/\(commentID)"
        APIService.share.apiHandle(method: .delete ,subUrl: subUrl, data: DeleteComment.self) { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            switch result {
            case .success(let data):
                commentData.remove(at: commentIndex)
                print("success")
                DispatchQueue.main.async {
                    self.commentCollectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
                switch error {
                case .server(let message):
                    self.showAlert(title: "lỗi server", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi mạng", message: message)
                }
            }
        }
    }
    func subviewHandle(willShow: Bool){
        UIView.animate(withDuration: 0.2) {
            self.subViewLocation.constant = willShow ? -100 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case likeBtn :
            if isLiked {
                favoriteCount! -= 1
            } else {
                favoriteCount! += 1
            }
            isLiked.toggle()
            likeBtnHandle()
            likePost()
            likeComment?()
        case sendBtn:
            print("sendBTN")
            sendComment()
        case imagePickBtn:
            pickImage()
        case removeBtn:
            imageComment.image = nil
            removeBtn.isHidden = true
            didPickImage = false
            sendBtn.isEnabled = !commentTextView.text.isEmpty
            commentViewHandle(type: ViewHeight.textComment)
        case deleteBtn:
            subviewHandle(willShow: false)
            showAlertAndAction(title: "Cảnh báo", message: "Bạn có muốn xóa bình luận không") { [weak self] in
                self?.deleteComment()
            } cancelHandler: { [weak self] in
                print("cancel")
            }
        default:
            break
        }
    }
}
// MARK: - LoadComment
extension CommentsViewController {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if didPickImage {
            commentViewHandle(type: ViewHeight.imageComment)
        } else {
            commentViewHandle(type: ViewHeight.textComment)
        }
        showInputBar(isHidden: false)
        sendBtn.isEnabled = !textView.text.isEmpty
        sendBtn.tintColor = textView.text.isEmpty ? UIColor.lightGray : UIColor.systemBlue
        //        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        if didPickImage {
            sendBtn.isEnabled = true
            sendBtn.tintColor = UIColor.systemBlue
            print("đã chọn ảnh")
        } else {
            sendBtn.isEnabled = !textView.text.isEmpty
            sendBtn.tintColor = textView.text.isEmpty ? UIColor.lightGray : UIColor.systemBlue
            print("chưa chọn ảnh")
            
        }
    }
    //    func textViewDidEndEditing(_ textView: UITextView) {
    //        textView.resignFirstResponder()
    //        sendBtn.tintColor = textView.text.isEmpty ? UIColor.lightGray : UIColor.systemBlue
    //    }
}
// MARK: - LoadComment
extension CommentsViewController {
    func getCommentData(){
        showLoading(isShow: true)
        guard let userID = UserInfo.shared.getUserID(), let postID = postID else {
            showLoading(isShow: false)
            return
        }
        let subUrl = "forum/comment/\(postID)/\(userID)"
        APIService.share.apiHandleGetRequest(subUrl: subUrl, data: CommentsData.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                self.commentData = data.comments
                DispatchQueue.main.async {
                    self.commentCollectionView.reloadData()
                }
                showLoading(isShow: false)
            case .failure(let error):
                showLoading(isShow: false)
                print("lỗi :\(error.localizedDescription)")
                switch error {
                case .network(let message):
                    showAlert(title: "Lỗi mạng", message: message)
                case .server(let message):
                    showAlert(title: "Lỗi server", message: message)
                }
            }
        }
    }
}
// MARK: - CollectionView
extension CommentsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func registerCell(){
        commentCollectionView.dataSource = self
        commentCollectionView.delegate = self
        let cell = UINib(nibName: "CommentCollectionViewCell", bundle: nil)
        commentCollectionView.register(cell, forCellWithReuseIdentifier: "CommentCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commentData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCollectionViewCell", for: indexPath) as! CommentCollectionViewCell
        cell.bindDataComment(data: commentData[indexPath.row], favoriteCount: favoriteCount ?? 0)
        let commentID = commentData[indexPath.row].commentID
        cell.likeComment = { [weak self] in
            self?.likeComment(commentID: commentID)
        }
        cell.gotoUserProfile = { [weak self] in
            self?.goToIntroductVC(index: indexPath.row)
        }
        cell.showSubView = {[weak self] in
            self?.commentID = self?.commentData[indexPath.row].commentID
            self?.subviewHandle(willShow: true)
        }
        cell.hideSubView = {[weak self] in
            self?.commentID = commentID
            self?.commentIndex = indexPath.row
            print("commentID: \(commentID)")
            self?.subviewHandle(willShow: false)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var imageHeight : CGFloat = 0
        var cellHeight : CGFloat = 0
        
        if commentData[indexPath.row].photoURL?.count ?? 0 < 10 {
            imageHeight = 0
        } else {
            imageHeight = 200
        }
        
        let cellTextHeight = heightForText(commentData[indexPath.row].content )
        print("cellTextHeight: \(cellTextHeight)")
        
        if imageHeight + cellTextHeight < 100 {
            cellHeight = 55
        } else {
            if commentData[indexPath.row].content.count < 1 {
                cellHeight = imageHeight + 35
            } else {
                cellHeight = imageHeight + cellTextHeight + 35
            }
        }
        print("cellHeight:\(cellHeight)")
        return CGSize(width: collectionView.bounds.width, height: (cellHeight + 25 ))
    }
    
    func heightForText(_ text: String) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 17) // Thiết lập font cho label (tuỳ chọn)
        let width = commentCollectionView.bounds.width - 110 // Độ rộng của label (có thể thay đổi tùy theo layout của bạn)
        let height = label.height(forWidth: width)
        return height
    }
    func likeComment(commentID: Int){
        struct LikeComment: Codable {
            let message: String
            let status: Int
        }
        //https://api.iudi.xyz/api/forum/comment/favorite/235/30
        guard let userID = UserInfo.shared.getUserID() else {
            print("không có userID")
            return
        }
        let subUrl = "forum/comment/favorite/\(userID)/\(commentID)"
        APIService.share.apiHandle(method: .post ,subUrl: subUrl, data: LikeComment.self) { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            switch result {
            case .success(let data):
                print("success")
            case .failure(let error):
                print(error.localizedDescription)
                switch error {
                case .server(let message):
                    self.showAlert(title: "lỗi server", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi mạng", message: message)
                }
            }
        }
    }
    
    func goToIntroductVC(index: Int){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "UserIntroduceViewController") as! UserIntroduceViewController
        vc.otherUserName = commentData[index].username
        vc.otherUserID = "\(commentData[index].userID )"
        vc.navigationFromOtherVC = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: - ScrollView khi chọn bình luận
extension CommentsViewController {
    func setupScrollView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
        
        DispatchQueue.main.async {  [self] in
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = .zero
        scrollView.contentInset = contentInset
    }
}
// MARK: - Load image slectecd
extension CommentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        // Update the UI with the picked image
        imageComment.image = pickedImage
        picker.dismiss(animated: true) {
            self.sendBtn.isEnabled = true
            self.sendBtn.tintColor = UIColor.systemBlue
            self.didPickImage = true
            self.removeBtn.isHidden = false
            self.commentViewHandle(type: ViewHeight.imageComment)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func pickImage() {
        let titleAlert = NSLocalizedString("Choose Image", comment: "")
        let messageAlert = NSLocalizedString("Choose your option", comment: ""
        )
        let alertViewController = UIAlertController(title: titleAlert,
                                                    message: messageAlert,
                                                    preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera",
                                   style: .default) { (_) in
            UserDefaults.standard.willUploadImage = true
            self.openCamera()
        }
        let galleryText = NSLocalizedString("Gallery", comment: "")
        let gallery = UIAlertAction(title: galleryText,
                                    style: .default) { (_) in
            UserDefaults.standard.willUploadImage = true
            self.openGallary()
        }
        let cancelText = NSLocalizedString("Cancel", comment: "")
        let cancel = UIAlertAction(title: cancelText, style: .cancel) { (_) in
        }
        alertViewController.addAction(camera)
        alertViewController.addAction(gallery)
        alertViewController.addAction(cancel)
        present(alertViewController, animated: true, completion: nil)
    }
}
// MARK: - Alert Choose image
extension CommentsViewController {
    fileprivate func openCamera() {
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
    
    fileprivate func openGallary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .photoLibrary
            /// Cho phép edit ảnh hay là không
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        }
    }
}


