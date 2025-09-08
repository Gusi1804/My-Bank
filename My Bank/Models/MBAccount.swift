//
//  MBAccount.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import Foundation
import FirebaseFirestore

struct MBAccount: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var balance: Decimal
    var ownerUID: String
    
    var formattedBalance: String {
        return balance.formatted(.currency(code: "USD"))
    }
    
    static let sampleData: [MBAccount] = [
        Self.sampleAccount,
        .init(id: "account2", name: "Credit Gold", balance: 524.24, ownerUID: "me"),
        .init(id: "account3", name: "Credit Platinum", balance: 1082.92, ownerUID: "me")
    ]
    
    static let sampleAccount: MBAccount = .init(id: "account1", name: "Debit Visa", balance: 10000.0, ownerUID: "me")
}
