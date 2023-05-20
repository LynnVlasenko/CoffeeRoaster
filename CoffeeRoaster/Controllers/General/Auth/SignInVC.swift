//
//  SignInVC.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 12.05.2023.
//

import UIKit

class SignInVC: UITabBarController {
    // MARK: - UI Elements
    // Header View
    private let headerView = SignInHeaderView()
    
    // Email field
    private let emailField: UITextField = {
        let field = UITextField()
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none //щоб не було великих літер у написанні
        field.autocorrectionType = .no//тип автоматичного виправлення електронної пошти
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
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Create Account
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        addSubviews()
        addTargets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height/5)
        emailField.frame = CGRect(x: 20, y: headerView.bottom+30, width: view.width-40, height: 50)
        passwordField.frame = CGRect(x: 20, y: emailField.bottom+10, width: view.width-40, height: 50)
        signInButton.frame = CGRect(x: 20, y: passwordField.bottom+10, width: view.width-40, height: 50)
        createAccountButton.frame = CGRect(x: 20, y: signInButton.bottom+40, width: view.width-40, height:
        50)
    }
    
    // MARK: - Add Subview
    private func addSubviews() {
        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(createAccountButton)
    }
    
    // MARK: - Actions
    private func addTargets() {
        signInButton.addTarget(self, action: #selector (didTapSignIn), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector (didTapCreateAccount), for: .touchUpInside)
    }
    
    // SignIn Action
    @objc func didTapSignIn() {
        //data verification
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            let alert = UIAlertController(title: "Check Login Details",
                                          message: "Please check the correctness of the login and password for Sign In.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        AuthManager.shared.signIn(email: email, password: password) { [weak self] success in
            guard success else {
                return
            }
            DispatchQueue.main.async {
                //data caching
                UserDefaults.standard.set(email, forKey: "email")
                //show Home View
                let vc = TabBarVC()
                vc.modalPresentationStyle = .fullScreen
                self?.present (vc, animated: true)
            }
        }
    }
    
    // CreateAccount Action
    @objc func didTapCreateAccount() {
        let vc = SignUpVC()
        vc.title = "Create Account"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
