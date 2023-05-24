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
        localNotificationSetting() ///////////////////////////////// It doesn't show up in my simulator /////////////////////////////
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
        DispatchQueue.main.async {
            //show Home View
            let vc = TabBarVC()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    // Local Notification
    ///////////////////////////////// It doesn't show up in my simulator /////////////////////////////
    private func localNotificationSetting() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Coffee Shop"
        content.body = "Thank you for your order, it was accepted. Our manager will reach out you soon."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil {
                print ("Error = \(error?.localizedDescription ?? "error local notification")")
            } else {
                print("Push was sent")
            }
        }
    }
}
