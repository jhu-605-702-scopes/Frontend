//
//  HoroscopeListItem.swift
//  Scopes
//
//  Created by Michael Eisemann on 7/30/24.
//

import SwiftUI

struct HoroscopeListItem: View {
    let horoscope: Horoscope
    
    init(_ horoscope: Horoscope) {
        self.horoscope = horoscope
    }
    
    var body: some View {
        Text("hi!")
    }
}

#Preview {
    HoroscopeListItem(Horoscope(date: Date(), emojis: "🫢🫡🤫", feedback: ""))
}
