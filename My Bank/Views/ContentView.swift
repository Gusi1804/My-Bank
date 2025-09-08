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
    @State private var stocks: [String: Double] = [
        "AAPL": 0,
        "TSLA": 0,
        "GOOG": 0,
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    accountsListView
                }, header: {
                    accountsHeader
                })
                
                Section(header: VStack {
                    Text("Top Stocks")
                }) {
                    stocksListView
                }
                .task {
                    await loadStocks()
                }
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
    
    @ViewBuilder
    private var stocksListView: some View {
        ForEach(Array(stocks.keys), id: \.self) { ticker in
            HStack {
                Text(ticker)
                Spacer()
                Text("\(stocks[ticker] ?? 0)")
            }
        }
    }
    
    private func loadStocks() async {
        for (ticker, _) in stocks {
            let request = URLRequest(url: URL(string: "https://api.finazon.io/latest/finazon/us_stocks_essential/price?ticker=\(ticker)&apikey=fcb78e8a1b384174bc43857374bb6d86ym")!)
            let (data, _) = try! await URLSession.shared.data(for: request)
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let newPrice = json["p"] as! Double
            
            self.stocks[ticker] = newPrice
        }
    }
}

#Preview {
    ContentView()
        .environment(AccountsViewModel(MBAccount.sampleData))
}
