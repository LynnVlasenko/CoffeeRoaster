//
//  BasketVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 08.05.2023.
//

import UIKit

class BasketVC: UIViewController {
    
    // Array for goods in basket data
    private var addedGoods: [GoodInBacket] = []
    
    // MARK: - UI Objects
    // No Added Goods Lbl
    private let noAddedGoodsLbl: UILabel = {
        let label = UILabel()
        label.text = "You haven't added products"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 27, weight: .light)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // Added Goods Table
    private let addedGoodsTable: UITableView = {
        let table = UITableView()
        table.register(BasketTableViewCell.self, forCellReuseIdentifier: BasketTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    // Total cost Lbl
    private let totalLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // the button to start placing an order
    private let toOrderButton: UIButton = {
        let button = UIButton()
        button.setTitle("To Order", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "LightBrown")
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(didTabToOrderButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubview()
        // table delegates
        applyDelegates()
        // get goods in basket for reload table
        fetchGoodFromBasket()
        // get total cost for all of products in basket
        getTotal()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addedGoodsTable.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height/1.8)
        totalLbl.frame = CGRect(x: 20, y: addedGoodsTable.bottom, width: view.width-20, height: 50)
        toOrderButton.frame = CGRect(x: 20, y: totalLbl.bottom+10, width: view.width-40, height: 50)
        noAddedGoodsLbl.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // get goods in basket for reload table when view Will Appear
        fetchGoodFromBasket()
        // get total cost for all of products in basket when view Will Appear
        getTotal()
    }
    
    // MARK: - Add Subviews
    private func addSubview() {
        view.addSubview(addedGoodsTable)
        view.addSubview(totalLbl)
        view.addSubview(toOrderButton)
        view.addSubview(noAddedGoodsLbl)
    }
    
    // MARK: - Actions
    @objc private func didTabToOrderButton() {
        let vc = OrderVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private
    
    // get goods in basket for reload table
    private func fetchGoodFromBasket() {
        print("Fetching googs in basket...")
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        DatabaseManager.shared.getBasketGoods(for: currentUserEmail) { [weak self] goods in
            self?.addedGoods = goods
            print("Found \(goods.count) goods")
            DispatchQueue.main.async {
                self?.addedGoodsTable.reloadData()
            }
        }
    }
    
    // configure totalLbl with total Data
    private func setUpTotalData(
        total: Float? = nil
    ) {
        if let total = total {
            totalLbl.text = "Total: \(total) $"
        }
    }
    
    // get total cost for all of products in basket
    private func getTotal() {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return
        }
        DatabaseManager.shared.getTotalCost(for: email) { [weak self] total in
            let totalCost = total.reduce(0, +)
            
            DispatchQueue.main.async {
                self?.setUpTotalData(total: totalCost)
                print("I'm in Backet getTotal")
            }
        }
    }
}

// MARK: - Extension for Table
extension BasketVC: UITableViewDataSource, UITableViewDelegate {
    
    private func applyDelegates() {
        addedGoodsTable.delegate = self
        addedGoodsTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // change view when basket is empty
        if addedGoods.count == 0 {
            addedGoodsTable.isHidden = true
            totalLbl.isHidden = true
            toOrderButton.isHidden = true
            noAddedGoodsLbl.isHidden = false
        } else {
            addedGoodsTable.isHidden = false
            totalLbl.isHidden = false
            toOrderButton.isHidden = false
            noAddedGoodsLbl.isHidden = true
        }
        return addedGoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BasketTableViewCell.identifier,
            for: indexPath) as? BasketTableViewCell else { return UITableViewCell()}
        let model = addedGoods[indexPath.row]
        cell.configure(with: model)
        cell.deleteGoodsButton.tag = indexPath.row
        cell.delegate = self
        cell.delegateForDelete = self
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // delete row in basket
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let email = UserDefaults.standard.string(forKey: "email") else {
                return
            }
            let id = addedGoods[indexPath.row].id
    
            // delete data from DB
            DatabaseManager.shared.deleteGoodFromBacket(for: id, email: email) { deleted in
                guard deleted else {
                    return
                }
                print("The good \(id) was deleted")
            }
            // delete data from array
            self.addedGoods.remove(at: indexPath.row)
            
            // delete row
            tableView.deleteRows(at: [indexPath], with: .fade)
            // reload total
            self.getTotal()
        }
    }
}

// MARK: - Extension for UpdateTotalDelegate
extension BasketVC: UpdateTotalDelegate {
   // updateTotal when changed qty of goods in basket
    func updateTotal() {
        getTotal()
    }
}

extension BasketVC: DeleteGoodFromCartDelegate {
//    func deleteGoodFromCart() {
//        fetchGoodFromBasket()
//        getTotal()
//    }
    func deleteGoodFromCart(indexPath: IndexPath) {
        print ("DELETE DELEGATION" )
        
        let alert = UIAlertController(title: "Delete", message: "Are sure to delete?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "YES", style: .destructive) { _ in
            self.addedGoodsTable.dataSource?.tableView?(self.addedGoodsTable, commit: .delete, forRowAt: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
                                      
}
