//
//  ContentView.swift
//  My Bank
//
//  Created by Gustavo Garfias on 9/7/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Form {
                Section("Accounts") {
                    List {
                        
                    }
                }
            }
            .navigationTitle(Text("My Bank"))
        }
    }
}

#Preview {
    ContentView()
}
