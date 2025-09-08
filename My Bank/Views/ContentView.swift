//
//  ContentView.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(AccountsViewModel.self) var accountsVM
    @State private var showAddAccountSheet: Bool = false
    @State private var accounts = [MBAccount]()
    
    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    accountsListView
                }, header: {
                    accountsHeader
                })
            }
            .navigationTitle(Text("My Bank"))
            .sheet(isPresented: $showAddAccountSheet, content: {
                NewAccountSheet()
            })
            .task {
                accountsVM.loadAccounts(onUpdate: { accounts in
                    self.accounts = accounts
                })
            }
        }
    }
    
    @ViewBuilder
    private var accountsListView: some View {
        List {
            ForEach(accounts) { account in
                NavigationLink(destination: AccountView(account: account), label: {
                    HStack {
                        Text(account.name)
                        Spacer()
                        Text(account.formattedBalance)
                    }
                })
                
            }
        }
    }
    
    @ViewBuilder
    private var accountsHeader: some View {
        HStack {
            Text("Accounts")
            Spacer()
            accountsMenu
        }
    }
    
    @ViewBuilder
    private var accountsMenu: some View {
        Menu(content: {
            addAccountButton
        }, label: {
            Image(systemName: "plus.circle.fill")
        })
    }
    
    @ViewBuilder
    private var addAccountButton: some View {
        Button("Add Account") {
            showAddAccountSheet = true
        }
    }
}

#Preview {
    ContentView()
        .environment(AccountsViewModel(MBAccount.sampleData))
}
