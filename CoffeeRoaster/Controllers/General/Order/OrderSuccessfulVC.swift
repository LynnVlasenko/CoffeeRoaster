//
//  OrderSuccessfulVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 18.05.2023.
//

import UIKit

class OrderSuccessfulVC: UIViewController {
    
    // MARK: - UI Objects
    //Logo
    private let imageView: UIImageView = {
        let imageView = UIImageView (image: UIImage (named: "logocoffee"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //Title For Successful
    private let titleOrderSuccessfulLbl: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.clipsToBounds = true
        label.font = .systemFont(ofSize: 28, weight: .light)
        label.text = "Your order is successful!"
        return label
    }()
    
    // order Successful Lbl
    private let orderSuccessfulLbl: UILabel = {
        let label = UILabel()
        label.text = "* our manager will send details for payment after confirmation of the order"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // the button to add order
    private let goToHome: UIButton = {
        let button = UIButton()
        button.setTitle("Continue Shopping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "LightBrown")
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(didTabGoToHomeButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        NotificationManager.shared.orderedNotification()
        addSubview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = view.width/3
        imageView.frame = CGRect(x: (view.width-size)/2, y: view.height/3, width: size, height: size)
        titleOrderSuccessfulLbl.frame = CGRect(x: 20, y: imageView.bottom+10, width: view.width-40, height: 50)
        orderSuccessfulLbl.frame = CGRect(x: 20, y: titleOrderSuccessfulLbl.bottom+10, width: view.width-40, height: 100)
        goToHome.frame = CGRect(x: 20, y: orderSuccessfulLbl.bottom+20, width: view.width-40, height: 50)
    }

    // MARK: - Add Subviews
    private func addSubview() {
        view.addSubview(orderSuccessfulLbl)
        view.addSubview(titleOrderSuccessfulLbl)
        view.addSubview (imageView)
        view.addSubview(goToHome)
    }
     
    // MARK: - Action
    @objc private func didTabGoToHomeButton() {
        
        guard let parent = navigationController?.viewControllers.first as? BasketVC else { return }
        
        navigationController?.popToRootViewController(animated: false)
        
        parent.tabBarController?.selectedIndex = 0
        
        guard let tabBar = parent.tabBarController as? TabBarVC else { return }
        tabBar.selectedTab = 0
        
        UIView.transition(with: parent.tabBarController!.view, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: { _ in })
    }
}
