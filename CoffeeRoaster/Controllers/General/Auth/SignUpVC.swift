//
//  SignInVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 12.05.2023.
//

import UIKit

class SignUpVC: UITabBarController {
    // MARK: - UI Elements
    // Header View
    private let headerView = SignInHeaderView()
    
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
    
    // Email field
    private let emailField: UITextField = {
        let field = UITextField()
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none //щоб не було великих літер у написанні
        field.autocorrectionType = .no//тип автоматисного виправлення електронної пошти
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Email Address"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    // Password field
    private let passwordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.autocapitalizationType = .none //щоб не було великих літер у написанні
        field.autocorrectionType = .no//тип автоматисного виправлення електронної пошти
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Password"
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 8
        field.layer.masksToBounds = true
        return field
    }()
    
    // Sign In button
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .systemBackground
        addSubviews()
        signUpButton.addTarget(self, action: #selector (didTapSignUp), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height/5)
        nameField.frame = CGRect(x: 20, y: headerView.bottom+30, width: view.width-40, height: 50)
        surenameField.frame = CGRect(x: 20, y: nameField.bottom+10, width: view.width-40, height: 50)
        emailField.frame = CGRect(x: 20, y: surenameField.bottom+10 , width: view.width-40, height: 50)
        passwordField.frame = CGRect(x: 20, y: emailField.bottom+10, width: view.width-40, height: 50)
        signUpButton.frame = CGRect(x: 20, y: passwordField.bottom+10, width: view.width-40, height: 50)
    }
    
    // MARK: - Add Subview
    private func addSubviews() {
        view.addSubview(headerView)
        view.addSubview(nameField)
        view.addSubview(surenameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
    }
    
    // MARK: - Actions
    @objc func didTapSignUp() {
        //data verification
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let name = nameField.text, !name.isEmpty,
              let surename = surenameField.text, !surename.isEmpty else {
            let alert = UIAlertController(title: "Add Your Data",
                                          message: "Please enter your name, surename, email and password for Sign Up.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        //Create User
        AuthManager.shared.signUp(email: email, password: password) { [weak self] success in
            if success {
                //Update Database
                let newUser = User(name: name, surename: surename, email: email)
                DatabaseManager.shared.insert(user: newUser) { inserted in
                    guard inserted else {
                        return
                    }
                    //data caching
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(name, forKey: "name")
                    UserDefaults.standard.set(surename, forKey: "surename")
                    
                    DispatchQueue.main.async {
                        //show Home View
                        let vc = TabBarVC()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true)
                    }
                }
            } else {
                print ("Failed to create account")
            }
        }
    }
}
