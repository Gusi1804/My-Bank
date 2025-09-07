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
    
    init(_ accounts: [MBAccount] = []) {
        self.accounts = accounts
    }
    
    func loadAccounts(onUpdate: @escaping ([MBAccount]) -> Void) {
        print("Loading accounts...")
        let db = Firestore.firestore()
        guard let uid else {
            // if we can't get a uid, that means we're not signed in yet...
            print("No user signed in, can't load accounts")
            return
        }
        
        // create query to match all accounts owned by current user
        let query = db
            .collection("accounts")
            .whereField("ownerUID", isEqualTo: uid)
        
        // create listener to update balances in real time
        self.listenerRegistration = query.addSnapshotListener { snapshot, error in
            guard let snapshot else {
                print("Error listening for changes: \(error!)")
                return
            }
            print("Matching accounts: \(snapshot.documents.count)")
            for document in snapshot.documents {
                guard let account = try? document.data(as: MBAccount.self) else {
                    print("Error decoding account document: \(document.data())")
                    return
                }
                
                if let index = self.accounts.firstIndex(where: { $0.id == account.id }) {
                    print("Account \(account.id) already exists locally, updating")
                    // account already exists locally, update
                    self.accounts[index].balance = account.balance
                    self.accounts[index].name = account.name
                    self.accounts[index].ownerUID = account.ownerUID
                } else {
                    print("New account \(account.id)")
                    // new account, add to array
                    self.accounts.append(account)
                }
            }
            
            print(self.accounts)
            onUpdate(self.accounts)
        }
    }
    
    func createAccount(_ account: MBAccount) async throws {
        let db = Firestore.firestore()
        try db.collection("accounts").addDocument(from: account)
    }
}
