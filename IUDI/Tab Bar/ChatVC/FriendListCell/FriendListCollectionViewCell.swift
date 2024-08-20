//
//  FriendListCollectionViewCell.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//

import UIKit

class FriendListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var friendListCV: UICollectionView!
    var frameWidth : CGFloat?
    var gotoChatVC : ((ChatData) -> Void)?

    var chatData = [ChatData]()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        registerCollectionView()
        print("FriendListCollectionViewCell:\(chatData.count)")
    }
    
    func bindData(data: [ChatData]) {
        self.chatData = data
        friendListCV.reloadData()
    }
    
}
extension FriendListCollectionViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,CellSizeCaculate {
    
    func setupCollectionView() {
        if let flowLayout = friendListCV.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.itemSize.width = friendListCV.frame.width
        }
    }
    
    func registerCollectionView(){
        friendListCV.dataSource = self
        friendListCV.delegate = self
        let userActiveCell = UINib(nibName: "FriendListCell", bundle: nil)
        friendListCV.register(userActiveCell, forCellWithReuseIdentifier: "FriendListCell")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("chatdata:\(chatData.count)")
        return chatData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendListCell", for: indexPath) as! FriendListCell
        cell.bindData(data: chatData[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("FriendListCell select: \(indexPath.row)")
        self.gotoChatVC?(chatData[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height : CGFloat = 90
        return CGSize(width: width, height: height)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            let width = ((collectionView.bounds.width - 20) / 3) // Use the width of the collection view
//            let height: CGFloat = 120 // Fixed height for the cells
//            print("collectionView frame: \(width)")
//            return CGSize(width: width, height: height)
//        } else {
//            let width = collectionView.bounds.width // Use the width of the collection view
//            let height: CGFloat = 120 // Fixed height for the cells
//            print("collectionView frame: \(width)")
//            return CGSize(width: width, height: height)
//        }
//    }
}

