//
//  MBAccount.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import Foundation
import FirebaseFirestore

struct MBAccount: Codable {
    @DocumentID var id: String?
    var name: String
    var balance: Double
}
