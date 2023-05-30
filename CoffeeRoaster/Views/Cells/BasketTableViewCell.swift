//
//  BasketTableViewCell.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 11.05.2023.
//

import UIKit

// delegate for Update Total value
protocol UpdateTotalDelegate {
    func updateTotal()
}

protocol DeleteGoodFromCartDelegate {
    func deleteGoodFromCart(indexPath: IndexPath)
}

class BasketTableViewCell: UITableViewCell {

    // cell identifier
    static let identifier = "BasketTableViewCell"
    
    // Variable with type of Update Total Delegate
    var delegate: UpdateTotalDelegate?
    var delegateForDelete: DeleteGoodFromCartDelegate?
    
    //good id
    var goodId: String?
    //good cost
    var goodCost: Float?

    // MARK: - UI Objects
    // image of good
    private let goodImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "logocoffee")
        img.layer.cornerRadius = 10
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    // name of good
    private let nameLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // total cost of good
    private let totalGoodCostLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // stepper for choosing quantity of goods
    private let qtyOfGoodsStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1 //мінімальне значення для віднімання(decrementing) значення
        stepper.maximumValue = 20 //максимальне значення для додавання(incrementing) значення
        //вказати початкове значення з якого рахувати - відповідне до обраного уже при додаванні в корзинку - тобто значення яке на той час має лейбла(але перевести в Int)
        stepper.stepValue = 1 //крок на який збільшується чи зменшується значення
        stepper.addTarget(self, action: #selector(valueStepperChanged), for: .touchUpInside)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()
    
    // label for the value of the selected quantity of the product
    private let qtyOfGoodsLbl: UILabel = {
        let label = UILabel()
        //label.text = "0"
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // delete good button //робимо змінною і не приватною, для додавання тегу в селі
    var deleteGoodsButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "trash"), for: UIControl.State.normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(didTabDeleteGoodButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        
        addSubviews()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Add subviews
    private func addSubviews() {
        contentView.addSubview(goodImage)
        contentView.addSubview(nameLbl)
        contentView.addSubview(totalGoodCostLbl)
        contentView.addSubview(qtyOfGoodsStepper)
        contentView.addSubview(qtyOfGoodsLbl)
        contentView.addSubview(deleteGoodsButton)
    }
    
    // MARK: - Actions
    //delete good
    @objc private func didTabDeleteGoodButton(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        delegateForDelete?.deleteGoodFromCart(indexPath: indexPath)
    }
    
    //stepper
    @objc func valueStepperChanged() {
        //data verification
        guard let email = UserDefaults.standard.string(forKey: "email"),
              let id = goodId,
              let cost = goodCost else {
            return
        }
        
        qtyOfGoodsLbl.text = "\(String(format: "%.0f", self.qtyOfGoodsStepper.value))"
        totalGoodCostLbl.text = "\(cost * Float(qtyOfGoodsStepper.value)) $"
        
        print("Start update qty and totalGoodCost..")
        //Update database
        DatabaseManager.shared.updateQuantityAndCostGoodsDataInBasket(
            userEmail: email,
            goodId: id,
            qty: qtyOfGoodsStepper.value,
            totalGoodCost: cost * Float(qtyOfGoodsStepper.value)) { [weak self] updated in
            //checking for updates
            guard let strongSelf = self else { return }
            guard updated else {
                return
            }
                DispatchQueue.main.async {
                    strongSelf.delegate?.updateTotal()
                }
        }
    }
    
    //MARK: - Apply constraints
    private func applyConstraints() {
        let goodImageConstraints = [
            goodImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            goodImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            goodImage.widthAnchor.constraint(equalToConstant: 100),
            goodImage.heightAnchor.constraint(equalToConstant: 100)
        ]
        
        let nameLblConstraints = [
            nameLbl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLbl.leadingAnchor.constraint(equalTo: goodImage.trailingAnchor, constant: 20),
            nameLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]
        
        let totalGoodCostLblConstraints = [
            totalGoodCostLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 8),
            totalGoodCostLbl.leadingAnchor.constraint(equalTo: goodImage.trailingAnchor, constant: 20)
        ]
        
        let qtyOfGoodsStepperConstraints = [
            qtyOfGoodsStepper.topAnchor.constraint(equalTo: totalGoodCostLbl.bottomAnchor, constant: 10),
            qtyOfGoodsStepper.leadingAnchor.constraint(equalTo: goodImage.trailingAnchor, constant: 20),
            qtyOfGoodsStepper.widthAnchor.constraint(equalToConstant: 100),
            qtyOfGoodsStepper.heightAnchor.constraint(equalToConstant: 25)
        ]
        
        let qtyOfGoodsLblConstraints = [
            qtyOfGoodsLbl.topAnchor.constraint(equalTo: totalGoodCostLbl.bottomAnchor, constant: 15),
            qtyOfGoodsLbl.leadingAnchor.constraint(equalTo: qtyOfGoodsStepper.trailingAnchor, constant: 30)
        ]
        
        let deleteGoodsButtonConstraints = [
            deleteGoodsButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteGoodsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteGoodsButton.widthAnchor.constraint(equalToConstant: 17),
            deleteGoodsButton.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        NSLayoutConstraint.activate(goodImageConstraints)
        NSLayoutConstraint.activate(nameLblConstraints)
        NSLayoutConstraint.activate(totalGoodCostLblConstraints)
        NSLayoutConstraint.activate(qtyOfGoodsStepperConstraints)
        NSLayoutConstraint.activate(qtyOfGoodsLblConstraints)
        NSLayoutConstraint.activate(deleteGoodsButtonConstraints)
    }
    
    // MARK: - Configure cell
    public func configure(with goodInBasket: GoodInBacket) {
        nameLbl.text = goodInBasket.name
        qtyOfGoodsStepper.value = goodInBasket.qty
        qtyOfGoodsLbl.text = "\(String(format: "%.0f", goodInBasket.qty))"
        totalGoodCostLbl.text = "\(goodInBasket.totalGoodCost) $"
        goodId = goodInBasket.id
        goodCost = goodInBasket.cost
        
        StorageManager.shared.downloadUrlForGood(path: goodInBasket.photo) { url in
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
}
