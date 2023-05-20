//
//  OrderVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 17.05.2023.
//

import UIKit
import UserNotifications

class OrderVC: UIViewController {

    // Array for ids of ordered goods
    private var idsOrderedGoods: [String] = []
    // total cost data
    private var totalCost: Float = 0.0
    
    // MARK: - UI Objects
    // title - Recipient Data
    private let titleLbl: UILabel = {
        let label = UILabel()
        label.text = "Recipient Data"
        //label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 25, weight: .light)
        return label
    }()
    
    // line
    private let lineView: UIView = {
        let line = UIView()
        line.backgroundColor = .gray
        return line
    }()
    
    // Name field
    private let recipientNameField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Name"
        field.font = .systemFont(ofSize: 17, weight: .light)
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    // Surename field
    private let recipientSurnameField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Surename"
        field.font = .systemFont(ofSize: 17, weight: .light)
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    // Phone field (then complete the verification of the number correctness)
    public let recipientPhoneField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Phone"
        field.font = .systemFont(ofSize: 17, weight: .light)
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        //call up the numeric keypad
        field.keyboardType = .phonePad
        field.layer.masksToBounds = true
        return field
    }()
    
    // Address field
    private let recipientAddressField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Address"
        field.font = .systemFont(ofSize: 17, weight: .light)
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    // Title for commentTextView
    private let commentTitleLbl: UILabel = {
        let label = UILabel()
        label.text = "Comment:"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    // TextView for comment
    private let commentTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 17, weight: .light)
        textView.layer.masksToBounds = true
        return textView
    }()
    
    // Total label
    private let totalLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // payment explanation label
    private let explanationLbl: UILabel = {
        let label = UILabel()
        label.text = "* the manager will send details for payment after confirmation of the order"
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    // the button to Place Order
    private let addOrderButton: UIButton = {
        let button = UIButton()
        button.setTitle("Place Your Order", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "LightBrown")
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(didTabAddOrderButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Order"
        view.backgroundColor = .systemBackground
        configureNavBar()
        addSubviews()
        
        getTotal()
        getOrderedGoodsIds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // get total cost for all of products in basket when view Will Appear
        getTotal()
        // get all good Ids from basket to save in BD
        getOrderedGoodsIds()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleLbl.frame = CGRect(x: 20, y: view.safeAreaInsets.top+20, width: view.width, height: 20)
        lineView.frame = CGRect(x: 20, y: titleLbl.bottom+10, width: view.width-40, height: 1)
        recipientNameField.frame = CGRect(x: 20, y: lineView.bottom+10, width: view.width-40, height: 40)
        recipientSurnameField.frame = CGRect(x: 20, y: recipientNameField.bottom+10, width: view.width-40, height: 40)
        recipientPhoneField.frame = CGRect(x: 20, y: recipientSurnameField.bottom+10, width: view.width-40, height: 40)
        recipientAddressField.frame = CGRect(x: 20, y: recipientPhoneField.bottom+10, width: view.width-40, height: 40)
        commentTitleLbl.frame = CGRect(x: 20, y: recipientAddressField.bottom+10, width: view.width-40, height: 20)
        commentTextView.frame = CGRect(x: 20, y: commentTitleLbl.bottom+8, width: view.width-40, height: 80)
        totalLbl.frame = CGRect(x: 20, y: commentTextView.bottom+20, width: view.width-40, height: 40)
        explanationLbl.frame = CGRect(x: 20, y: totalLbl.bottom+10, width: view.width-40, height: 40)
        addOrderButton.frame = CGRect(x: 20, y: explanationLbl.bottom+20, width: view.width-40, height: 50)
    }
    
    // MARK: - Add Subviews
    private func addSubviews() {
        view.addSubview(titleLbl)
        view.addSubview(lineView)
        view.addSubview(recipientNameField)
        view.addSubview(recipientSurnameField)
        view.addSubview(recipientPhoneField)
        view.addSubview(recipientAddressField)
        view.addSubview(commentTitleLbl)
        view.addSubview(commentTextView)
        view.addSubview(totalLbl)
        view.addSubview(explanationLbl)
        view.addSubview(addOrderButton)
    }
    
    // MARK: - Congifure nav bar
    private func configureNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor(named: "DarkBrown")
        navigationController?.modalPresentationStyle = .fullScreen
    }
    
    // MARK: - Action
    //the button for: | to Place Order | insert data to orders collection | remove goods from the basket
    // | updated the rating for purchased goods |
    @objc private func didTabAddOrderButton() {
        //data verification
        guard let email = UserDefaults.standard.string(forKey: "email"),
              let recipientName = recipientNameField.text, !recipientName.isEmpty,
              let recipientSurname = recipientSurnameField.text, !recipientSurname.isEmpty,
              let recipientPhone = recipientPhoneField.text, !recipientPhone.isEmpty,
              let recipientAddress = recipientAddressField.text, !recipientAddress.isEmpty,
              let comment = commentTextView.text else {
            // alert
            let alert = UIAlertController(title: "Add Recipient Data",
                                          message: "Please enter a recipient name, surename, phone and address for Place Your Order.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        // insert data to orders collection
        DatabaseManager.shared.insert(orderedGoods: self.idsOrderedGoods, email: email, recipientName: recipientName, recipientSurname: recipientSurname, phone: recipientPhone, address: recipientAddress, comment: comment, totalGoodCost: self.totalCost) { [weak self] added in
            guard added else {
                print("Faield to add Orders")
                return
            }
            DispatchQueue.main.async {
                // Then do: Update the My Orders table
                let vc = OrderSuccessfulVC()
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
                
                // updated the rating for purchased goods
                guard let ids = self?.idsOrderedGoods else {
                    return
                }
                    for id in ids {
                        DatabaseManager.shared.updateRatingOfGood(goodId: id) { updated in
                            //checking for updates
                            guard updated else {
                                return
                            }
                            print("Update Rating Succesful!")
                        }
                    }
                }
            // remove goods from the basket
            guard let ids = self?.idsOrderedGoods else {
                return
            }
            for id in ids {
                DatabaseManager.shared.deleteGoodFromBacket(for: id, email: email) { deleted in
                    guard deleted else {
                        return
                    }
                    print("doog \(id) was deleted after ordered")
                }
            }
        }
    }
    
    // MARK: - Private
    // get total cost for all of products in basket
    private func getTotal() {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        print("getTotal - starting...")
        DatabaseManager.shared.getTotalCost(for: email) { [weak self] total in
            let totalCost = total.reduce(0, +)
            print("totalCost: \(totalCost)")
            DispatchQueue.main.async {
                self?.totalLbl.text = "Total: \(String(describing: totalCost)) $"
                self?.totalCost = totalCost
            }
            print("Total after work get total function: \(String(describing: totalCost))")
        }
    }
    // get all good Ids from basket to save in BD
    private func getOrderedGoodsIds() {
        print("Getting ids in order...")
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        DatabaseManager.shared.getAllOfIdInOrder(for: currentUserEmail) { ids in
            self.idsOrderedGoods = ids
            print("Found \(ids.count) goods")
            print("idsOrderedGoods in Getting ids in order: \(self.idsOrderedGoods)")
        }
    }
}
