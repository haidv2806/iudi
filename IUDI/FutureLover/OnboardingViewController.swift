//
//  OnboardingViewController.swift
//  IUDI
//
//  Created by LinhMAC on 28/05/2024.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneBtn.layer.cornerRadius = 8
        doneBtn.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case skipBtn:
            UserDefaults.standard.hasOnboarded = true
            AppDelegate.scene?.goToLogin()
        case doneBtn:
            print("doneBtn")
            gotoUserInputVC()
        default:
            break
        }
    }
    
    func gotoUserInputVC() {
        let vc = UserInputViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
