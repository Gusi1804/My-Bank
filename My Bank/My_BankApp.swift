//
//  My_BankApp.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth


@main
struct My_BankApp: App {
    @State var userVM: UserViewModel
    @State var accountsVM: AccountsViewModel = .init()
    @State var signedIn = false
    
    init() {
        FirebaseApp.configure()
        
        if let user = Auth.auth().currentUser {
            // user already signed in! -> skip log in
            userVM = .init(user: user)
        } else {
            // not signed in
            userVM = .init(user: .empty)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if userVM.user.isEmpty && !signedIn {
                SignInView(signedIn: $signedIn)
                    .environment(userVM)
            } else {
                ContentView()
                    .environment(userVM)
                    .environment(accountsVM)
            }
        }
    }
}
