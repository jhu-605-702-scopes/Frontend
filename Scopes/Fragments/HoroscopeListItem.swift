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
        Text(horoscope.date, formatter: DateFormatter.MMddYYYYFormatter)
    }
}

extension DateFormatter {
    static let MMddYYYYFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
}


#Preview {
    HoroscopeListItem(
        Horoscope(date: Date(), emojis: ["🫢","🫡","🤫"], feedback: "")
    )
}
