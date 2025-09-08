//
//  NewTransactionSheet.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import SwiftUI

struct NewTransactionSheet: View {
    @Environment(AccountsViewModel.self) var accountsVM
    @Environment(\.presentationMode) var presentationMode
    @State private var transaction: MBTransaction = .init(id: UUID().uuidString, date: Date(), amount: 0, description: "", ownerUID: "", accountUID: "")
    @State private var errorMessage: String?
    @State private var accountUID: String?
    var defaultAccountUID: String?
    
    var body: some View {
        Form {
            Section(header: VStack {Text("New Transaction")}, footer: VStack {
                VStack {
                    Button(action: {
                        // validate user inputs
                        guard !transaction.description.isEmpty,
                              !transaction.accountUID.isEmpty
                        else {
                            return
                        }
                        
                        Task {
                            do {
                                try await accountsVM.createTransaction(transaction)
                                // once the account is created, dismiss the sheet
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                print(error.localizedDescription)
                                self.errorMessage = error.localizedDescription
                            }
                        }
                    }, label: {
                        Text("Save Transaction")
                            .frame(maxWidth: .infinity)
                    })
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                }
            }) {
                TextField("Description", text: $transaction.description)
                TextField("Amount", value: $transaction.amount, format: .currency(code: "USD"))
                    .foregroundStyle(transaction.amount < 0 ? .red : .green)
                DatePicker("Date", selection: $transaction.date)
                
                Picker("Account", selection: $accountUID) {
                    ForEach(accountsVM.accounts) { account in
                        Text(account.name).tag(account.id)
                    }
                }
                .onChange(of: accountUID) {
                    if let accountUID {
                        transaction.accountUID = accountUID
                    }
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .onAppear {
            if let defaultAccountUID {
                // if we're starting a transaction from an account page, set it as the default account
                accountUID = defaultAccountUID
                transaction.accountUID = defaultAccountUID
            } else {
                accountUID = accountsVM.accounts.first?.id ?? ""
                transaction.accountUID = accountsVM.accounts.first?.id ?? ""
            }
            transaction.ownerUID = accountsVM.uid ?? ""
        }
        .padding(.top)
    }
    
    func createTransaction() {
        
    }
}

#Preview {
    NewTransactionSheet()
        .environment(AccountsViewModel(MBAccount.sampleData))
}
