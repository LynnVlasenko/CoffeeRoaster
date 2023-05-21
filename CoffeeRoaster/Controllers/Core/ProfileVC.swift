//
//  ProfileVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 08.05.2023.
//

import UIKit

class ProfileVC: UIViewController {
    
    // Variable for current user email
    let currentEmail: String
    
    // Array of Profile items in table
    private let items = ["My Orders", "Settings"]
    
    // MARK: - UI Objects
    // List of item
    private let profileTable: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // Header
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "LightBrown")
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        return view
    }()
   
    // Full Name
    private let fullNameLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Email
    private let emailLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Button for edit user data
    private let editButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "square.and.pencil.circle.fill"),
                                  for: UIControl.State.normal)
        button.tintColor = UIColor(named: "DarkBrown")
        button.addTarget(self, action: #selector(didTabEdit), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - init and override
    //initialize with the current email
    init(currentEmail: String) {
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        emailLbl.text = currentEmail
        addSubviews()
        applyConstraints()
        // table delegates
        applyDelegates()
        // set up sing out button
        setUpSignOutButton()
        // get user data and configure fields with User Data
        fetchProfileData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5)
        profileTable.frame = view.bounds
    }

    // MARK: - Add Subviews
    private func addSubviews() {
        view.addSubview(profileTable)
        profileTable.tableHeaderView = headerView
        headerView.addSubview(fullNameLbl)
        headerView.addSubview(emailLbl)
        headerView.addSubview(editButton)
    }
    
    // MARK: - Actions
    @objc private func didTabEdit() {
        print("Opened Edit View")
        let vc = EditProfileVC(currentEmail: currentEmail)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Sign Out Button
    private func setUpSignOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sign Out",
            style: .done,
            target: self,
            action: #selector(didTabSignOut))
    }
    
    @objc private func didTabSignOut() {
        //alert to confirm sign out
        let sheet = UIAlertController(title: "Sign Out",
                                      message: "Are you sure you'd like to sign out?",
                                      preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthManager.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        //data cache reset
                        UserDefaults.standard.set(nil, forKey: "email")
                        UserDefaults.standard.set(nil, forKey: "name")
                        UserDefaults.standard.set(nil, forKey: "surename")
                        UserDefaults.standard.set(false, forKey: "flag")
                        
                        //show SignIn View
                        let signInVC = SignInVC()
                        signInVC.navigationItem.largeTitleDisplayMode = .always
                        
                        let navVC = UINavigationController(rootViewController: signInVC)
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true, completion: nil)
                    }
                }
            }
        }))
        present(sheet, animated: true)
    }
    
    // MARK: - Private
    // configure fields with User Data
    private func setUpProfileData(
        name: String? = nil,
        surename: String? = nil
    ) {
        if let name = name,
           let surename = surename {
            fullNameLbl.text = "\(name) \(surename)"
        }
    }
    // get user data and configure fields with User Data
    private func fetchProfileData() {
        DatabaseManager.shared.getUser(email: currentEmail) { [weak self] user in
            guard let user = user else {
                return
            }
            DispatchQueue.main.async {
                self?.setUpProfileData(name: user.name, surename: user.surename)
            }
        }
    }
    
    //MARK: - Apply constraints
    private func applyConstraints() {
        let fullNameLblConstraints = [
            fullNameLbl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 100),
            fullNameLbl.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ]
        
        let emailLblConstraints = [
            emailLbl.topAnchor.constraint(equalTo: fullNameLbl.bottomAnchor, constant: 20),
            emailLbl.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ]
        
        let editButtonConstraints = [
            editButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            editButton.widthAnchor.constraint(equalToConstant: 30),
            editButton.heightAnchor.constraint(equalToConstant: 30)
        ]
        
        NSLayoutConstraint.activate(fullNameLblConstraints)
        NSLayoutConstraint.activate(emailLblConstraints)
        NSLayoutConstraint.activate(editButtonConstraints)
    }
}

// MARK: - Extension for Table
extension ProfileVC: UITableViewDataSource, UITableViewDelegate {

    private func applyDelegates() {
        profileTable.delegate = self
        profileTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let vc1 = MyOrdersVC()
            navigationController?.pushViewController(vc1, animated: true)
        } else if indexPath.row == 1 {
            let vc2 = SettingsVC()
            navigationController?.pushViewController(vc2, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - Extension for SetEditedUserDataDelegate
extension ProfileVC: SetEditedUserDataDelegate {
    //delegate for Set & Update Edited User Data in EditProfileVC
    func updateEditedUserData() {
        fetchProfileData()
    }
}
