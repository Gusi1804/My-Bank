//
//  My_BankApp.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//        return true
//    }
//}

@main
struct My_BankApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var userVM: UserViewModel
    
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
            if userVM.user.isEmpty {
                SignInView()
                    .environment(userVM)
            } else {
                ContentView()
                    .environment(userVM)
            }
        }
    }
}
