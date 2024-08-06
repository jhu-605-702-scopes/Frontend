//
//  HoroscopeListView.swift
//  Scopes
//
//  Created by Michael Eisemann on 8/6/24.
//

import SwiftUI
import SwiftData

struct HoroscopeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Horoscope.date, order: .reverse)]) private var horoscopes: [Horoscope]
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(horoscopes) { horoscope in
                    NavigationLink {
                        HoroscopeDetailedView(horoscope)
                    } label: {
                        Text(horoscope.date, style: .date)
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: loadDefault) {
                        Label("Load Defaults", systemImage: "arrow.circlepath")
                    }
                }
            }
            .navigationTitle("Scopes")
        } detail: {
            Text("Select a horoscope! 🔮")
        }
    }
    
    private func loadDefault() {
        // try to dump the current horoscopes
        for horoscope in horoscopes {
            withAnimation {
                modelContext.delete(horoscope)
            }
        }

        guard let url = Bundle.main.url(forResource: "sample_horoscopes", withExtension: "json") else {
            print("Unable to find JSON file")
            return
        }

        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let horoscopes = try decoder.decode([Horoscope].self, from: data)
            for horoscope in horoscopes {
                print(horoscope.emojiString())
                withAnimation {
                    modelContext.insert(horoscope)
                }
            }
            
            try modelContext.save()
        } catch {
            print("Error loading or decoding JSON: \(error)")
        }
    }
    
}

#Preview {
    HoroscopeListView()
}
