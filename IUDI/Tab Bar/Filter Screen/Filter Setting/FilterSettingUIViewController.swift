//
//  FilterSettingUIViewController.swift
//  IUDI
//
//  Created by LinhMAC on 06/03/2024.
//

import UIKit
import SwiftRangeSlider
import iOSDropDown

class FilterSettingUIViewController: UIViewController {
    
    @IBOutlet weak var distanceSlider: RangeSlider!
    @IBOutlet weak var ageSlider: RangeSlider!
    @IBOutlet weak var genderTF: DropDown!
    @IBOutlet weak var currentAddressTF: DropDown!
    
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var currentAddressBtn: UIButton!
    @IBOutlet weak var returnBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    
    @IBOutlet weak var genderBoxView: UIView!
    @IBOutlet weak var currentAddressBoxView: UIView!
    weak var delegate : FilterSettingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromCoreData()
        standardBtnCornerRadius(button: returnBtn)
        returnBtn.layer.borderWidth = 1
        returnBtn.layer.borderColor = Constant.mainBorderColor.cgColor
        standardBtnCornerRadius(button: applyBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dropDownHandle(texfield: genderTF, inputArray: Constant.filterGender)
        dropDownHandle(texfield: currentAddressTF, inputArray: Constant.filterProvinces)
        standardViewCornerRadius(uiView: currentAddressBoxView)
        standardViewCornerRadius(uiView: genderBoxView)
    }
    override func viewDidLayoutSubviews() {
        setupSlider(slider: ageSlider, minimumValue: 18, maximumValue: 70)
        setupSlider(slider: distanceSlider, minimumValue: 0, maximumValue: 60)
    }
    func homeVCReloadData() {
        if let tabBar = self.tabBarController,
           let viewControllers = tabBar.viewControllers {
            for vc in viewControllers {
                if let navController = vc as? UINavigationController,
                   let homeVC = navController.viewControllers.first as? HomeViewController {
                    homeVC.getNearUser()
                    return
                }
            }
        }
        print("lỗi rồi ")
    }
    
    func dropDownHandle(texfield: DropDown, inputArray: [String]){
        texfield.arrowColor = UIColor .red
        texfield.selectedRowColor = UIColor .red
        texfield.optionArray = inputArray
    }
    
    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case genderBtn:
            genderTF.showList()
        case currentAddressBtn:
            currentAddressTF.showList()
            print("saved")
        case applyBtn:
            saveDataToCoreData()
            delegate?.getNearUser()
            homeVCReloadData()
            print("save")
        case returnBtn:
            loadDataFromCoreData()
        default :
            break
        }
    }
    
}
// MARK: - CoreData
extension FilterSettingUIViewController {
    
    func saveDataToCoreData(){
        let filterUserCoreData = FilterUserCoreData.share
        let minDistance = distanceSlider.lowerValue
        let maxDistance = distanceSlider.upperValue
        let minAge = Int(ageSlider.lowerValue)
        let maxAge = Int(ageSlider.upperValue)
        let gender = genderTF.text ?? ""
        filterUserCoreData.saveUserFilterValueToCoreData(currentAddress: currentAddressTF.text ?? "", minDistance: minDistance, maxDistance: maxDistance, minAge: minAge, maxAge: maxAge, gender: gender)
    }
    func loadDataFromCoreData(){
        let coreData = FilterUserCoreData.share
        genderTF.text = coreData.getUserFilterValueFromCoreData(key: "gender") as? String ?? ""
        ageSlider.lowerValue = Double(coreData.getUserFilterValueFromCoreData(key: "minAge") as? Int ?? 0)
        ageSlider.upperValue = Double(coreData.getUserFilterValueFromCoreData(key: "maxAge") as? Int ?? 60)
        
        distanceSlider.upperValue = coreData.getUserFilterValueFromCoreData(key: "maxDistance") as? Double ?? 70
        
        distanceSlider.lowerValue = coreData.getUserFilterValueFromCoreData(key: "minDistance") as? Double ?? 0
        
        currentAddressTF.text = coreData.getUserFilterValueFromCoreData(key: "currentAddress") as? String ?? ""
    }
}
// MARK: - Setup Slider
extension FilterSettingUIViewController {
    @objc func sliderValueChanged(_ slider: RangeSlider) {
        //        print("Selected age range: \(slider.lowerValue) - \(slider.upperValue)")
    }
    
    func setupSlider(slider: RangeSlider,minimumValue: Double, maximumValue: Double){
        // Thiết lập giá trị tối thiểu, tối đa và các giá trị hiện tại
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
        slider.lowerValue = minimumValue
        slider.upperValue = maximumValue
        slider.knobSize = 24
        slider.knobBorderThickness = 1
        slider.knobBorderTintColor = UIColor(red: 0.00, green: 0.53, blue: 0.28, alpha: 1.00)
        slider.labelFontSize = 16
        slider.trackThickness = 5
        slider.trackTintColor = UIColor.gray
        slider.trackHighlightTintColor = UIColor(red: 0.00, green: 0.53, blue: 0.28, alpha: 1.00)
        // Thêm hành động cho sự kiện .valueChanged
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
}

