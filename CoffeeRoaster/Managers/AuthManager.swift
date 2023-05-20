//
//  AuthManager.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 12.05.2023.
//
///The Authentication Manager has 4 responsibilities: sign in, register, sign out, report if the user is currently signed in

import Foundation
import FirebaseAuth

final class AuthManager {
    
    static let shared = AuthManager()
    
    // created auth manager
    private let auth = Auth.auth()
    
    private init() {}

    // MARK: - User is signed in
    // checking if the user is signed in
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    // MARK: - Sign Up
    // user registration handling
    public func signUp(email: String,
                       password: String,
                       completion: @escaping (Bool) -> Void) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }
        
        auth.createUser(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            // Account created
            completion(true)
        }
    }
    
    // MARK: - Sign In
    // handling a registered user's sign in
    public func signIn(email: String,
                       password: String,
                       completion: @escaping (Bool) -> Void) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }

        auth.signIn(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            // User signedIn
            completion(true)
        }
    }
    
    // MARK: - Sign Out
    // account sign out handling
    public func signOut(completion: (Bool) -> Void) {
        do {
            try auth.signOut()
            completion(true)
        }
        catch {
            print(error)
            completion(false)
        }
    }
}
