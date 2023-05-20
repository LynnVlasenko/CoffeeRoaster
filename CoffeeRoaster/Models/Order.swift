//
//  Order.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 16.05.2023.
//

import Foundation

struct Order {
    let orderId: String
    let goods: [String]
    let recipientName: String
    let recipientSurname: String
    let phone: String
    let address: String
    let comment: String
    let totalGoodCost: Float
    let timestamp: TimeInterval
    
}

struct GoodInBacket {
    let id: String
    let photo: String
    let name: String
    let description: String
    let cost: Float
    let totalGoodCost: Float
    let qty: Double
}
