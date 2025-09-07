//
//  SignInView.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(UserViewModel.self) var userVM
    @State var email = ""
    @State var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
                .textContentType(.password)
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            
            HStack {
                Button(action: {
                    Task {
                        do {
                            try await userVM.signIn(email: email, password: password)
                            print("Signed in!")
                            print(userVM.user.isEmpty)
                        } catch {
                            print(error.localizedDescription)
                            self.errorMessage = "Failed to sign in:\n\(error.localizedDescription)"
                        }
                    }
                }, label: {
                    Text("Sign In")
                })
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Text("or")
                
                Button(action: {
                    Task {
                        do {
                            try await userVM.signUp(email: email, password: password)
                            print("Signed up successfully!")
                            print(userVM.user.isEmpty)
                        } catch {
                            print(error.localizedDescription)
                            self.errorMessage = "Failed to sign up:\n\(error.localizedDescription)"
                        }
                    }
                }, label: {
                    Text("Sign Up")
                })
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    SignInView()
}
