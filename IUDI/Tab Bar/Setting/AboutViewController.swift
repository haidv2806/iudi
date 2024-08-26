//
//  AboutViewController.swift
//  IUDI
//
//  Created by Quoc on 27/02/2024.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        let backButton = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = backButton
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case backBtn :
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }

}
