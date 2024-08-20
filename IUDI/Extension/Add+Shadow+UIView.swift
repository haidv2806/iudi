//
//  Add+Shadow+UIView.swift
//  IUDI
//
//  Created by LinhMAC on 29/02/2024.
//

import UIKit

class ShadeView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // Set shadow properties
        layer.shadowColor = UIColor.red.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 50
        layer.shadowOffset = CGSize(width: 10, height: 10)
    }
}
//extension UICollectionViewFlowLayout {
//    open override var flipsVertical : Bool {
//        return true  //RETURN true if collection view needs to enable RTL
//    }
//    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
//        return true  //RETURN true if collection view needs to enable RTL
//    }
//}
