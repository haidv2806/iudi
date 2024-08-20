//
//  GroupViewController.swift
//  IUDI
//
//  Created by Quoc on 28/02/2024.
//

import UIKit
import Alamofire

class GroupViewController: UIViewController{
    
    @IBOutlet weak var displayGroup: UICollectionView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var searchGroupBar: UISearchBar!
    
    var groupData: [Datum] = []
    var groupDataFilter: [Datum] = []
    var groupName : String?
    private var refeshControl = UIRefreshControl()
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Nhóm"
        fetchAllGroupData()
        registerCell()
        pullToRefesh()
        addSubView(bool: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func fetchAllGroupData() {
        let url = "https://api.iudi.xyz/api/forum/group/all_group"
        AF.request(url, method: .get).validate(statusCode: 200...299).responseDecodable(of: GroupData.self) { response in
            switch response.result {
            case .success(let data):
                if let dataArray = data.data {
                    self.groupData = dataArray
                    self.groupDataFilter = dataArray
                    self.displayGroup.reloadData()
                }
            case .failure(let error):
                print("Lỗi khi lấy dữ liệu:", error.localizedDescription)
            }
        }
    }
    
    func addSubView(bool: Bool){
        let childVC = AddGroupViewController()
        childVC.recallData = { [weak self] in
            self?.fetchAllGroupData()
        }
        childVC.hideSubview = { [weak self] in
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        addChild(childVC)
        if bool {
            view.addSubview(childVC.view)
            childVC.view.frame = view.bounds
            childVC.didMove(toParent: self)
        } else {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
    }
    
    @IBAction func BtnHandle(_ sender: UIButton) {
        switch sender {
        case addBtn:
            addSubView(bool: true)
            print("addBtn.isSelected:\(addBtn.isSelected)")
        default:
            break
        }
    }
}

//MARK: - FilterGroup
extension GroupViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            print("searchBar rỗng")
            self.groupData = groupDataFilter
        }else {
            self.groupData = groupDataFilter
            let filterGroupData = groupData.filter { data in
                if let groupname = data.groupName {
                    let filterReuslt = groupname.lowercased().contains(searchText.lowercased())
                    return filterReuslt
                }
                return false
            }
            self.groupData = filterGroupData
        }
        displayGroup.reloadData()
    }
}

// MARK: - CollectionView
extension GroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func registerCell(){
        displayGroup.delegate = self
        displayGroup.dataSource = self
        if let flowLayout = displayGroup.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 10
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.minimumInteritemSpacing = 10
        }
//        let layout = displayGroup.collectionViewLayout
//        layout.min
        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
        displayGroup.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let data = groupData[indexPath.row]
        cell.bindData(data: data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destinationVC = InGroupViewController()
        let data = groupData[indexPath.row]
        destinationVC.bindData(data: data)
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let width = ((collectionView.bounds.width - 20) / 3) // Use the width of the collection view
            let height: CGFloat = 120 // Fixed height for the cells
            print("collectionView frame: \(width)")
            return CGSize(width: width, height: height)
        } else {
            let width = collectionView.bounds.width // Use the width of the collection view
            let height: CGFloat = 120 // Fixed height for the cells
            print("collectionView frame: \(width)")
            return CGSize(width: width, height: height)
        }
    }
}
// MARK: - Load post
extension GroupViewController {
    func pullToRefesh(){
        refeshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        displayGroup.addSubview(refeshControl)
    }
    @objc func reloadData(send: UIRefreshControl){
        DispatchQueue.main.async {
            self.fetchAllGroupData()
            print("đã reload data")
            self.refeshControl.endRefreshing()
        }
    }
}


