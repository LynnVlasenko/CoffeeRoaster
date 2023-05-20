//
//  SettingsVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 15.05.2023.
//

import UIKit

class SettingsVC: UIViewController {
    // MARK: - UI Objects
    let settingsTable: UITableView = {
        let table = UITableView()
        table.register(SettingTableViewCell.self,
                       forCellReuseIdentifier: SettingTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        view.addSubview(settingsTable)
        applyDelegates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        settingsTable.frame = view.bounds
    }
    
    // MARK: - Congifure nav bar
    private func configureNavBar() {
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor(named: "DarkBrown")
   }
}

// MARK: - Extension for Table
extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    
    private func applyDelegates() {
        settingsTable.delegate = self
        settingsTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingTableViewCell.identifier,
            for: indexPath) as? SettingTableViewCell else { return UITableViewCell()}
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
