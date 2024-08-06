//
//  ContentView.swift
//  Scopes
//
//  Created by Michael Eisemann on 7/30/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            HoroscopeListView()
                .modelContext(modelContext)
                .tabItem {
                    Image(systemName: "gyroscope")
                    Text("Horoscopes")
                }.tag(0)
            UserDetailsView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("User")
                }.tag(1)
            
        }
    }
}


#Preview {
    ContentView()
}
