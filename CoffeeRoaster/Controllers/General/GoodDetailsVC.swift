//
//  DescriptionVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 08.05.2023.
//

import UIKit

class GoodDetailsVC: UIViewController {
    
    // Array for good data
    private var good: Good?
    
    // Variable - if the product is already in the basket
    private var isEqualGoodId = false
    
    // MARK: - UI Objects
    // image of good
    private let goodImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "logocoffee")
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    // name of good
    private let nameLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // description of good
    private let descriptionLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .thin)
        label.numberOfLines = 10
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // cost of good
    private let costLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // stepper for choosing quantity of goods
    private let qtyOfGoodsStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 20
        stepper.stepValue = 1
        stepper.addTarget(self, action: #selector(valueStepperChanged), for: .touchUpInside)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    // label for the value of the selected quantity of the product
    private let qtyOfGoodsLbl: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // the button that adds the product to the basket
    private let addGoodToBasketButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add to Cart", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "LightBrown")
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(didTabAddGoodButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviews()
        applyConstraints()
        renderGood()
        checkIsEqualGoodId()
    }
    
    // MARK: - addSubviews
    private func addSubviews() {
        view.addSubview(goodImage)
        view.addSubview(nameLbl)
        view.addSubview(descriptionLbl)
        view.addSubview(costLbl)
        view.addSubview(qtyOfGoodsStepper)
        view.addSubview(qtyOfGoodsLbl)
        view.addSubview(addGoodToBasketButton)
    }
    
    // MARK: - Actions
    // adds the product to the basket
    @objc func didTabAddGoodButton() {
        // Verification of required data
        guard let qty = qtyOfGoodsLbl.text,
              let email = UserDefaults.standard.string(forKey: "email"),
              qty != "0" else {
            
            let alert = UIAlertController(title: "Add Quantity of Products",
                                          message: "Please enter a quantity of products to continue.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        print("Second Guard..")
        
        // Checking if the product is already in the basket
        guard isEqualGoodId == false else {
            let alert = UIAlertController(title: "This product is in the cart",
                                          message: "You can change the quantity of the selected product in the Cart.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        print("Starting.. good Adding To Basket")
        
        // Verification of required data
        guard let good = good,
              let photo = good.photo else {
            return
        }

        // Create a product model
        let goodInBasket = GoodInBacket(
            id: good.id,
            photo: photo,
            name: good.name,
            description: good.description,
            cost: good.cost,
            totalGoodCost: good.cost * (Float(qty) ?? 0.0),
            qty: Double(qty) ?? 0.0
        )

        // insert the product to the database in the basket coolection
        DatabaseManager.shared.insert(goodsInBasket: goodInBasket, email: email) { [weak self] added in
            guard added else {
                print("Faield to add new good in Basket")
                return
            }
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    // stepper
    @objc func valueStepperChanged() {
        print("Stepper clicked. Velue = \(qtyOfGoodsStepper.value)")
        qtyOfGoodsLbl.text = "\(String(format: "%.0f", self.qtyOfGoodsStepper.value))"
    }
    
    // MARK: - Private
    // get data for good array
    func renderGood() {
        guard let good = good else { return }
        
        nameLbl.text = good.name
        descriptionLbl.text = good.description
        costLbl.text = "\(good.cost) $"
        
        guard let photo = good.photo else {
            return
        }
        // download image
        StorageManager.shared.downloadUrlForGood(path: photo) { url in
            guard let url = url else {
                return
            }
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    self.goodImage.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
    
    // set data to good array
    func setGood(good: Good?) {
        self.good = good
    }
    
    // checking if the product is already in the basket
    private func checkIsEqualGoodId() {
        guard let currentGoodId = good?.id,
              let email = UserDefaults.standard.string(forKey: "email") else { return }
        print("It is current id \(currentGoodId)")

        DatabaseManager.shared.getBasketGoods(for: email) { goods in
            let ids = goods.map { $0.id }
            for id in ids {
                print(id)
                if id == currentGoodId {
                    self.isEqualGoodId = true
                    print("In Cicle: \(self.isEqualGoodId)")
                    return
                }
            }
        }
    }
    
    //MARK: - Constraints
    private func applyConstraints() {
        let goodImageConstraints = [
            goodImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goodImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            goodImage.widthAnchor.constraint(equalToConstant: view.frame.width),
            goodImage.heightAnchor.constraint(equalToConstant: 200)
            
        ]
        
        let nameLblConstraints = [
            nameLbl.topAnchor.constraint(equalTo: goodImage.bottomAnchor, constant: 15),
            nameLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ]
        
        let descriptionLblConstraints = [
            descriptionLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 15),
            descriptionLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLbl.widthAnchor.constraint(equalToConstant: view.frame.width - 10),
            descriptionLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ]
        
        let costLblConstraints = [
            costLbl.topAnchor.constraint(equalTo: descriptionLbl.bottomAnchor, constant: 15),
            costLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ]
        
        let qtyOfGoodsStepperConstraints = [
            qtyOfGoodsStepper.topAnchor.constraint(equalTo: costLbl.bottomAnchor, constant: 15),
            qtyOfGoodsStepper.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            qtyOfGoodsStepper.widthAnchor.constraint(equalToConstant: 100),
            qtyOfGoodsStepper.heightAnchor.constraint(equalToConstant: 25)
        ]
        
        let qtyOfGoodsLblConstraints = [
            qtyOfGoodsLbl.topAnchor.constraint(equalTo: costLbl.bottomAnchor, constant: 20),
            qtyOfGoodsLbl.leadingAnchor.constraint(equalTo: qtyOfGoodsStepper.trailingAnchor, constant: 30)
        ]
        
        let addGoodToBasketButtonConstraints = [
            addGoodToBasketButton.topAnchor.constraint(equalTo: qtyOfGoodsStepper.bottomAnchor, constant: 40),
            addGoodToBasketButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addGoodToBasketButton.widthAnchor.constraint(equalToConstant: 250),
            addGoodToBasketButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(goodImageConstraints)
        NSLayoutConstraint.activate(nameLblConstraints)
        NSLayoutConstraint.activate(descriptionLblConstraints)
        NSLayoutConstraint.activate(costLblConstraints)
        NSLayoutConstraint.activate(qtyOfGoodsStepperConstraints)
        NSLayoutConstraint.activate(qtyOfGoodsLblConstraints)
        NSLayoutConstraint.activate(addGoodToBasketButtonConstraints)
    }
}
