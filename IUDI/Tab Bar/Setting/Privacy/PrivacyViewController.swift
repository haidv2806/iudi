//
//  PrivacyViewController.swift
//  IUDI
//
//  Created by Quoc on 28/02/2024.
//

import UIKit
import DropDown

class PrivacyViewController: UIViewController {

    @IBOutlet weak var lineAllowView: UIImageView!
    @IBOutlet weak var allowButton: UIButton!
    @IBOutlet weak var allowLabel: UILabel!
    
    @IBOutlet weak var lineView: UIImageView!
    @IBOutlet weak var seenButton: UIButton!
    @IBOutlet weak var seenLabel: UILabel!
    
    @IBOutlet weak var myselfView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    let dropDownStatus = DropDown()
    let dropDownMess = DropDown()
    let dropDownAllow = DropDown()
    
    let allowArrayValue = ["Mọi người", "Bạn bè"]
    let messArrayValue = ["Đang tắt", "Đang bật"]
    let statusArrayValue = ["Chia sẻ", "Chỉ mình tôi", "Bạn bè", "Mọi người"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Quyền riêng tư"
        // Do any additional setup after loading the view.
        createDropDown()
    }

    func createDropDown() {
        dropDownStatus.anchorView = statusButton
        dropDownStatus.dataSource = statusArrayValue
        
        dropDownStatus.bottomOffset = CGPoint(x: 0, y: (dropDownStatus.anchorView?.plainView.bounds.height)!)
        dropDownStatus.topOffset = CGPoint(x: 0, y: -(dropDownStatus.anchorView?.plainView.bounds.height)!)
        dropDownStatus.direction = .bottom
        
        dropDownStatus.selectionAction = {(index: Int, item: String) in
            self.statusLabel.text = self.statusArrayValue[index]
            self.statusLabel.textColor = .black
        }
        
        dropDownMess.anchorView = lineView
        dropDownMess.dataSource = messArrayValue
        
        dropDownMess.bottomOffset = CGPoint(x: 0, y: (dropDownMess.anchorView?.plainView.bounds.height)!)
        dropDownMess.topOffset = CGPoint(x: 0, y: -(dropDownMess.anchorView?.plainView.bounds.height)!)
        
        dropDownMess.selectionAction = {(index: Int, item: String) in
            self.seenLabel.text = self.messArrayValue[index]
            self.seenLabel.textColor = .black
        }
        
        dropDownAllow.anchorView = lineAllowView
        dropDownAllow.dataSource = allowArrayValue
        
        dropDownAllow.bottomOffset = CGPoint(x: 0, y: (dropDownAllow.anchorView?.plainView.bounds.height)!)
        dropDownAllow.topOffset = CGPoint(x: 0, y: -(dropDownAllow.anchorView?.plainView.bounds.height)!)
        
        dropDownAllow.selectionAction = {(index: Int, item: String) in
            self.allowLabel.text = self.allowArrayValue[index]
            self.allowLabel.textColor = .black
        }
    }

    @IBAction func statusTapped(_ sender: Any) {
        dropDownStatus.show()
    }
    
    @IBAction func messTapped(_ sender: Any) {
        dropDownMess.show()
    }
    
    @IBAction func allowTapp(_ sender: Any) {
        dropDownAllow.show()
    }
    
    @IBAction func blockMessTapped(_ sender: Any) {
        let vc = BlockMessViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
