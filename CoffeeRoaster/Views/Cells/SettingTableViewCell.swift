//
//  SettingTableViewCell.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 15.05.2023.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    static let identifier = "SettingTableViewCell"
    
    // MARK: - UI Objects
    private let setTitleLbl: UILabel = {
        let label = UILabel()
        label.text = "Dark theme"
        label.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let darkSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(didChangeSwitch), for: .allTouchEvents)
        toggle.isOn = false
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        darkSwitch.setOn(UserDefaults.standard.bool(forKey: "flag"), animated: true)
        addSubviews()
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Add subviews
    private func addSubviews() {
        contentView.addSubview(setTitleLbl)
        contentView.addSubview(darkSwitch)
    }

    @objc private func didChangeSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "flag")
        if darkSwitch.isOn {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .dark
            print("dark")
        } else {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .light
            print("white")
        }
    }
    
    // MARK: - Apply constraints
    private func applyConstraints() {
        let setTitleLblConstraints = [
            setTitleLbl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            setTitleLbl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            setTitleLbl.widthAnchor.constraint(equalToConstant: contentView.frame.width/2),
            setTitleLbl.heightAnchor.constraint(equalToConstant: 70)
        ]
        
        let darkSwitchConstraints = [
            darkSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            darkSwitch.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(setTitleLblConstraints)
        NSLayoutConstraint.activate(darkSwitchConstraints)
    }
}
