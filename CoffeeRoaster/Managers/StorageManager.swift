//
//  StorageManager.swift
//  CoffeeShop
//
//  Created by Алина Власенко on 12.05.2023.
//
///The Storage Manager has 1 responsibilities: - download url for good

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    
    static let shared = StorageManager()
    
    //created container
    private let container = Storage.storage()
    
    private init() {}
    
    // Func: - download url for good
    public func downloadUrlForGood(
        path: String,
        completion: @escaping (URL?) -> Void
    ){
        container.reference(withPath: path)
            .downloadURL { url, _ in
                completion(url)
            }
    }
}


