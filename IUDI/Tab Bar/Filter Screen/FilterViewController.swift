
import UIKit

protocol FilterSettingDelegate:AnyObject{
    func getNearUser()
}
class FilterViewController: UIViewController,FilterSettingDelegate {

    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var subviewLocation: NSLayoutConstraint!
    @IBOutlet weak var hideSubViewBtn: UIButton!
    
    private var isMenuOpen = false
    let itemNumber = 4.0
    let minimumLineSpacing = 10.0
    var userDistance = [Distance]()
    let coreData = FilterUserCoreData.share
    let coreDataMaxDistance = (FilterUserCoreData.share.getUserFilterValueFromCoreData(key: "maxDistance") as? Double ?? 30) * 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        registerCollectionView()
        getNearUser()
        subviewHandle()
        getNearUser()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func btnHandle(_ sender: UIButton) {
        switch sender {
        case filterBtn:
            displayMenu()
        case hideSubViewBtn:
            displayMenu()
            print("display")
        default :
            break
        }
    }
    
    func filterDistances(_ distances: [Distance]) -> [Distance] {
        let coreData = FilterUserCoreData.share
        let filterGender = coreData.getUserFilterValueFromCoreData(key: "gender") as? String ?? ""
        
        let coreDataMinAge = coreData.getUserFilterValueFromCoreData(key: "minAge") as? Int ?? 18
        let filterMinAge = Int(Constant.currentYear) - coreDataMinAge
        
        let coreDataMaxAge = coreData.getUserFilterValueFromCoreData(key: "maxAge") as? Int ?? 70
        let filterMaxAge = Int(Constant.currentYear) - coreDataMaxAge
        
//        let coreDataMaxDistance = coreData.getUserFilterValueFromCoreData(key: "maxDistance") as? Double ?? 30
        let filterMaxDistance = coreDataMaxDistance * 1000
        
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
                return (filterMaxAge...filterMinAge).contains(birthYear) && currentAdd == filterAddress && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            } else if filterGender.count > 1 && filterAddress.count < 1 {
//                print("no Address")
//                print("filterValue: \(filterGender.count),\(filterMinAge),\(filterMaxAge),\(filterMaxDistance),\(filterMinDistance),\(filterAddress.count)")
                return gender == filterGender && (filterMaxAge...filterMinAge).contains(birthYear) && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            } else if filterGender.count < 1 && filterAddress.count < 1 {
//                print("no gender, no Address")
                return (filterMaxAge...filterMinAge).contains(birthYear) && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            }else {
//                print("full")
                return gender == filterGender && (filterMaxAge...filterMinAge).contains(birthYear) && currentAdd == filterAddress && (filterMinDistance...filterMaxDistance).contains(distanceInMeters)
            }
            //                        return gender == "Nam" && (0...2024).contains(birthYear) && currentAdd == "" && (100...30000).contains(distanceInMeters)
        }
    }



    func getNearUser(){
        guard let userID = UserInfo.shared.getUserID() else {
            print("userID Nil")
            return
        }
        let apiService = APIService.share
        let subUrl = "location/\(userID)/\(String(Int(coreDataMaxDistance)))"
        print("url:\(subUrl)")
        apiService.apiHandleGetRequest(subUrl: subUrl,data: UserDistances.self) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    guard let distanceData = data.distances else {
                        return
                    }
                    // Sử dụng hàm `filterDistances(_:with:)` để lọc mảng `distances`
                    let filterData = self.filterDistances(distanceData)
                    self.userDistance = filterData
                    print("userDistance: \(self.userDistance.count)")
//                    print("filterData: \(filterData)")
                    self.filterCollectionView.reloadData()
                }
            case .failure(let error):
                print("error: \(error.localizedDescription)")
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

// MARK: - Add Subview
extension FilterViewController {
    
    private func displayMenu() {
        isMenuOpen.toggle()
        hideSubViewBtn.isHidden = !isMenuOpen
        UIView.animate(withDuration: 0.5, animations: {
            self.hideSubViewBtn.alpha = self.isMenuOpen ? 0.5 : 0
            self.subviewLocation.constant = self.isMenuOpen ? 0 : -550
            self.view.layoutIfNeeded()
        })
        self.tabBarController?.tabBar.isHidden = self.isMenuOpen
    }
    
    func subviewHandle(){
        let childVC = FilterSettingUIViewController()
        addChild(childVC)
        subView.addSubview(childVC.view)
        childVC.view.frame = subView.bounds
        childVC.didMove(toParent: self)
        childVC.delegate = self
        subviewLocation.constant = -550
        hideSubViewBtn.isHidden = true
    }
    
}
// MARK: - CollectionView
extension FilterViewController : UICollectionViewDataSource, UICollectionViewDelegate,CellSizeCaculate, UICollectionViewDelegateFlowLayout {
    
    func registerCollectionView(){
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        let cell = UINib(nibName: "FilterCell", bundle: nil)
        filterCollectionView.register(cell, forCellWithReuseIdentifier: "FilterCell")
    }
    
    private func setupCollectionView() {
        if let flowLayout = filterCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = minimumLineSpacing
            flowLayout.minimumInteritemSpacing = minimumLineSpacing
            flowLayout.itemSize.width = filterCollectionView.frame.size.width
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userDistance.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        let data = userDistance[indexPath.row]
        cell.blindata(data: data)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let width = ((collectionView.bounds.width - 10) / 2) // Use the width of the collection view
            let height: CGFloat = 65 // Fixed height for the cells
            print("collectionView frame: \(width)")
            return CGSize(width: width, height: height)
        } else {
            let width = collectionView.bounds.width // Use the width of the collection view
            let height: CGFloat = 65 // Fixed height for the cells
            print("collectionView frame: \(width)")
            return CGSize(width: width, height: height)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserIntroduceViewController") as! UserIntroduceViewController
        vc.dataUser = userDistance[indexPath.row]
        let data = userDistance[indexPath.row]
        print("indexPath.row: \(indexPath.row)")
        let userID : Int = data.userID ?? 0
        let test = String(userID)
        print("userID: \(test)")
        vc.blindata(data: data)
        navigationController?.pushViewController(vc, animated: true)
    }

}
