import UIKit
import SwiftyJSON
import CollectionViewPagingLayout
import Alamofire
import ReadMoreTextView

protocol HomeVCDelegate:AnyObject {
    func setRelationShip(relatedUserID: Int?, relationshipType: String?)
    func gotoPreviousChatVC(targetImage: UIImage,dataUser: Distance)
    func gotoNextPage()
    func getNearUser()
}

class HomeViewController: UIViewController, HomeVCDelegate{
    
    @IBOutlet weak var userCollectionView: UICollectionView!
    @IBOutlet weak var profileBtn: UIButton!
    var userDistance = [Distance]()
    var stackTransformOptions = StackTransformViewOptions()
    let coreData = FilterUserCoreData.share
    let coreDataMaxDistance = (FilterUserCoreData.share.getUserFilterValueFromCoreData(key: "maxDistance") as? Double ?? 30) * 1000
    let userID = UserInfo.shared.getUserID()
    let userCoreData = UserInfoCoreData.shared
    var userProfile : Users?

    weak var delegate : FilterSettingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        getNearUser()
        getUserProfile()
        setupCollectionView()
        profileBtn.layer.cornerRadius = profileBtn.frame.width / 2
        profileBtn.clipsToBounds = true
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true

    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        SocketIOManager.shared.establishConnection()
        SocketIOManager.shared.mSocket.on("connect") {data, ack in
            self.emitOnline() // Gọi hàm sendUserId() khi kết nối thành công
        }
    }
    
    func setupView(){
        userCollectionView.layer.cornerRadius = 32
        userCollectionView.clipsToBounds = true
        userCollectionView.layer.masksToBounds = true
        userCollectionView.layer.shadowColor = UIColor.black.cgColor
        userCollectionView.layer.shadowOpacity = 1
        userCollectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        userCollectionView.layer.shadowRadius = 4
    }
    

    func setRelationShip(relatedUserID: Int?, relationshipType: String?) {
//        showLoading(isShow: true)
        struct SetRelationShip: Codable {
            let createTime: String?
            let relatedUserID: Int?
            let relationshipType, userID: String?
            
            enum CodingKeys: String, CodingKey {
                case createTime = "CreateTime"
                case relatedUserID = "RelatedUserID"
                case relationshipType = "RelationshipType"
                case userID = "UserID"
            }
        }
        guard let userID = relatedUserID, let relateType = relationshipType else {
            return
        }
        let parameters: [String: Any] = [
            "RelatedUserID": userID,
            "RelationshipType": relateType
        ]
        guard let userID = UserInfo.shared.getUserID() else {
            print("userID rỗng")
            return
        }
        let subUrl = "profile/setRelationship/" + userID
        
        print("parameters: \(parameters)")
        APIService.share.apiHandle(method:.post ,subUrl: subUrl, parameters: parameters, data: SetRelationShip.self) { [weak self] result in
            guard let self = self else { return }
//            self.showLoading(isShow: false)
            switch result {
            case .success(let data):
                print("success")
//                self.showLoading(isShow: false)
            case .failure(let error):
                print(error.localizedDescription)
//                switch error {
//                case .server(let message):
//                    self.showAlert(title: "lỗi1", message: message)
//                case .network(let message):
//                    self.showAlert(title: "lỗi", message: message)
//                }
            }
        }
    }
    
    func gotoPreviousChatVC(targetImage: UIImage,dataUser: Distance){
        let vc = PreviousChatViewController()
        vc.testImage = targetImage
        vc.dataUser = dataUser
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func profileBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.userProfile = userProfile
        vc.transferDataToHomeVC = { [weak self](data,image) in
            self?.userProfile = data
            self?.profileBtn.setImage(image, for: .normal)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
// MARK: - getUser + Filter
extension HomeViewController {
    func filterDistances(_ distances: [Distance]) -> [Distance] {
        let filterGender = coreData.getUserFilterValueFromCoreData(key: "gender") as? String ?? ""
        
        let coreDataMinAge = coreData.getUserFilterValueFromCoreData(key: "minAge") as? Int ?? 18
        let filterMinAge = Int(Constant.currentYear) - coreDataMinAge
        
        let coreDataMaxAge = coreData.getUserFilterValueFromCoreData(key: "maxAge") as? Int ?? 70
        let filterMaxAge = Int(Constant.currentYear) - coreDataMaxAge
        
        let coreDataMinDistance = coreData.getUserFilterValueFromCoreData(key: "minDistance") as? Double ?? 0
        let filterMinDistance = coreDataMinDistance * 1000
        
        let filterAddress = coreData.getUserFilterValueFromCoreData(key: "currentAddress") as? String ?? ""
        
        return distances.filter { distance in
            guard let gender = distance.gender,
                  let birthDateStr = distance.birthDate,
                  let currentAdd = distance.currentAdd else {
                return false
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let birthDate = dateFormatter.date(from: birthDateStr),
                  let birthYear = Calendar.current.dateComponents([.year], from: birthDate).year else {
                return false
            }
            
            let distanceInMeters = distance.distance ?? 0.0
            
            if filterGender.count < 1 && filterAddress.count > 1{
                //                print("no gender")
                return (filterMaxAge...filterMinAge).contains(birthYear) && currentAdd == filterAddress && (filterMinDistance...coreDataMaxDistance).contains(distanceInMeters)
            } else if filterGender.count > 1 && filterAddress.count < 1 {
                //                print("no Address")
                return gender == filterGender && (filterMaxAge...filterMinAge).contains(birthYear) && (filterMinDistance...coreDataMaxDistance).contains(distanceInMeters)
            } else if filterGender.count < 1 && filterAddress.count < 1 {
                //                print("no gender, no Address")
                return (filterMaxAge...filterMinAge).contains(birthYear) && (filterMinDistance...coreDataMaxDistance).contains(distanceInMeters)
            }else {
                //                print("full")
                return gender == filterGender && (filterMaxAge...filterMinAge).contains(birthYear) && currentAdd == filterAddress && (filterMinDistance...coreDataMaxDistance).contains(distanceInMeters)
            }
        }
    }
    
    func getNearUser(){
        print("getNearUser")
        guard let userID = UserInfo.shared.getUserID() else {
            print("userID Nil")
            return
        }
        showLoading(isShow: true)
        let apiService = APIService.share
        let subUrl = "location/\(userID)/\(String(Int(coreDataMaxDistance)))"
        print(coreDataMaxDistance)
        print("url:\(subUrl)")
        apiService.apiHandleGetRequest(subUrl: subUrl,data: UserDistances.self) { result in
            switch result {
            case .success(let data):
                print("getNearUser success")

                guard let distanceData = data.distances else {
                    self.showLoading(isShow: false)
                    return
                }
                // Sử dụng hàm `filterDistances(_:with:)` để lọc mảng `distances`
                let filterData = self.filterDistances(distanceData)
                self.userDistance = filterData
                DispatchQueue.main.async {
                    self.userCollectionView.reloadData()
                }
                self.gotoPreviousPage()
                self.showLoading(isShow: false)
            case .failure(let error):
                print("getNearUser error: \(error.localizedDescription)")
                self.showLoading(isShow: false)
                switch error{
                case .server(let message):
                    self.showAlert(title: "lỗi server", message: message)
                    print("lỗi server \(message)")

                case .network(let message):
                    self.showAlert(title: "lỗi mạng", message: message)
                    print("lỗi mạng \(message)")
                }
            }
        }
    }
}

// MARK: - CollectionView
extension HomeViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        userCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        let layout = CollectionViewPagingLayout()
        layout.scrollDirection = .vertical
        layout.numberOfVisibleItems = nil
        userCollectionView.collectionViewLayout = layout
        userCollectionView.isPagingEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("userDistance.count:\(userDistance.count)")
        return userDistance.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        let data = userDistance[indexPath.item]
        cell.blindata(data: data)
        cell.relatedUserID = data.userID
        cell.homeVCDelegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserIntroduceViewController") as! UserIntroduceViewController
        let data = userDistance[indexPath.row]
        print("indexPath.row: \(indexPath.row)")
        let userID : Int = data.userID ?? 0
        let test = String(userID)
        print("userID: \(test)")
        vc.blindata(data: data)
        vc.dataUser = data
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoNextPage() {
        print("gotoNextPage")
        if let layout = userCollectionView.collectionViewLayout as? CollectionViewPagingLayout {
            layout.goToNextPage(animated: true)
        }
    }
    func gotoPreviousPage() {
        print("gotoPreviousPage")
        if let layout = userCollectionView.collectionViewLayout as? CollectionViewPagingLayout {
            layout.goToPreviousPage(animated: true)
        }
    }
}
extension HomeViewController {
    
    func emitOnline() {
        print("emitOnline")
        let messageData: [String: Any] = [
            "userId": userID ?? ""
        ]
        SocketIOManager.shared.mSocket.emit("userId", messageData)
    }
    
}
extension HomeViewController: ServerImageHandle {
    
    func getUserProfile(){
        showLoading(isShow: true)
        guard let userName = UserInfo.shared.getUserName() else {
            print("không có userName")
            return
        }
        let url = "profile/" + userName
        APIService.share.apiHandleGetRequest(subUrl: url, data: User.self) { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            switch result {
            case .success(let data):
                guard let userData = data.users?.first else {
                    self.showLoading(isShow: false)
                    return
                }
                self.userProfile = userData
                userCoreData.saveProfileValueToCoreData(userAvatarUrl: userData.avatarLink, userFullname: userData.fullName, userEmail: userData.email
                )
//                let image = convertStringToImage(url: userData.avatarLink ?? "")
                convertUrlToImage(url: userData.avatarLink ?? "") { image in
                    DispatchQueue.main.async {
                        if let image = image {
                            // Set the image to the UIButton
                            self.profileBtn.setImage(image, for: .normal)
                        } else {
                            // Handle the case where the image could not be loaded
                            print("Failed to load image.")
                        }
                    }
                }
                //                profileBtn.setImage(image, for: .normal)
                profileBtn.contentMode = .scaleAspectFit
                self.showLoading(isShow: false)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                self.showLoading(isShow: false)
                switch error{
                case .server(let message):
                    self.showAlert(title: "lỗi", message: message)
                case .network(let message):
                    self.showAlert(title: "lỗi", message: message)
                }
            }
        }
    }
}

