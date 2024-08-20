
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
        
//        if test.bounds.height < 50 {
//            leadingCellUIView.constant = 100
//            trailingCellUIView.constant = 100
//        }
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            leadingCellUIView.constant = 100
//            trailingCellUIView.constant = 100
//            print("chiều cao cuả ipadview là :\(test.bounds.height)")
//        } else {
//            // Nếu không, giả sử đây là iPhone
//            print("chiều cao cuả iphoneview là :\(test.bounds.height)")
//
//            print("iphone")
//            leadingCellUIView.constant = 5
//            trailingCellUIView.constant = 5
//        }
        // Thay đổi giá trị của biến
    }
    
    func blindata(data: Distance){
        if let url = data.avatarLink {
            let avatar = convertStringToImage(imageString: url)
            userImage.image = avatar
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
//extension HomeCollectionViewCell: TransformableView {
//    
//    func transform(progress: CGFloat) {
//        var alpha = 1 + progress
//        var y = progress * 13
//        var angle: CGFloat = 0
//        var scale: CGFloat = 1 - progress * 0.05
//        
//        if progress > 3 {
//            alpha = 1 - progress + 3
//            y = 3 * 13
//        }
//        
//        let offset: CGFloat = 240
//        
//        if progress < 0, progress >= -0.5 {
//            alpha = 1
//            let lProgress = -logProgress(min: 0, max: -0.5, progress: progress)
//            y = lProgress * offset
//            angle = lProgress * (-.pi * 0.08)
//        } else if progress < -0.5, progress > -1 {
//            alpha = 1
//            let lProgress = logProgress(min: -0.5, max: -1.0, progress: progress, reverse: true)
//            y = -offset + lProgress * (CGFloat(offset + 30))
//            angle = CGFloat(.pi * 0.08) - lProgress * CGFloat(.pi * 0.08)
//        }
//        
//        if progress < -0.5 {
//            scale = 1 + 0.5 * 0.05 + ((progress + 0.5) * 0.35)
//        }
//
//        let adjustScaleProgress = abs(round(progress) - progress)
//        let adjustScaleLogProgress = logProgress(min: 0, max: 0.5, progress: adjustScaleProgress)
//        var adjustScale = adjustScaleLogProgress * 0.1
//        if progress < 0, progress >= -1.0 {
//            adjustScale *= -1
//        }
//        
//        scale -= adjustScale
//        
//        cellUiView.alpha = alpha
//        cellUiView.transform = CGAffineTransform(translationX: 0, y: y).scaledBy(x: scale, y: scale).rotated(by: angle)
//            
//    }
//    
//    func zPosition(progress: CGFloat) -> Int {
//        if progress < -0.5 {
//            return -10
//        }
//        return Int(-abs(round(progress)))
//    }
//    
//    
//    // MARK: Private functions
//    
//    private func logProgress(min: CGFloat, max: CGFloat, progress: CGFloat, reverse: Bool = false) -> CGFloat {
//        let logValue = (abs(progress - min) / abs(max - min)) * 99
//        let value: CGFloat
//        if reverse {
//            value = 1 - log10(1 + (99 - logValue)) / 2
//        } else {
//            value = log10(1 + logValue) / 2
//        }
//        return value
//    }
//    
//}
