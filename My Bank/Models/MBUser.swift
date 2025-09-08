//
//  MBUser.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import Foundation
import FirebaseAuth

/// Represents a user in the My Bank application
struct MBUser: Codable {
    let id: String
    let email: String
    
    init(id: String, email: String) {
        self.id = id
        self.email = email
    }
    
    init(_ firebaseAuthUser: User) {
        self.id = firebaseAuthUser.uid
        self.email = firebaseAuthUser.email ?? ""
    }
    
    var isEmpty: Bool {
        id.isEmpty && email.isEmpty
    }
    
    static let empty: MBUser = .init(id: "", email: "")
}
