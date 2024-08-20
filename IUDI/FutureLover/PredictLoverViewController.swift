//
//  PredictLoverViewController.swift
//  IUDI
//
//  Created by LinhMAC on 28/05/2024.
//

import UIKit

class PredictLoverViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var otherUserImage: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case nextBtn:
            print("mext")
        case backBtn:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    
    func setupView(){
        userImage.layer.cornerRadius = 8
        userImage.clipsToBounds = true
        nextBtn.layer.cornerRadius = 8
        nextBtn.clipsToBounds = true
        let color = UIColor(red: 0/255.0, green: 135/255.0, blue: 72/255.0, alpha: 1.0)
        backBtn.layer.borderColor = color.cgColor
        backBtn.clipsToBounds = true
    }

}
