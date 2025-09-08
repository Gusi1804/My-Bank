//
//  AccountView.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import SwiftUI

struct AccountView: View {
    @Environment(AccountsViewModel.self) var accountsVM
    @State private var showAddTransactionView: Bool = false
    @State private var showTransferView: Bool = false
    var account: MBAccount
    
    @State var transactions: [MBTransaction] = []
    
    var body: some View {
        Form {
            Section("Balance") {
                Text(account.formattedBalance)
                    .fontDesign(.monospaced)
                
                NavigationLink(isActive: $showTransferView, destination: {
                    TransferView()
                }, label: {
                    Label("Transfer", systemImage: "arrow.left.arrow.right")
                })
            }
            
            Section("Recent Transactions") {
                transactionsListView
            }
            .task {
                guard let accountId = account.id else { return }
                accountsVM.loadTransactions(accountUID: accountId, onUpdate: { transactions in
                    self.transactions = transactions
                })
            }
        }
        .sheet(isPresented: $showAddTransactionView, content: {
            NewTransactionSheet(defaultAccountUID: account.id)
        })
        .navigationTitle(account.name)
        .toolbar {
            ToolbarItem {
                toolbarMenu
            }
        }
        
    }
    
    @ViewBuilder
    var transactionsListView: some View {
        List {
            if let accountId = account.id {
                ForEach(transactions) { transaction in
                    transactionRow(transaction: transaction)
                }
            }
            
        }
    }
    
    @ViewBuilder
    func transactionRow(transaction: MBTransaction) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(transaction.formattedAmount)
                    .foregroundStyle(transaction.amount < 0 ? .red : .primary)
                    .fontDesign(.monospaced)
                
                Spacer()
                Text(transaction.formattedDate)
                    .font(.caption)
            }
            Text(transaction.description)
        }
    }
    
    @ViewBuilder
    var toolbarMenu: some View {
        Menu(content: {
            Button(action: {
                self.showAddTransactionView = true
            }, label: {
                Label("New Transaction", systemImage: "dollarsign")
            })
        }, label: {
            Image(systemName: "plus")
        })
    }
}

#Preview {
    NavigationStack {
        AccountView(account: .sampleAccount, transactions: MBTransaction.sampleData)
            .environment(AccountsViewModel(MBAccount.sampleData, transactions: MBTransaction.parsedSampleData))
    }
}
