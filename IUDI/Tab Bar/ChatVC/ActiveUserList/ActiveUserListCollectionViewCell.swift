//
//  ActiveUserListCollectionViewCell.swift
//  IUDI
//
//  Created by LinhMAC on 13/03/2024.
//

import UIKit

class ActiveUserListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var activeUserListCV: UICollectionView!
    var chatData = [ChatData]()
    var gotoChatVC : ((ChatData) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        registerCollectionView()
        print("activeUserListCV:\(activeUserListCV.frame.height)")
    }
    func bindData(data: [ChatData], userOnlineId: [Int]) {
        let userOnline = data.filter { chat in
            if let userID = chat.otherUserID {
                return userOnlineId.contains(userID)
            }
            return false
        }
        self.chatData = userOnline
        activeUserListCV.reloadData()
    }
    
}
extension ActiveUserListCollectionViewCell : UICollectionViewDataSource, UICollectionViewDelegate,CellSizeCaculate {
    
    func setupCollectionView() {
        if let flowLayout = activeUserListCV.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 20
            flowLayout.minimumInteritemSpacing = 0
        }
    }
    
    func registerCollectionView(){
        activeUserListCV.dataSource = self
        activeUserListCV.delegate = self
        let userActiveCell = UINib(nibName: "UserActiveCollectionViewCell", bundle: nil)
        activeUserListCV.register(userActiveCell, forCellWithReuseIdentifier: "UserActiveCollectionViewCell")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("chatData.count:\(chatData.count)")

        return chatData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserActiveCollectionViewCell", for: indexPath) as! UserActiveCollectionViewCell
        cell.bindData(data: chatData[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.gotoChatVC?(chatData[indexPath.row])
        print("user select: \(indexPath.row)")
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: bounds.width, height: 72)
//    }
//        let screenWidth = bounds.width
//        if screenWidth >= 700 {
//            return CGSize(width: ((bounds.width)/2)-10, height: 65)
//        } else {
//            return CGSize(width: bounds.width, height: 65)
//        }
//    }
    
}

