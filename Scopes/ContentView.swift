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
            DemoView()
                .modelContext(modelContext)
                .tabItem {
                    Image(systemName: "ev.plug.dc.chademo.fill")
                    Text("Demo")
                }
                .tag(0)
            
        }
    }
}


#Preview {
    ContentView()
}
