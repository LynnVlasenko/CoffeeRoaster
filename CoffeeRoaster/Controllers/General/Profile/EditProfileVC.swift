//
//  EditProfileVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 15.05.2023.
//

import UIKit

//delegate for Set & Update Edited User Data
protocol SetEditedUserDataDelegate {
    func updateEditedUserData()
}

class EditProfileVC: UIViewController {
    
    // Variable for current user email
    let currentEmail: String
    
    // Variable with type of Set Edited User Data Delegate
    var delegate: SetEditedUserDataDelegate?
    
    // MARK: - UI Objects
    // Name field
    private let nameField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Name"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    // Surename field
    private let surenameField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Surename"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    // MARK: - init and override
    init(currentEmail: String) {
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Your Data"
        view.backgroundColor = .systemBackground
        addSubviews()
        // set up button for save edited user data
        setUpSaveButton()
        // get user data and configure fields with User Data
        fetchProfileData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameField.frame = CGRect(x: 20, y: view.safeAreaInsets.top, width: view.width-40, height: 50)
        surenameField.frame = CGRect(x: 20, y: nameField.bottom+10, width: view.width-40, height: 50)
    }
    
    // MARK: - Add Subviews
    private func addSubviews() {
        view.addSubview(nameField)
        view.addSubview(surenameField)
    }
    
    // MARK: - Actions
    // save edited user data
    @objc func didTabSave() {
        //data verification
        guard let name = nameField.text, !name.isEmpty,
              let surename = surenameField.text, !surename.isEmpty else {
            let alert = UIAlertController(title: "Add Personal Data",
                                          message: "Please enter a name and surename for Save Personal Data.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        //Update database
        DatabaseManager.shared.updateProfileData(email: currentEmail,
                                                 name: name,
                                                 surename: surename) { [weak self] updated in
            guard let strongSelf = self else { return }
            //checking for updates
            guard updated else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.fetchProfileData()
                strongSelf.delegate?.updateEditedUserData()
                self?.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    // MARK: - Private
    private func setUpSaveButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(didTabSave))
    }
    
    // MARK: - Fetch and SetUp User Data
    // configure fields with User Data
    private func setUpProfileData(
        name: String? = nil,
        surename: String? = nil
    ) {
        if let name = name,
           let surename = surename {
            nameField.text = name
            surenameField.text = surename
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
}
