//
//  TabBarController.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 08.05.2023.
//

import UIKit

class TabBarVC: UITabBarController {
    
    //MARK: - Tracker
    private var selectedTab = 0 {
        didSet {
            for i in 0...3 {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in
                    self?.centerXAnchorsForIndicator[i].isActive = i == self?.selectedTab ? true : false
                    self?.tabBar.layoutIfNeeded()
                } completion: { _ in }
            }
        }
    }
    
    //MARK: - Array of constraints for indicator
    private var centerXAnchorsForIndicator: [NSLayoutConstraint] = []
    private var topAnchorsForIndicator: [NSLayoutConstraint] = []
    
    //MARK: - UI Objects
    var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "DarkBrown")
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setUpControllers()
        configureTabBar()
    }
    
    //MARK: - Set Up Controllers
    private func setUpControllers() {
        //create the current email to transfer to the init ProfileVC
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        // Set Up HomeVC
        let home = HomeVC()
        home.title = "Home"
        home.navigationItem.largeTitleDisplayMode = .always
        
        let vc1  = UINavigationController(rootViewController: home)
        vc1.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill"))
        
        vc1.navigationBar.prefersLargeTitles = true
        vc1.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "DarkBrown")!
        ]
        vc1.navigationBar.tintColor = UIColor(named: "DarkBrown")
        
        // Set Up FavoritesVC()
        let favorites = FavoritesVC()
        favorites.title = "Favorites"
        favorites.navigationItem.largeTitleDisplayMode = .always
        
        let vc2  = UINavigationController(rootViewController: favorites)
        vc2.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill"))
        
        vc2.navigationBar.prefersLargeTitles = true
        vc2.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "DarkBrown")!
        ]
        vc2.navigationBar.tintColor = UIColor(named: "DarkBrown")
        
        // Set Up BasketVC()
        let basket = BasketVC()
        basket.title = "Cart"
        basket.navigationItem.largeTitleDisplayMode = .always
        
        let vc3 = UINavigationController(rootViewController: basket)
        vc3.tabBarItem = UITabBarItem(
            title: "Cart",
            image: UIImage(systemName: "basket"),
            selectedImage: UIImage(systemName: "basket.fill"))
        
        vc3.navigationBar.prefersLargeTitles = true
        vc3.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "DarkBrown")!
        ]
        vc3.navigationBar.tintColor = UIColor(named: "DarkBrown")
        
        // Set Up ProfileVC()
        let profile = ProfileVC(currentEmail: currentUserEmail)
        profile.title = "Profile"
        profile.navigationItem.largeTitleDisplayMode = .always
        
        let vc4 = UINavigationController(rootViewController: profile)
        vc4.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle.fill"))

        vc4.navigationBar.prefersLargeTitles = true
        vc4.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "DarkBrown")!
        ]
        vc4.navigationBar.tintColor = UIColor(named: "DarkBrown")
        
        //set Controllers
        setViewControllers([vc1, vc2, vc3, vc4], animated: true)
    }
    
    //MARK: - Configure nav bar
    private func configureTabBar() {
        tabBar.tintColor = UIColor(named: "DarkBrown")
        tabBar.unselectedItemTintColor = UIColor(named: "LightBrown")
        tabBar.addSubview(indicatorView)
        applyConstraints()
    }
    
    //MARK: - Apply constraints
    private func applyConstraints() {
        // get indicator constraints
        for (index, item) in tabBar.subviews.enumerated() {
            if index == tabBar.subviews.count - 1 {
                continue
            }
            let centerXAnchor = indicatorView.centerXAnchor.constraint(equalTo: item.centerXAnchor)
            centerXAnchorsForIndicator.append(centerXAnchor)
            let topAnchor = indicatorView.topAnchor.constraint(equalTo: item.bottomAnchor,
                                                               constant: 5)
            topAnchorsForIndicator.append(topAnchor)
        }

        // indicatorView constraints
        let indicatorViewConstraints = [
            centerXAnchorsForIndicator[0],
            topAnchorsForIndicator[0],
            indicatorView.heightAnchor.constraint(equalToConstant: 4),
            indicatorView.widthAnchor.constraint(equalToConstant: 4)
        ]

        // activate constraints
        NSLayoutConstraint.activate(indicatorViewConstraints)
    }


    //MARK: - Did select item
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // animation
        if let index = tabBar.items?.firstIndex(of: item) {
            animateToTab(toIndex: index)
        }
        // indicator changes
        switch item.title {
        case "Home":
            selectedTab = 0
        case "Favorites":
            selectedTab = 1
        case "Cart":
            selectedTab = 2
        case "Profile":
            selectedTab = 3
        default:
            selectedTab = 0
        }
    }
    
    //MARK: - Transition animation
    func animateToTab(toIndex: Int) {
        guard let fromView = selectedViewController?.view,
              let toView = viewControllers?[toIndex].view, fromView != toView else {return}
        UIView.transition(from: fromView,
                          to: toView,
                          duration: 0.2,
                          options: [.transitionCrossDissolve],
                          completion: nil)
    }
}
