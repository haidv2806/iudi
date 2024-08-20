//
//  InGroupViewController.swift
//  IUDI
//
//  Created by Quoc on 29/02/2024.
//

import UIKit
import Alamofire

protocol PostsGroupVCDelegate: AnyObject {
    func loadPostGroupFrombegin()
}

class InGroupViewController: UIViewController, PostsGroupVCDelegate,ServerImageHandle {
    
    @IBOutlet weak var displayDataPosts: UICollectionView!
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var hideSubViewBtn: UIButton!
    @IBOutlet weak var subviewLocation: NSLayoutConstraint!
    @IBOutlet weak var deletePost: UIButton!
    @IBOutlet weak var hidePost: UIButton!
    @IBOutlet weak var subView: UIView!
    
    let userID = UserInfo.shared.getUserID()
    var groupID: Int?
    var postData = [ListPost]()

    var groupTitle : String?
    private var isMenuOpen = false
    var deletePostID: Int?
    
    private var refeshControl = UIRefreshControl()
    var pageNumber = 1
    var isLoading = false
    var commentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionview()
        loadPostGroupFrombegin()
        setUpView()
        title = groupTitle
        pullToRefesh()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewDidLayoutSubviews() {
        avatarView.layer.cornerRadius = avatarView.frame.size.width / 2
        avatarView.clipsToBounds = true
    }
    func bindData(data: Datum){
        self.groupID = data.groupID
        self.groupTitle = data.groupName
    }
    func setUpView(){
        subView.isHidden = true
        postsButton.layer.borderWidth = 1
        postsButton.layer.cornerRadius = 22
        postsButton.backgroundColor = UIColor(named: "Black")
        postsButton.tintColor = UIColor.clear
        title = "Nhóm"
        let userInfo = UserInfoCoreData.shared.fetchProfileFromCoreData()
        avatarView.image = convertStringToImage(imageString: userInfo?.userAvatarUrl ?? "")
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case postsButton :
            let vc = PostsGroupViewController()
            vc.groupID = self.groupID
            vc.postsGroupVCDelegate = self
            navigationController?.pushViewController(vc, animated: true)
        case hideSubViewBtn:
            displayMenu(userPostId: 0)
        case deletePost:
            deletePostHandle()
            print("deletePost")
        case hidePost:
            print("deletePost")
        default:
            break
        }
    }
    // Giả sử bạn muốn truy cập vào cell tại indexPath cụ thể
    func accessSpecificCell() {
        postData[commentIndex].isFavorited = !(postData[commentIndex].isFavorited ?? false)
        displayDataPosts.reloadItems(at: [IndexPath(item: commentIndex, section: 0)])
        
        // Đảm bảo collectionView không bị nil
//        let indexPath = IndexPath(row: commentIndex, section: 0)
//        guard let collectionView = self.displayDataPosts else {
//            print("collectionView is nil")
//            return
//        }
//
//        // Kiểm tra xem indexPath có hợp lệ không
//        if indexPath.row < collectionView.numberOfItems(inSection: indexPath.section) {
//            // Lấy cell tại indexPath
//            if let cell = collectionView.cellForItem(at: indexPath) as? PostCollectionViewCell {
//                // Thực hiện các hành động mong muốn với cell
//                print("Successfully accessed cell at \(indexPath)")
//                // Ví dụ, bạn có thể gọi một phương thức cụ thể trên cell
//                cell.likeBtnHandle1()
//            } else {
//                print("Could not find cell at \(indexPath)")
//            }
//        } else {
//            print("Invalid indexPath: \(indexPath)")
//        }
    }


}
// MARK: - Load post
extension InGroupViewController {
    func pullToRefesh(){
        refeshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        displayDataPosts.addSubview(refeshControl)
    }
    @objc func reloadData(send: UIRefreshControl){
        DispatchQueue.main.async {
            self.loadPostGroupFrombegin()
            print("đã reload data")
            self.refeshControl.endRefreshing()
        }
    }
    func loadPostGroupFrombegin() {
        showLoading(isShow: true)
        guard let groupID = self.groupID,let userID = userID else {
            showLoading(isShow: false)
            return // Không có ID nhóm, không thể fetch dữ liệu
        }
        let url = "https://api.iudi.xyz/api/forum/group/\(groupID)/1/10/\(userID)"
        print("url: \(url)")

        print("groupID: \(groupID)")
        AF.request(url, method: .get).validate(statusCode: 200...299).responseDecodable(of: GroupDataPosts.self) { response in
            switch response.result {
            case .success(let data):
                guard let dataArray = data.listPosts else{
                    self.showLoading(isShow: false)
                    return
                }
                    self.postData = dataArray
//                    self.postData = dataArray.reversed()
                    self.displayDataPosts.reloadData()
                    self.isLoading = false
                    self.showLoading(isShow: false)
            case .failure(let error):
                self.showLoading(isShow: false)
                print("Lỗi khi lấy dữ liệu:", error.localizedDescription)
            }
        }
    }
    func loadPostGroup() {
        showLoading(isShow: true)
        guard let groupID = self.groupID, let userID = userID else {
            showLoading(isShow: false)
            return // Không có ID nhóm, không thể fetch dữ liệu
        }
        let url = "https://api.iudi.xyz/api/forum/group/\(groupID)/\(pageNumber)/10/\(userID)"
        print("groupID: \(groupID)")
        print("url: \(url)")

        AF.request(url, method: .get).validate(statusCode: 200...299).responseDecodable(of: GroupDataPosts.self) { response in
            switch response.result {
            case .success(let data):
                guard let dataArray = data.listPosts else{
                    self.showLoading(isShow: false)
                    return
                }
                guard dataArray.count > 0 else {                    self.showLoading(isShow: false)
//                    self.showAlert(title: "Thông báo", message: "Đây là post cuối rồi")
                    print("dataArray.count = 0 :\(dataArray.count)")
                    return
                }
                    self.postData += dataArray
//                    self.postData = dataArray.reversed()
                    self.displayDataPosts.reloadData()
                    self.isLoading = false
                    self.showLoading(isShow: false)
            case .failure(let error):
                self.showLoading(isShow: false)
                print("Lỗi khi lấy dữ liệu:", error.localizedDescription)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height && !isLoading {
            pageNumber += 1 // Tăng trang lên để tải trang tiếp theo
            isLoading = true
            loadPostGroup() // Tải dữ liệu cho trang tiếp theo
            print("scrollViewDidScroll")
        }
    }

}

// MARK: - hàm subview
extension InGroupViewController {
    func displayMenu(userPostId: Int) {
        isMenuOpen.toggle()
        hideSubViewBtn.isHidden = !isMenuOpen
        UIView.animate(withDuration: 0.2, animations: {
            self.hideSubViewBtn.alpha = self.isMenuOpen ? 0.5 : 0
            self.subView.isHidden = !self.isMenuOpen
//            self.subviewLocation.constant = self.isMenuOpen ? 0 : -50
            self.view.layoutIfNeeded()
        })
        self.tabBarController?.tabBar.isHidden = self.isMenuOpen
    }
}

// MARK: - Xóa Post, Like Post, Comment
extension InGroupViewController {
    
    func passPostID(postId: Int, isUser: Bool){
        self.deletePostID = postId
//        self.isUserPost = isUser
        print("passPostID : \(postId)")
    }
    func deletePostHandle(){
        showAlertAndAction(title: "Xác nhận", message: "Bạn có chắc chắn muốn xóa bài đăng này không?", completionHandler:  {
            self.deletePosst()
        }, cancelHandler: {
            print("something")
        })
    }
    
    func deletePosst(){
        guard let postId = deletePostID else {
            print("khong co post id")
            return
        }
        let subUrl = "forum/delete_post/\(postId)"
        print("subUrl : \(subUrl)")

        APIService.share.apiHandle(method: .delete ,subUrl: subUrl, data: GroupDataPosts.self) { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            switch result {
            case .success(let data):
                print("data:\(data)")
                DispatchQueue.main.async {
                    self.loadPostGroup()
                }
                self.showAlert(title: "Thông báo", message: "Xóa bài thành công") {
                    self.loadPostGroupFrombegin()
                    self.displayMenu(userPostId: 0)
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
    func likePost(postID: Int?){
//"https://api.iudi.xyz/forum/favorite/<userID>/<postID>"
        guard let userID = userID, let postID = postID else {return}
        let subUrl = "forum/favorite/\(userID)/\(postID)"
        APIService.share.apiHandle(method: .post ,subUrl: subUrl, data: PostData.self) { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            switch result {
            case .success(_):
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
    
    func commentPost(postID: Int?){
//"https://api.iudi.xyz/forum/favorite/<userID>/<postID>"
        guard let userID = userID, let postID = postID else {return}
        let subUrl = "forum/favorite/\(userID)/\(postID)"
        APIService.share.apiHandle(method: .post ,subUrl: subUrl, data: PostData.self) { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            switch result {
            case .success(_):
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
    
    func goToCommentVC(index: Int){
        let vc = CommentsViewController()
        vc.postID = postData[index].postID
        vc.isLiked = postData[index].isFavorited ?? false
        vc.favoriteCount = postData[index].favoriteCount
        vc.likeComment = { [weak self] in
            self?.accessSpecificCell()
        }
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    func goToIntroductVC(index: Int){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "UserIntroduceViewController") as! UserIntroduceViewController
        vc.otherUserName = postData[index].username
        vc.otherUserID = "\(postData[index].userID ?? 0)"
        vc.navigationFromOtherVC = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
// MARK: - CollectionView

extension InGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setupCollectionview(){
        displayDataPosts.delegate = self
        displayDataPosts.dataSource = self
        let nib = UINib(nibName: "PostCollectionViewCell", bundle: .main)
        displayDataPosts.register(nib, forCellWithReuseIdentifier: "PostCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexPath:\(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        let postsData = postData[indexPath.row]
        
        cell.blindata(data: postsData)
        cell.deletePost = { [weak self] in
            guard let self = self else {return}
            displayMenu(userPostId: postsData.userID ?? 0)
            self.deletePostID = postsData.postID
        }
        cell.likePost = { [weak self] in
            guard let self = self else {return}
            self.likePost(postID:  postsData.postID)
            self.postData[indexPath.row].isFavorited? = !(postsData.isFavorited ?? false)
            collectionView.reloadItems(at: [indexPath])
        }
        cell.commentPost = { [weak self] in
            self?.commentIndex = indexPath.row
            guard let self = self else {return}
            self.goToCommentVC(index: indexPath.row)
        }
        cell.avatarTapped = { [weak self] in
            self?.goToIntroductVC(index: indexPath.row)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let userAvater : CGFloat = 60
        var imageHeight : CGFloat = 0
        if postData[indexPath.row].photo?.count ?? 0 < 10 {
            imageHeight = 0
        } else {
            imageHeight = 315
        }
        let cellHeightIncrement = heightForText(postData[indexPath.row].content ?? "")
        var spaceHeight : CGFloat = 20
        // nếu như user comment cả ảnh và text
        if imageHeight > 0 && postData[indexPath.row].content?.count ?? 0 > 1 {
            spaceHeight = 20
        } else if imageHeight > 0 && postData[indexPath.row].content?.count ?? 0 < 1 {
            // user chỉ comment ảnh
            spaceHeight = 0
        } else {
            // user chỉ comment text
            spaceHeight = 20
        }
        let bottomHeight : CGFloat = 40
        let cellHeight = userAvater + cellHeightIncrement + imageHeight + spaceHeight + bottomHeight

        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    func heightForText(_ text: String) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 17) // Thiết lập font cho label (tuỳ chọn)
        let width = displayDataPosts.frame.width // Độ rộng của label (có thể thay đổi tùy theo layout của bạn)
        let height = label.height(forWidth: width)
        return height
    }
    
}

