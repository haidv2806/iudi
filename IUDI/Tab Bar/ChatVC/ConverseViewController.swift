//
//  ConverseViewController.swift
//  IUDI
//
//  Created by LinhMAC on 18/03/2024.

import UIKit
import SocketIO
import MessageKit

class ConverseViewController: UIViewController,DateConvertFormat {
    @IBOutlet weak var targerName: UILabel!
    @IBOutlet weak var targerAvatar: UIImageView!
    @IBOutlet weak var targetStatus: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var avatarImageBtn: UIButton!
    
    var messageUserData: MessageUserData?
    var didSelectBtn: (()-> Void)?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        targerAvatar.layer.cornerRadius = targerAvatar.frame.height / 2
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    func bindData(data: MessageUserData?){
        self.messageUserData = data
    }
    func loadData(){
        targerName.text = messageUserData?.otherUserFullName

        targerAvatar.image = messageUserData?.otherUserAvatar
        targetStatus.text = convertServerTimeString(messageUserData?.otherLastActivityTime)
        
//        if ((user.isLoggedIn) != nil) {
//            targetStatus.text = "đang hoạt động"
//            targetStatus.textColor = Constant.mainBorderColor
//        } else {
//            targetStatus.text = lastOnlineDate
//            targetStatus.textColor = UIColor.lightGray
//        }
//        targetStatus.text = lastOnlineDate
//        targerAvatar.image = otherAvatar
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case backBtn :
            print("backBtn")
//            SocketIOManager.shared.mSocket.off("seen")
            navigationController?.popToRootViewController(animated: true)
        case callBtn:
            print("callBtn")
        case avatarImageBtn:
            didSelectBtn?()
        default:
            break
        }
    }
}

