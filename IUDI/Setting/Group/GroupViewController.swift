//
//  GroupViewController.swift
//  IUDI
//
//  Created by Quoc on 28/02/2024.
//

import UIKit
import Alamofire

class GroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var displayGroup: UICollectionView!
    var groupData: [Datum] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nhóm"
        displayGroup.delegate = self
        displayGroup.dataSource = self
        fetchData()
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
        displayGroup.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
        
    }
    func fetchData() {
        let url = "https://api.iudi.xyz/api/forum/group/all_group"
        AF.request(url, method: .get).validate(statusCode: 200...299).responseDecodable(of: GroupData.self) { response in
            switch response.result {
            case .success(let data):
                if let dataArray = data.data {
                    self.groupData = dataArray
                    self.displayGroup.reloadData()
                }
            case .failure(let error):
                print("Lỗi khi lấy dữ liệu:", error.localizedDescription)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let data = groupData[indexPath.row]
        
        cell.groupName = data.groupName
        
        // Cập nhật ô với dữ liệu
        cell.nameGroup.text = data.groupName ?? ""
        cell.numberOfMembers.text = "\(data.userNumber ?? 0) Thành viên"
        cell.time.text = data.createAt ?? ""
        if let avatarLink = data.avatarLink {
            cell.setImage(fromURL: avatarLink)
        }
        
        // Thiết lập closure cho mỗi cell
        cell.didSelectItem = {
            // Thực hiện việc push sang màn hình đích tương ứng
            let destinationVC = InGroupViewController()
            destinationVC.groupID = data.groupID // Truyền ID của nhóm sang InGroupViewController
            destinationVC.title = cell.groupName // Cập nhật title của màn hình đích
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width // Use the width of the collection view
        let height: CGFloat = 65 // Fixed height for the cells
        return CGSize(width: width, height: height)
    }
    
}

