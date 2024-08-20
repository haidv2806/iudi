//
//  FilterCell.swift
//  IUDI
//
//  Created by LinhMAC on 06/03/2024.
//

import UIKit


class FilterCell: UICollectionViewCell,DateConvertFormat, ServerImageHandle {
    @IBOutlet weak var cellUiView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userDistanceLb: UILabel!
    @IBOutlet weak var userNameLb: UILabel!
    @IBOutlet weak var userAgeLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setupView(){
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: cellUiView.frame.height - 1, width: cellUiView.frame.width, height: 1)
        bottomBorder.backgroundColor = UIColor.black.cgColor
        cellUiView.layer.addSublayer(bottomBorder)
    }
    func blindata(data: Distance){
        userImage.image = convertStringToImage(imageString: data.avatarLink ?? "")
        let rawKilometers = (data.distance ?? 1.0) / 1000.0
        let roundedKilometers = round(rawKilometers * 10) / 10
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        let userDistant = formatter.string(from: NSNumber(value: roundedKilometers)) ?? ""
        userDistanceLb.text = userDistant + " km"
        userNameLb.text = data.fullName

        let yearOfBirth = convertDate(date: data.birthDate ?? "", inputFormat: "yyyy-MM-dd", outputFormat: "**yyyy**")
        let userAge = Int(Constant.currentYear) - (Int(yearOfBirth) ?? 0)
        userAgeLb.text = String(userAge)
    }


}
