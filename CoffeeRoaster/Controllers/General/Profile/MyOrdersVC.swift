//
//  MyOrdersVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 18.05.2023.
//

import UIKit

class MyOrdersVC: UIViewController {
    // MARK: - UI Objects
    //Logo
    private let imageView: UIImageView = {
        let imageView = UIImageView (image: UIImage (named: "logocoffee"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // Title For No Orders
    private let titleNoOrdersLbl: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.clipsToBounds = true
        label.font = .systemFont(ofSize: 28, weight: .light)
        label.text = "You don't have any orders!"
        return label
    }()

    // No Orders Lbl
    private let noOrdersLbl: UILabel = {
        let label = UILabel()
        label.text = "* choose the best coffee for yourself in our shop or contact us for a consultation"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // the button to go to HomeVC
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
        addSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = view.width/3
        
        imageView.frame = CGRect(x: (view.width-size)/2, y: view.height/3, width: size, height: size)
        titleNoOrdersLbl.frame = CGRect(x: 20, y: imageView.bottom+10, width: view.width-40, height: 50)
        noOrdersLbl.frame = CGRect(x: 20, y: titleNoOrdersLbl.bottom+10, width: view.width-40, height: 100)
        goToHome.frame = CGRect(x: 20, y: noOrdersLbl.bottom+20, width: view.width-40, height: 50)
    }
    
    // MARK: - Add Subviews
    private func addSubviews() {
        view.addSubview(noOrdersLbl)
        view.addSubview(titleNoOrdersLbl)
        view.addSubview (imageView)
        view.addSubview(goToHome)
    }
    
    // MARK: - Action
    @objc private func didTabGoToHomeButton() {
        
        guard let parent = navigationController?.viewControllers.first as? ProfileVC else { return }
        
        navigationController?.popToRootViewController(animated: false)
        
        parent.tabBarController?.selectedIndex = 0
        
        guard let tabBar = parent.tabBarController as? TabBarVC else { return }
        tabBar.selectedTab = 0
        
        UIView.transition(with: parent.tabBarController!.view, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: { _ in })
    }
}
