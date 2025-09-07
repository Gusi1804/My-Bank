//
//  UserViewModel.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserViewModel: Observable {
    var user: MBUser
    
    init(user: MBUser) {
        self.user = user
    }
    
    convenience init(user: User) {
        let user: MBUser = .init(user)
        self.init(user: user)
    }
    
    func signUp(email: String, password: String) async throws -> MBUser {
        let result: AuthDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = MBUser(id: result.user.uid, email: result.user.email!)
        self.user = user
        return user
    }
    
    func signIn(email: String, password: String) async throws -> MBUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = MBUser(id: result.user.uid, email: result.user.email!)
        self.user = user
        return user
    }
}
