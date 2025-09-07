//
//  AccountsViewModel.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class AccountsViewModel: Observable {
    var accounts: [MBAccount] = []
    
    var uid: String? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return user.uid
    }
    private var listenerRegistration: ListenerRegistration?
    
    init() {
    }
    
    func loadAccounts() {
        let db = Firestore.firestore()
        guard let uid else {
            // if we can't get a uid, that means we're not signed in yet...
            print("No user signed in, can't load accounts")
            return
        }
        
        let query = db
            .collection("accounts")
            .whereField("ownerUID", isEqualTo: uid)
        self.listenerRegistration = query.addSnapshotListener { snapshot, error in
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
                    self.accounts[index].ownerUID = account.ownerUID
                } else {
                    // new account, add to array
                    self.accounts.append(account)
                }
            }
        }
    }
}
