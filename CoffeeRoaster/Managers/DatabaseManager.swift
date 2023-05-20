//
//  DatabaseManager.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 12.05.2023.
//
/// The Database Manager has 14 responsibilities:
/// For Users: | 1: insert user data to the database users collection,
            /// 2: get user data from the database users collection,
            /// 3: updates user data in user collection
/// For Goods: | 4: get all goods from database goods collection,
            /// 5: get good from database goods collection by ID,
            /// 6: updates good rating data in goods collection
/// For Basket: | 7: insert good data to the user's basket collection,
            /// 8: get all goods from user's basket collection,
            /// 9: delete all goods from user's basket collection,
            /// 10: updates goods quantity and cost in user's basket collection,
            /// 11: gets total cost of all goods from user's basket collection,
            /// 12: gets all of IDs from user's basket collection,
/// For Order: | 13: insert goods data to the user's orders collection,
            /// 14: (not writed yet!) gets user order from user's orders collection

import Foundation
import FirebaseFirestore
import UIKit

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    //created database
    private let database = Firestore.firestore()
    
    private init() {}
    
    // MARK: - User
    //1 Func: insert user data to the database users collection
    public func insert(
        user: User,
        completion: @escaping (Bool) -> Void
    ){
        // email as an identifier
        let documentId = user.email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        // pass the keys and values ​​to create a record in the database
        let data = ["email": user.email, "name": user.name, "surename": user.surename]
        
        // create a "users" collection
        // add the document id
        // set data
        database
            .collection("users")
            .document(documentId)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    
    //2 Func: get user data from the database users collection
    public func getUser(email: String, completion: @escaping (User?) -> Void) {
        // email as an identifier
        let documentId = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        // get user data from DB
        database
            .collection("users")
            .document(documentId)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data() as? [String: String],
                      let name = data["name"],
                      let surename = data["surename"],
                      error == nil else {
                    return
                }
                
                // set the data to User model
                let user = User(name: name, surename: surename, email: email)
                completion(user)
            }
    }
    
    //3 Func: updates user data in user collection
    func updateProfileData (
        email: String,
        name: String,
        surename: String,
        completion: @escaping (Bool) -> Void
    ) {
        // email as an identifier
        let path = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        // assign new data
        let newName = name
        let newSurname = surename
        
        // create a link to the users document
        let dbRef = database
            .collection ("users")
            .document(path)
        
        // get document
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {
                return
            }
            // update user data
            data["name"] = newName
            data["surename"] = newSurname
            
            // set new user data to database
            dbRef.setData (data) { error in
                completion(error == nil)
            }
        }
    }
    
    // MARK: - Goods
    //4 Func: get all goods from database goods collection
    public func getAllGoods(
        completion: @escaping ([Good]) -> Void
    ){
        // get goods data from DB
        database
            .collection("goods")
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                      error == nil else {
                    return
                }
                
                // get all good ids
                let ids: [String] = documents.compactMap({ $0["id"] as? String })
                print(ids)
                
                // check that the array is not empty
                guard !ids.isEmpty else {
                    completion([])
                    return
                }
                // create a dispatch group for grouping multiple asynchronous operations
                let group = DispatchGroup()
                // array to get the results
                var result: [Good] = []
                
                //go through all IDs and add products to the array
                for id in ids {
                    group.enter()
                    self?.getGood(id: id) { good in
                        defer {
                            group.leave()
                        }
                        result.append(good)
                    }
                }
                //the dispatch group informed us that it was successfully passed and received
                group.notify(queue: .global()) {
                    print("Feed posts: \(result.count)")
                    completion(result)
                }
            }
    }
    
    //5 Func: get good from database goods collection by ID
    public func getGood (
        id: String,
        completion: @escaping (Good) -> Void
    ){
        // id as an identifier
        let goodId = id
        
        //get good data from DB
        database
            .collection("goods")
            .document(goodId)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data() as? [String: Any?],
                      let id = data["id"] as? String,
                      let name = data["name"] as? String,
                      let description = data["description"] as? String,
                      let cost = data["cost"] as? Float,
                      let photo = data["photo"] as? String,
                      let rating = data["rating"] as? Int,
                      let type = data["type"] as? String,
                      error == nil else {
                    return
                }
                //set good data to Good model
                let good = Good(id: id,
                                photo: photo,
                                name: name,
                                description: description,
                                cost: cost,
                                rating: rating,
                                type: type)
                completion(good)
            }
    }
    
    // MARK: - Rating of Good
    //6 Func: updates good rating data in goods collection
    func updateRatingOfGood (
        goodId: String,
        completion: @escaping (Bool) -> Void
    ) {
        // create a link to the goods document
        let dbRef = database
            .collection("goods")
            .document(goodId)
        print("dbRef: \(dbRef)")
        
        // get document
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {
                return
            }
            let rating = data["rating"] as? Int
            
            guard let currentRating = rating else {
                return
            }
            // update rating data
            data["rating"] = currentRating + 1
            // set new rating data to the DB
            dbRef.setData (data) { error in
                completion(error == nil)
            }
        }
    }
    
    // MARK: - Basket
    //7 Func: insert good data to the user's basket collection
    public func insert(
        goodsInBasket: GoodInBacket,
        email: String,
        completion: @escaping (Bool) -> Void
    ){
        // email as an identifier
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        // pass the keys and values ​​to create a record in the database
        let data: [String: Any] = [
            "id": goodsInBasket.id,
            "name": goodsInBasket.name,
            "description": goodsInBasket.description,
            "photo": goodsInBasket.photo,
            "cost": goodsInBasket.cost,
            "totalGoodCost": goodsInBasket.totalGoodCost,
            "qty": goodsInBasket.qty
        ]
        
        // set good data to DB to user basket collection
        database
            .collection("users")
            .document(userEmail)
            .collection("basket")
            .document(goodsInBasket.id)
            .setData(data) { error in
                completion(error == nil)
            }
    }
    
    //8 Func: get all goods from user's basket collection
    public func getBasketGoods(
        for email: String,
        completion: @escaping ([GoodInBacket]) -> Void
    ){
        // email as an identifier
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        // get goods data
        database
            .collection("users")
            .document(userEmail)
            .collection("basket")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                error == nil else {
                    return
                }
                
                let goodsInBasket: [GoodInBacket] = documents.compactMap({ dictionary in
                    guard let id = dictionary["id"] as? String,
                          let name = dictionary["name"] as? String,
                          let description = dictionary["description"] as? String,
                          let cost = dictionary["cost"] as? Float,
                          let totalGoodCost = dictionary["totalGoodCost"] as? Float,
                          let photo = dictionary["photo"] as? String,
                          let qty = dictionary["qty"] as? Double else {
                        print("Invalid post fetch conersion")
                        return nil
                    }
                    // set goods data to Basket model
                    let goodInBasket = GoodInBacket(id: id,
                                                    photo: photo,
                                                    name: name,
                                                    description: description,
                                                    cost: cost,
                                                    totalGoodCost: totalGoodCost,
                                                    qty: qty)
                    return goodInBasket
                })
                // result - array of goods from user basket
                completion(goodsInBasket)
            }
    }
    
    //9 Func: delete all goods from user's basket collection
    public func deleteGoodFromBacket (
        for id: String,
        email: String,
        completion: @escaping (Bool) -> Void
    ){
        // id as an identifier
        let goodinBasketId = id
        // email as an identifier
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
    
        // delete goods from user basket
        database
            .collection("users")
            .document(userEmail)
            .collection("basket")
            .document(goodinBasketId)
            .delete { error in
                if let error = error {
                        print("Error removing document: \(error)")
                    } else {
                        print("Document \(goodinBasketId) successfully removed!")
                    }
            }
    }
    
    // MARK: - Quantity and cost in Basket
    //10 Func: updates goods quantity and cost in user's basket collection
    func updateQuantityAndCostGoodsDataInBasket (
        userEmail: String,
        goodId: String,
        qty: Double,
        totalGoodCost: Float,
        completion: @escaping (Bool) -> Void
    ) {
        // email as an identifier
        let path = userEmail
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        // assign new data
        let newQty = qty
        let newTotalGoodCost = totalGoodCost
        
        // create a link to the user basket document
        let dbRef = database
            .collection ("users")
            .document(path)
            .collection("basket")
            .document(goodId)
        print("dbRef: \(dbRef)")
        
        // get document
        dbRef.getDocument { snapshot, error in
            guard var data = snapshot?.data(), error == nil else {
                return
            }
            // update data
            data["qty"] = newQty
            data["totalGoodCost"] = newTotalGoodCost
            
            // set data
            dbRef.setData (data) { error in
                completion(error == nil)
            }
        }
    }
    
    //11 Func: gets total cost of all goods from user's basket collection
    public func getTotalCost(
        for email: String,
        completion: @escaping ([Float]) -> Void
    ){
        // email as an identifier
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        // get data from user basket
        database
            .collection("users")
            .document(userEmail)
            .collection("basket")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                error == nil else {
                    return
                }
                
                let total: [Float] = documents.compactMap({ dictionary in
                    guard let totalGoodCost = dictionary["totalGoodCost"] as? Float else {
                        print("Invalid goods fetch conersion")
                        return nil
                    }
                    
                    let goodCost = totalGoodCost
                    return goodCost
                })
                // returns array with costs of each good in user baskrt
                completion(total)
            }
    }
    
    //12 Func: gets all of Ids from user's basket collection
    public func getAllOfIdInOrder(
        for email: String,
        completion: @escaping ([String]) -> Void
    ){
        // email as an identifier
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        // get data
        database
            .collection("users")
            .document(userEmail)
            .collection("basket")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents.compactMap({ $0.data() }),
                error == nil else {
                    return
                }
                let allId: [String] = documents.compactMap({ dictionary in
                    guard let idInOrder = dictionary["id"] as? String else {
                        print("Invalid goods fetch conersion")
                        return nil
                    }
                    
                    let goodId = idInOrder
                    return goodId
                })
                // returns an array of all Ids from the user's basket collection
                completion(allId)
            }
    }
    
    // MARK: - Orders
    //13 Func: insert goods data to the user's orders collection
    public func insert(
        orderedGoods: [String],
        email: String,
        recipientName: String,
        recipientSurname: String,
        phone: String,
        address: String,
        comment: String,
        totalGoodCost: Float,
        completion: @escaping (Bool) -> Void
    ){
        // email as an identifier
        let userEmail = email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
        
        // dates for id and timestamp
        let ordedId = UUID().uuidString
        let timestamp = Date()
        
        // pass the keys and values ​​to create a record in the database
        let data: [String: Any] = [
            "id": ordedId,
            "orderedGoods": orderedGoods,
            "recipientName": recipientName,
            "recipientSurname": recipientSurname,
            "phone": phone,
            "address": address,
            "comment": comment,
            "totalGoodCost": totalGoodCost,
            "created": timestamp
        ]
        // set order data
        database
            .collection("users")
            .document(userEmail)
            .collection("orders")
            .document(ordedId)
            .setData(data) { error in
                completion(error == nil)
            }
    }

    //14 Func: gets user order from user's orders collection
    public func getUserOrder(
        for email: String,
        completion: @escaping (Order) -> Void
    ){
        // email as an identifier
    }
}
