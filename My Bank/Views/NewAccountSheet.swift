//
//  NewAccountSheet.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import SwiftUI

struct NewAccountSheet: View {
    @Environment(AccountsViewModel.self) var accountsVM
    @Environment(\.presentationMode) var presentationMode
    @State private var account: MBAccount = .init(id: UUID().uuidString, name: "", balance: 0, ownerUID: "")
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            TextField("Account Name", text: $account.name)
            TextField("Account Balance", value: $account.balance, format: .currency(code: "USD"))
            
            Button(action: {
                guard !account.name.isEmpty else {
                    return
                }
                
                Task {
                    do {
                        try await accountsVM.createAccount(account)
                        // once the account is created, dismiss the sheet
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print(error.localizedDescription)
                        self.errorMessage = error.localizedDescription
                    }
                }
            }, label: {
                Text("Save Account")
            })
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .onAppear {
            account.ownerUID = accountsVM.uid ?? ""
        }
    }
}

#Preview {
    NewAccountSheet()
        .environment(AccountsViewModel(MBAccount.sampleData))
}
