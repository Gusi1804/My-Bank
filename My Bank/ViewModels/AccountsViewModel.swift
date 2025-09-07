//
//  AccountsViewModel.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import Foundation
import FirebaseFirestore

class AccountsViewModel: Observable {
    var accounts: [MBAccount] = []
    
    init() {
    }
    
    func loadAccounts() {
        let db = Firestore.firestore()
        let query = db.collection("accounts")
        let listener = query.addSnapshotListener { snapshot, error in
            guard let snapshot else {
                print("Error listening for changes: \(error!)")
                return
            }
            for document in snapshot.documents {
                guard let account = try? document.data(as: MBAccount.self) else {
                    return
                }
                
                if let index = self.accounts.firstIndex(where: { $0.id == account.id }) {
                    // account already exists locally, update
                    self.accounts[index].balance = account.balance
                    self.accounts[index].name = account.name
                } else {
                    // new account, add to array
                    self.accounts.append(account)
                }
            }
        }
    }
}
