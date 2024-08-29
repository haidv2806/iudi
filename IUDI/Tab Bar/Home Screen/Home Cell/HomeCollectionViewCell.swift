
import UIKit
import CollectionViewPagingLayout


class HomeCollectionViewCell: UICollectionViewCell,DateConvertFormat,ServerImageHandle {
    @IBOutlet weak var cellUiView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userDistanceLb: UILabel!
    @IBOutlet weak var userDistanceView: UIView!
    @IBOutlet weak var userNameLb: UILabel!
    @IBOutlet weak var userAgeLb: UILabel!
    @IBOutlet weak var userLocationLb: UILabel!
    
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var loveBtn: UIButton!
    @IBOutlet weak var leadingCellUIView: NSLayoutConstraint!
    @IBOutlet weak var trailingCellUIView: NSLayoutConstraint!
//    @IBOutlet weak var test: UIView!
    
    var options = StackTransformViewOptions()
    var RelationshipType : String?
    weak var homeVCDelegate : HomeVCDelegate?

    var relatedUserID: Int?
    var distanData :Distance?
    var didReacted = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func blindata(data: Distance){
        if let url = data.avatarLink {
//            let avatar = convertStringToImage(imageString: url)
            convertUrlToImage(url: url) { image in
                DispatchQueue.main.async {
                    if let image = image {
                        // Set the image to the UIButton
                        self.userImage.image = image
                    } else {
                        // Handle the case where the image could not be loaded
                        print("Failed to load image.")
                    }
                }
            }
//            userImage.image = avatar
        }
        let rawKilometers = (data.distance ?? 1.0) / 1000.0
        let roundedKilometers = round(rawKilometers * 10) / 10
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        let userDistant = formatter.string(from: NSNumber(value: roundedKilometers)) ?? ""
        userDistanceLb.text = "Khoảng cách " + userDistant + " km"
        userNameLb.text = data.fullName
        let yearOfBirth = convertDate(date: data.birthDate ?? "", inputFormat: "yyyy-MM-dd", outputFormat: "**yyyy**")
        let userAge = Int(Constant.currentYear) - (Int(yearOfBirth) ?? 0)
        userAgeLb.text = String(userAge)
        userLocationLb.text = data.currentAdd
        self.distanData = data
    }
    func setupView(){
        userImage.layer.cornerRadius = 32
        userImage.clipsToBounds = true
        cellUiView.layer.cornerRadius = 32
        cellUiView.layer.borderWidth = 0.5
        cellUiView.layer.borderColor = UIColor.black.cgColor
        cellUiView.clipsToBounds = true
        userDistanceView.layer.cornerRadius = userDistanceView.frame.height/2
        userDistanceView.layer.borderWidth = Constant.borderWidth
        userDistanceView.layer.borderColor = UIColor.white.cgColor
        userDistanceView.clipsToBounds = true
    }
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case removeBtn:
            print("removeBtn")
//            test()
            homeVCDelegate?.setRelationShip(relatedUserID: relatedUserID, relationshipType: "block")
            homeVCDelegate?.gotoNextPage()
        case likeBtn:
            print("other")
            homeVCDelegate?.setRelationShip(relatedUserID: relatedUserID, relationshipType: "other")
        case loveBtn:
            print("favorite")
            homeVCDelegate?.setRelationShip(relatedUserID: relatedUserID, relationshipType: "favorite")
            guard let image = userImage.image else {
                return
            }
            homeVCDelegate?.gotoPreviousChatVC(targetImage: userImage.image ?? image, dataUser: distanData!)
//            print("distanData:\(distanData)")
        default:
            break
        }
    }
}


extension HomeCollectionViewCell: StackTransformView {

    private func applyScaleTransform(progress: CGFloat) {
        let alpha = 1 - abs(progress)
        contentView.alpha = alpha
    }
    var stackOptions: StackTransformViewOptions {
        .layout(.transparent)
    }

}
