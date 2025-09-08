//
//  TransferView.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import SwiftUI
import CodeScanner
internal import AVFoundation

struct TransferView: View {
    @Environment(AccountsViewModel.self) var accountsVM
    @State private var accountUID: String?
    @State private var incoming: Bool = true
    @State private var accountInputUID: String = ""
    @State private var amount: Decimal = 0
    @State private var errorMessage: String?
    @State private var validAccountUID: Bool?
    @State private var isShowingScanner = false
    
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
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
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
    private var receiveView: some View {
        if let accountUID {
            VStack(alignment: .leading) {
                HStack {
                    Text("Share this ID with the sender:")
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
        
        VStack(alignment: .center) {
            AsyncImage(url: URL(string: "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=\(accountUID)"))
        }
    }
    
    @ViewBuilder
    private var sendView: some View {
        VStack {
            HStack {
                Text("Write or paste the receiver's account number here:")
                Spacer()
                Button(action: {
                    accountInputUID = UIPasteboard.general.string ?? ""
                }, label: {
                    Image(systemName: "document.on.clipboard")
                })
            }
            
            ZStack(alignment: .trailing) {
                TextField("Account Number", text: $accountInputUID)
                    .fontDesign(.monospaced)
                    .padding(10)
                    .autocorrectionDisabled(true)
                    .onChange(of: accountInputUID) {
                        Task {
                            let (valid, _) = await validateAccount(accountInputUID)
                            self.validAccountUID = valid
                        }
                    }
                
                if let validAccountUID {
                    if validAccountUID {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        
        Button("Scan Receiver QR") {
            isShowingScanner = true
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "hvkzRdQh8egQqzWNaxih", completion: handleScan)
        }
        
        TextField("Amount", value: $amount, format: .currency(code: "USD"))
        
        Button(action: {
            guard !accountInputUID.isEmpty, amount > 0 else { return }
            print("Transferring \(amount) to \(accountInputUID)")
            
            let date = Date()
            let sendTransaction = MBTransaction(id: UUID().uuidString, date: date, amount: -1 * amount, description: "P2P Transfer", ownerUID: accountsVM.uid ?? "", accountUID: accountUID ?? "")
            
            Task {
                let (valid, ownerUID) = await validateAccount(accountInputUID)
                guard valid else {
                    return
                }
                let receiveTransaction = MBTransaction(id: UUID().uuidString, date: date, amount: amount, description: "P2P Transfer", ownerUID: ownerUID, accountUID: accountInputUID)
                
                do {
                    try await accountsVM.createTransaction(sendTransaction)
                    try await accountsVM.createTransaction(receiveTransaction)
                } catch {
                    print(error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                }
            }
        }, label: {
            Text("Send")
        })
    }
    
    func validateAccount(_ uid: String) async -> (valid: Bool, ownerUID: String) {
        do {
            let account = try await accountsVM.fetchAccount(uid: uid)
            
            return (true, account.ownerUID)
        } catch {
            return (false, "")
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
       isShowingScanner = false
        switch result {
        case .success(let result):
            self.accountInputUID = result.string
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationView {
        TransferView()
            .environment(AccountsViewModel(MBAccount.sampleData))
    }
}
