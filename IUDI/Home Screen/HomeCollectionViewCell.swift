//
//  MyCell.swift
//  IUDI
//
//  Created by LinhMAC on 26/02/2024.
//

import UIKit
import CollectionViewPagingLayout

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellUiView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userDistanceLb: UILabel!
    @IBOutlet weak var userNameLb: UILabel!
    @IBOutlet weak var userAgeLb: UILabel!
    @IBOutlet weak var userLocationLb: UILabel!
    
    
    var card: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func blindata(name: String){
        userImage.image = UIImage(named: name)
//        userDistanceLb.text = String(format: "%.1f", userDistance.distance ?? "")
//        userNameLb.text =
    }
    func setupView(){
        userImage.layer.cornerRadius = 32
        userImage.clipsToBounds = true
        cellUiView.layer.cornerRadius = 32
        cellUiView.clipsToBounds = true
    }

}
    
extension HomeCollectionViewCell: StackTransformView {
    func applyScaleTransform(progress: CGFloat) {
        let alpha = 1 - abs(progress)
        contentView.alpha = alpha
    }
    
    var stackOptions: StackTransformViewOptions {
//        .layout(.vortex)
        .layout(.transparent)
    }
}
