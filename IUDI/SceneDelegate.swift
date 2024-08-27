//
//  SceneDelegate.swift
//  IUDI
//
//  Created by LinhMAC on 22/02/2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    static let shared = SceneDelegate()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // kiểm tra xem có người dùng đã chọn theme chưa, nếu chưa load theme theo hệ thống
        
//        if let selectedTheme = UserDefaults.standard.selectedTheme {
//            print("Selected Theme:", selectedTheme.rawValue)
//            ThemeManager.shared.applyTheme(selectedTheme, to: window)
//        } else {
//            print("No theme saved. Using default theme.")
//            ThemeManager.shared.applyTheme(.system, to: window)
//        }
        
        /// Vứt cho appDelegate nó giữ để sau mình lấy ra cho dễ
        (UIApplication.shared.delegate as? AppDelegate)?.window = window
        
        if UserDefaults.standard.hasOnboarded {
            if UserDefaults.standard.didLogin {
                if UserDefaults.standard.didOnMain {
                    setupTabBar()
                } else {
                    goToProfile()
                }
            } else {
                goToLogin()
                print("goToLogin")
            }
        } else {
            gotoOnbroadVC()
        }

    }
    
    func setupTabBar() {
        let tabBarVC = UITabBarController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            print("Failed to instantiate HomeViewController from storyboard")
            return
        }
        //        homeVC.title = "Home"
        let homeNavVC = UINavigationController(rootViewController: homeVC)
        
        
        homeNavVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Home-UnSelect"), selectedImage: UIImage(named: "Home-Selected"))
        
        let filterVC = FilterViewController()
        //        filterVC.title = "Filter"
        let filterNavVC = UINavigationController(rootViewController: filterVC)
        filterNavVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Location-UnSelect"), selectedImage: UIImage(named: "Location-Selected"))
        
        let groupVC = GroupViewController()
        //        filterVC.title = "Filter"
        let groupNavVC = UINavigationController(rootViewController: groupVC)
        groupNavVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Vector-2"), selectedImage: UIImage(named: "cộng đồng xanh"))
//        UserInputViewController
        let chatVC = ChatViewController()
//        let chatVC = UserInputViewController()

        //        filterVC.title = "Filter"
        let chatNavVC = UINavigationController(rootViewController: chatVC)
        chatNavVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Chat-UnSelect"), selectedImage: UIImage(named: "Chat-Selected"))
        
        let settingVC = SettingViewController()
        //        filterVC.title = "Filter"
        let settingNavVC = UINavigationController(rootViewController: settingVC)
        settingNavVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Setting-UnSelect"), selectedImage: UIImage(named: "Setting-Selected"))
        
        tabBarVC.viewControllers = [homeNavVC, filterNavVC,groupNavVC,chatNavVC,settingNavVC]
        tabBarVC.modalPresentationStyle = .fullScreen
        tabBarVC.tabBar.tintColor = UIColor(named: "MainColor")
        tabBarVC.tabBar.backgroundColor = UIColor(hex: "#111111")
        
        // Tạo UIImageView với ảnh nền
        let backgroundImageView = UIImageView(frame: tabBarVC.tabBar.bounds)
        backgroundImageView.image = UIImage(named: "Rectangle 21") // Thay "your_image_name" bằng tên ảnh của bạn
        backgroundImageView.contentMode = .scaleAspectFill // Điều chỉnh chế độ hiển thị ảnh nếu cần

        // Thêm UIImageView vào tabBar
        tabBarVC.tabBar.insertSubview(backgroundImageView, at: 0)
        
        
        
        tabBarVC.tabBar.layer.opacity = 1
        tabBarVC.tabBar.isTranslucent = true
        tabBarVC.tabBar.itemPositioning = .fill
        window!.rootViewController = tabBarVC
        window!.makeKeyAndVisible()
        //        present(tabBarVC, animated: true)
    }
    func gotoOnbroadVC(){
        let onboardingVC = OnboardingViewController(nibName: "OnboardingViewController", bundle: nil)
//        let onboardingVC = PredictLoverResultViewController(nibName: "PredictLoverResultViewController", bundle: nil)
        let onboardingNavigation = UINavigationController(rootViewController: onboardingVC)
        window!.rootViewController = onboardingNavigation
        window!.makeKeyAndVisible()
    }
    
    func goToFilter() {
        print("Đã login rồi. Cho vào Home")
        let mainVC = ChatViewController(nibName: "ChatViewController", bundle: nil)
//        let mainVC = FilterViewController(nibName: "FilterViewController", bundle: nil)
        let mainNavigation = UINavigationController(rootViewController: mainVC)
        window!.rootViewController = mainNavigation
        window!.makeKeyAndVisible()
    }
    
    func goToProfile() {
        print("Đã login rồi. Cho vào Home")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
        let profileNavigation = UINavigationController(rootViewController: profileVC)
        window!.rootViewController = profileNavigation
        window!.makeKeyAndVisible()
    }
    func goToHome() {
        print("Đã login rồi. Cho vào Home")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        let mainNavigation = UINavigationController(rootViewController: mainVC)
        window!.rootViewController = mainNavigation
        window!.makeKeyAndVisible()
    }
    func goToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let loginNavigation = UINavigationController(rootViewController: loginVC)
        window!.rootViewController = loginNavigation
        window!.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

