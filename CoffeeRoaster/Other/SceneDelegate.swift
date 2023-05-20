//
//  SceneDelegate.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 08.05.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // TODO: Update VC to sign in VC if not signed in
        let vc: UIViewController
        if AuthManager.shared.isSignedIn {
            vc = TabBarVC()
        } else {
            let signInVC = SignInVC()
            signInVC.navigationItem.largeTitleDisplayMode = .always
            let navVC = UINavigationController(rootViewController: signInVC)
            navVC.navigationBar.prefersLargeTitles = true
            vc = navVC
        }
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window
    }
}

