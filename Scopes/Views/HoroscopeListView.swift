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
    @State private var isRefreshing = false
    @State private var errorMessage: String?
    @Query private var users: [User]
    
    var user: User? {
        users.first
    }
    
    var userId: String? {
        user?.id
    }
    
    
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
                    Button(action: {
                        Task {
                            await manualRefresh()
                        }
                    }) {
                        Label("Manual Refresh", systemImage: "arrow.clockwise.circle")
                    }
                }
//                ToolbarItem {
//                    Button(action: {
//                        Task {
//                            await createHoroscope()
//                        }
//                    }) {
//                        Label("Create Horoscope", systemImage: "plus")
//                    }
//                }
            }
            .navigationTitle("Scopes")
            .onAppear() {
                Task {
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    
                    // Check if a horoscope for today already exists
                    let todayHoroscope = horoscopes.first { calendar.isDate($0.date, inSameDayAs: today) }
                    if todayHoroscope == nil {
                        await manualRefresh()
                        await createHoroscope()
                    }
                }
            }
        } detail: {
            // for ipads
            Text("Select a horoscope! 🔮")
        }
    }
    
    private func createHoroscope() async {
        guard let userId = userId else {
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if a horoscope for today already exists
        let todayHoroscope = horoscopes.first { calendar.isDate($0.date, inSameDayAs: today) }
        
        if todayHoroscope == nil {
            do {
                try await Requests.shared.generateHoroscope(for: userId, on: today)
                // After generating, refresh the list to show the new horoscope
                await manualRefresh()
            } catch {
                errorMessage = "Failed to create horoscope: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "A horoscope for today already exists."
        }
    }
    
    
    private func manualRefresh() async {
        guard let userId = userId else {
            return
        }
        isRefreshing = true
        defer { isRefreshing = false }
        print("Manual refresh initiated")
        do {
            let newHoroscopes = try await Requests.shared.fetchHoroscopes(for: userId)
            print("Fetched \(newHoroscopes.count) horoscopes")
            
            // Create a set of existing horoscope ISO date strings for quick lookup
            let existingISODates = Set(horoscopes.map { $0.isoDateString })
            
            // Insert only new horoscopes
            for newHoroscope in newHoroscopes {
                if !existingISODates.contains(newHoroscope.isoDateString) {
                    print("Adding new horoscope for date: \(newHoroscope.isoDateString)")
                    withAnimation {
                        modelContext.insert(newHoroscope)
                    }
                }
            }
            
            // Optional: Update existing horoscopes if needed
            for existingHoroscope in horoscopes {
                if let updatedHoroscope = newHoroscopes.first(where: { $0.isoDateString == existingHoroscope.isoDateString }) {
                    // Update only if there are changes
                    if existingHoroscope.emojis != updatedHoroscope.emojis ||
                        existingHoroscope.feedback != updatedHoroscope.feedback {
                        print("Updating horoscope for date: \(existingHoroscope.isoDateString)")
                        existingHoroscope.emojis = updatedHoroscope.emojis
                        existingHoroscope.feedback = updatedHoroscope.feedback
                    }
                }
            }
            
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
}


extension Requests {
    func fetchHoroscopes(for userId: String) async throws -> [Horoscope] {
        let endpoint = "/users/\(userId)/horoscopes"
        let response: HoroscopesAPIResponse = try await get(endpoint)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return try response.body.map { horoscopeJSON in
            guard let date = dateFormatter.date(from: horoscopeJSON.date) else {
                throw NetworkError.invalidDateFormat(dateString: horoscopeJSON.date)
            }
            
            let emojisArray = parseEmojis(from: horoscopeJSON.emojis)
            
            return Horoscope(date: date,
                             isoDateString: horoscopeJSON.date,
                             emojis: emojisArray,
                             feedback: horoscopeJSON.feedback,
                             userId: horoscopeJSON.userId)
        }
    }
    
    private func parseEmojis(from string: String) -> [String] {
        // Remove the outer square brackets and split by comma
        let emojiStrings = string.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            .components(separatedBy: ", ")
        
        return emojiStrings.compactMap { emojiString in
            // Remove the single quotes around each emoji
            let trimmed = emojiString.trimmingCharacters(in: CharacterSet(charactersIn: "'"))
            
            // Replace Unicode escape sequences with their actual characters
            let processed = replaceUnicodeEscapes(in: trimmed)
            
            return processed.isEmpty ? nil : processed
        }
    }
    
    private func replaceUnicodeEscapes(in string: String) -> String {
        var result = ""
        var iterator = string.unicodeScalars.makeIterator()
        
        while let scalar = iterator.next() {
            if scalar == "\\" {
                if let next = iterator.next() {
                    if next == "u" {
                        var unicodeString = ""
                        for _ in 0..<4 {
                            if let hexChar = iterator.next() {
                                unicodeString.append(Character(hexChar))
                            }
                        }
                        if let unicode = UInt32(unicodeString, radix: 16),
                           let unicodeScalar = UnicodeScalar(unicode) {
                            result.append(Character(unicodeScalar))
                        } else {
                            result.append("\\u")
                            result.append(unicodeString)
                        }
                    } else {
                        result.append(Character(scalar))
                        result.append(Character(next))
                    }
                } else {
                    result.append(Character(scalar))
                }
            } else {
                result.append(Character(scalar))
            }
        }
        
        return result
    }
    
    func generateHoroscope(for userId: String, on date: Date) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let endpoint = "/users/\(userId)/horoscopes/\(dateString)"
        try await postWithNoResponse(endpoint)
    }
}

struct HoroscopesAPIResponse: Codable {
    let statusCode: String
    let body: [HoroscopeJSON]
    let headers: Headers
}

struct HoroscopeJSON: Codable {
    let date: String
    let feedback: String
    let emojis: String
    let userId: String
}

#Preview {
    HoroscopeListView()
}
