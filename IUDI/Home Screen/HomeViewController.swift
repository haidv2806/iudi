import UIKit
import SwiftyJSON
import CollectionViewPagingLayout
import Alamofire

class HomeViewController: UIViewController{
    @IBOutlet weak var userCollectionView: UICollectionView!
    
    let dataImage = ["anh1","anh2","anh3","anh4","anh5"]
    var userDistance : UserDistances?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        collectionView.layer.cornerRadius = 100
//        setupView()
        userCollectionView.layer.cornerRadius = 32
        userCollectionView.clipsToBounds = true
        userCollectionView.layer.masksToBounds = true
        userCollectionView.layer.shadowColor = UIColor.black.cgColor
        userCollectionView.layer.shadowOpacity = 1
        userCollectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        userCollectionView.layer.shadowRadius = 4
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        let layout = CollectionViewPagingLayout()
        layout.scrollDirection = .vertical
        layout.numberOfVisibleItems = nil
        userCollectionView.collectionViewLayout = layout
        userCollectionView.isPagingEnabled = true
        userCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
    }
    func setupView(){
        userCollectionView.backgroundColor = UIColor.yellow
        userCollectionView.backgroundView?.layer.cornerRadius = 32
        userCollectionView.layer.cornerRadius = 32
        userCollectionView.clipsToBounds = true

        userCollectionView.layer.shadowColor = UIColor.red.cgColor
        userCollectionView.layer.shadowOpacity = 10
        userCollectionView.layer.shadowOffset = CGSize.zero
        userCollectionView.layer.shadowRadius = 5
    }

}
extension HomeViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        let imageName = dataImage[indexPath.row]
        cell.blindata(name: imageName)
        return cell
        
    }
    
}
