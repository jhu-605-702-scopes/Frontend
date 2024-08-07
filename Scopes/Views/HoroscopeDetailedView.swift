//
//  HoroscopeView.swift
//  Scopes
//
//  Created by Michael Eisemann on 7/30/24.
//

import SwiftUI
import SwiftData

struct HoroscopeDetailedView: View {
    @Bindable var horoscope: Horoscope
    @State var horoscopeFeedback: String = ""
    @Environment(\.modelContext) private var modelContext


    init(_ horoscope: Horoscope) {
        self.horoscope = horoscope
        _horoscopeFeedback = State(initialValue: horoscope.feedback)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(horoscope.emojiString())
                .font(.system(size: 66, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
            
            TextField("What ya thinkin?", text: $horoscopeFeedback, axis: .vertical)
                .lineLimit(7...14)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            Spacer()
//            Text(horoscope.date, style: .date)
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .padding(.bottom)
        } // VStack
        .padding()
        .navigationTitle(Text(horoscope.date, style: .date))
        .onDisappear() {
            saveFeedback(horoscopeFeedback)
        }
        
    }
    private func saveFeedback(_ feedback: String) {
        horoscope.feedback = feedback
        do {
            try modelContext.save()
        } catch {
            print("Failed to save feedback: \(error)")
        }    }
}



#Preview {
    HoroscopeDetailedView(Horoscope(date: Date(), emojis: ["🫢","🫡","🤫"], feedback: "Ay yuh")
)
}
