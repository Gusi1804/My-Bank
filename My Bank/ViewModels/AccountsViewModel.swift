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
    var transactions: [String: [MBTransaction]] = [:]
    
    var uid: String? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return user.uid
    }
    private var listenerRegistration: ListenerRegistration?
    
    init(_ accounts: [MBAccount] = [], transactions: [String: [MBTransaction]] = [:]) {
        self.accounts = accounts
        self.transactions = transactions
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
    
    func loadTransactions(
        accountUID: String,
        onUpdate: @escaping ([MBTransaction]) -> Void
    ) {
        let db = Firestore.firestore()
        guard let uid else {
            // if we can't get a uid, that means we're not signed in yet...
            print("No user signed in, can't load accounts")
            return
        }
        
        // create query to match all accounts owned by current user
        let query = db
            .collection("transactions")
            .whereField("ownerUID", isEqualTo: uid)
            .whereField("accountUID", isEqualTo: accountUID)
        
        self.listenerRegistration = query.addSnapshotListener { snapshot, error in
            guard let snapshot else {
                print("Error listening for changes: \(error!)")
                return
            }
            print("Matching transactions: \(snapshot.documents.count)")
            for document in snapshot.documents {
                guard let transaction = try? document.data(as: MBTransaction.self) else {
                    print("Error decoding transaction document: \(document.data())")
                    return
                }
                
                if let index = self.transactions[accountUID, default: []].firstIndex(where: { $0.id == transaction.id }) {
                    print("Transaction \(transaction.id) already exists locally, updating")
                    // account already exists locally, update
                    self.transactions[accountUID, default: []][index].ownerUID = transaction.ownerUID
                    self.transactions[accountUID, default: []][index].accountUID = transaction.accountUID
                    self.transactions[accountUID, default: []][index].date = transaction.date
                    self.transactions[accountUID, default: []][index].amount = transaction.amount
                    self.transactions[accountUID, default: []][index].description = transaction.description
                } else {
                    print("New transaction \(transaction.id)")
                    // new account, add to array
                    self.transactions[accountUID, default: []].append(transaction)
                }
            }
            
            print(self.transactions)
            onUpdate(self.transactions[accountUID, default: []])
        }
    }
    
    func createAccount(_ account: MBAccount) async throws {
        let db = Firestore.firestore()
        try db.collection("accounts").addDocument(from: account)
    }
    
    func createTransaction(_ transaction: MBTransaction) async throws {
        // create transaction
        let db = Firestore.firestore()
        try db.collection("transactions").addDocument(from: transaction)
        
        // update balance
        try await db.collection("accounts")
            .document(transaction.accountUID)
            .updateData(
                [
                    "balance": FieldValue.increment(NSDecimalNumber(decimal: transaction.amount).doubleValue)
                ]
            )
    }
}
