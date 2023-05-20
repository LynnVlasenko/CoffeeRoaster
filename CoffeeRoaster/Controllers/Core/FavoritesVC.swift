//
//  FavoritesVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 08.05.2023.
//

import UIKit

class FavoritesVC: UIViewController {
    
    // MARK: - UI Objects
    //Logo
    private let imageView: UIImageView = {
        let imageView = UIImageView (image: UIImage (named: "logocoffee"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    // Title For No Favorites Goods
    private let totleNoFavoritesLbl: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.clipsToBounds = true
        label.font = .systemFont(ofSize: 28, weight: .light)
        label.text = "You don't have any Favotite Products!"
        return label
    }()
    // No Favorites Goods
    private let noFavoritesLbl: UILabel = {
        let label = UILabel()
        label.text = "* choose the coffee you like the most and add it to Favorites for the fastest order"
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
        
        imageView.frame = CGRect(x: (view.width-size)/2, y: view.height/3.5, width: size, height: size)
        totleNoFavoritesLbl.frame = CGRect(x: 20, y: imageView.bottom+10, width: view.width-40, height: 100)
        noFavoritesLbl.frame = CGRect(x: 20, y: totleNoFavoritesLbl.bottom+10, width: view.width-40, height: 100)
        goToHome.frame = CGRect(x: 20, y: noFavoritesLbl.bottom+20, width: view.width-40, height: 50)
    }
    
    // MARK: - Add Subviews
    private func addSubviews() {
        view.addSubview(noFavoritesLbl)
        view.addSubview(totleNoFavoritesLbl)
        view.addSubview (imageView)
        view.addSubview(goToHome)
    }
    
    // MARK: - Action
    @objc private func didTabGoToHomeButton() {
        DispatchQueue.main.async {
            //show Home View
            let vc = TabBarVC()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
}

