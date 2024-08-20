

import Foundation
import UIKit

extension UIView {
    // thêm bo góc ở storyboard
//    @IBInspectable var cornerRadius : CGFloat {
//        get {
//            return self.cornerRadius
//        }
//        set {
//            self.layer.cornerRadius = newValue
//        }
//    }
}
extension UIViewController {
    func standardBorder(textField: UITextField) {
        textField.layer.cornerRadius = Constant.cornerRadius
        textField.layer.borderWidth = Constant.borderWidth
        textField.layer.borderColor = Constant.mainColor.cgColor
        //UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00).cgColor
    }
    func standardBtnCornerRadius(button: UIButton) {
        button.layer.cornerRadius = 10  // Thay đổi số này để điều chỉnh độ bo của góc
        button.clipsToBounds = true
    }
    func standardViewCornerRadius(uiView: UIView) {
        uiView.layer.cornerRadius =  Constant.cornerRadius
        uiView.layer.borderWidth = Constant.borderWidth
        uiView.layer.borderColor = Constant.mainBorderColor.cgColor //UIColor.red.cgColor
        uiView.clipsToBounds = true
    }
    
}

class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "App Icone")! as UIImage
    let uncheckedImage = UIImage(named: "Rectangle 8")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
        
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
        
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
extension UILabel {
    func height(forWidth width: CGFloat) -> CGFloat {
        guard let text = self.text else { return 0 }
        
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: self.font]
        
        let rect = text.boundingRect(with: maxSize,
                                     options: options,
                                     attributes: attributes as [NSAttributedString.Key : Any],
                                     context: nil)
        
        return ceil(rect.height)
    }
}




