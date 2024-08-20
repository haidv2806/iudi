//
//  InGroupViewController.swift
//  IUDI
//
//  Created by Quoc on 29/02/2024.
//

import UIKit
import Alamofire

protocol PostsGroupViewControllerDelegate: AnyObject {
    func getGroupID() -> Int?
}

class InGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PostCollectionViewCellDelegate{

    weak var delegate: PostsGroupViewControllerDelegate?
    var groupID: Int?
    var postData: [ListPost] = []
    

    @IBOutlet weak var displayDataPosts: UICollectionView!
    @IBOutlet weak var postsButton: UIButton!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var hideSubViewBtn: UIButton!
    
    private var isMenuOpen = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsButton.layer.borderWidth = 1
        postsButton.layer.cornerRadius = 22
        postsButton.backgroundColor = UIColor(named: "Black")
        avatarView.layer.cornerRadius = avatarView.frame.size.width / 2
        
        postsButton.tintColor = UIColor.clear
        
        displayDataPosts.delegate = self
        displayDataPosts.dataSource = self
        postGroupData()
        
        let nib = UINib(nibName: "PostCollectionViewCell", bundle: .main)
        displayDataPosts.register(nib, forCellWithReuseIdentifier: "PostCollectionViewCell")
        
    }
    
    func postGroupData() {
        guard let groupID = self.groupID else {
            return // Không có ID nhóm, không thể fetch dữ liệu
        }
        let url = "https://api.iudi.xyz/api/forum/group/\(groupID)/1/6"
        print("group: \(groupID)")
        AF.request(url, method: .get).validate(statusCode: 200...299).responseDecodable(of: GroupDataPosts.self) { response in
            switch response.result {
            case .success(let data):
                if let dataArray = data.listPosts {
                    
                    self.postData = dataArray.reversed()
                    self.displayDataPosts.reloadData()
                }
            case .failure(let error):
                print("Lỗi khi lấy dữ liệu:", error.localizedDescription)
            }
        }
    }
    
    @IBAction func postsButtonTapper(_ sender: Any) {
        let vc = PostsGroupViewController()
        vc.groupID = self.groupID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        let postsData = postData[indexPath.row]
        
        cell.deleteCompletion = {[weak self] in
            self?.postGroupData()
        }
        
        cell.postsLabel.text = postsData.content ?? ""
        cell.nameLabel.text = postsData.userFullName ?? ""
        cell.timeLabel.text = postsData.postTime ?? ""
        
        cell.setAvatarImage(data: postsData.avatar ?? "")
        
        cell.setPostsImage(data: postsData.photo ?? "")
        cell.postId = postsData.postID
        
        cell.delegate = self
        
        return cell
    }
    
    func didTapDeleteButton(for postId: Int) {
        // Tạo một thể hiện của subViewController
        let subVC = subViewController()
        subVC.postId = postId
        // Thiết lập detents cho sheetPresentationController nếu cần
        if let sheet = subVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        // Hiển thị subViewController trên màn hình
        self.present(subVC, animated: true, completion: nil)
    }

}

