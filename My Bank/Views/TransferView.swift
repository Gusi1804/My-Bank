//
//  TransferView.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import SwiftUI

struct TransferView: View {
    @Environment(AccountsViewModel.self) var accountsVM
    @State private var accountUID: String?
    @State private var incoming: Bool = true
    @State private var accountInputUID: String = ""
    
    var body: some View {
        Form {
            Section {
                Picker("Transfer Type", selection: $incoming, content: {
                    Text("Send").tag(false)
                    Text("Receive").tag(true)
                })
                .pickerStyle(.segmented)
                
                accountPicker
                    .task {
                        accountUID = accountsVM.accounts.first?.id
                    }
            }
            
            Section {
                if incoming {
                    receiveView
                } else {
                    sendView
                }
            }
        }
        .navigationTitle("Transfer")
    }
    
    @ViewBuilder
    private var accountPicker: some View {
        Picker("Account", selection: $accountUID) {
            ForEach(accountsVM.accounts) { account in
                Text(account.name).tag(account.id)
            }
        }
    }
    
    @ViewBuilder
    private var sendView: some View {
        if let accountUID {
            VStack(alignment: .leading) {
                HStack {
                    Text("Share this ID with the recipient:")
                    Spacer()
                    Button(action: {
                        UIPasteboard.general.string = accountUID
                    }, label: {
                        Image(systemName: "document.on.document")
                    })
                }
                Text(accountUID)
                    .fontDesign(.monospaced)
                    .padding(10)
            }
        }
    }
    
    @ViewBuilder
    private var receiveView: some View {
        VStack {
            HStack {
                Text("Write or paste the sender's account number here:")
                Spacer()
                Button(action: {
                    accountInputUID = UIPasteboard.general.string ?? ""
                }, label: {
                    Image(systemName: "document.on.clipboard")
                })
            }
            TextField("Account Number", text: $accountInputUID)
                .fontDesign(.monospaced)
                .padding(10)
        }
    }
}

#Preview {
    NavigationView {
        TransferView()
            .environment(AccountsViewModel(MBAccount.sampleData))
    }
}
