//
//  MBTransaction.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import Foundation
import FirebaseFirestore

struct MBTransaction: Codable, Identifiable {
    @DocumentID var id: String?
    var date: Date
    var amount: Decimal
    var description: String
    var ownerUID: String
    var accountUID: String
    
    var formattedAmount: String {
        return amount.formatted(.currency(code: "USD"))
    }
    
    var formattedDate: String {
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }
    
    static let sampleData: [MBTransaction] = [
        .init(id: UUID().uuidString, date: Date(), amount: 1200.08, description: "Deposit", ownerUID: "me", accountUID: "account1"),
        .init(id: UUID().uuidString, date: Date(), amount: -100.00, description: "Withdrawal", ownerUID: "me", accountUID: "account1"),
        .init(id: UUID().uuidString, date: Date(), amount: 7.34, description: "P2P Transfer", ownerUID: "me", accountUID: "account1"),
        .init(id: UUID().uuidString, date: Date(), amount: -10.34, description: "Coffee", ownerUID: "me", accountUID: "account2"),
        .init(id: UUID().uuidString, date: Date(), amount: -15.91, description: "Chick-Fil-A", ownerUID: "me", accountUID: "account2"),
        .init(id: UUID().uuidString, date: Date(), amount: -10.34, description: "Coffee", ownerUID: "me", accountUID: "account3"),
        .init(id: UUID().uuidString, date: Date(), amount: -15.91, description: "Chick-Fil-A", ownerUID: "me", accountUID: "account3"),
    ]
    
    static let parsedSampleData: [String: [MBTransaction]] = [
        "account1": [
            .init(id: UUID().uuidString, date: Date(), amount: 1200.08, description: "Deposit", ownerUID: "me", accountUID: "account1"),
            .init(id: UUID().uuidString, date: Date(), amount: -100.00, description: "Withdrawal", ownerUID: "me", accountUID: "account1"),
            .init(id: UUID().uuidString, date: Date(), amount: 7.34, description: "P2P Transfer", ownerUID: "me", accountUID: "account1"),
        ],
        "account2": [
            .init(id: UUID().uuidString, date: Date(), amount: -10.34, description: "Coffee", ownerUID: "me", accountUID: "account2"),
            .init(id: UUID().uuidString, date: Date(), amount: -15.91, description: "Chick-Fil-A", ownerUID: "me", accountUID: "account2"),
        ],
        "account3": [
            .init(id: UUID().uuidString, date: Date(), amount: -10.34, description: "Coffee", ownerUID: "me", accountUID: "account3"),
            .init(id: UUID().uuidString, date: Date(), amount: -15.91, description: "Chick-Fil-A", ownerUID: "me", accountUID: "account3"),
        ]
    ]
}
