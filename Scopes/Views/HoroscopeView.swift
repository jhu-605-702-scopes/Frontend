//
//  HoroscopeView.swift
//  Scopes
//
//  Created by Michael Eisemann on 7/30/24.
//

import SwiftUI

struct HoroscopeView: View {
    var emoji: String
    var date: Date?
    @State var feedback: String = "Placeholder"
    
    var body: some View {
        VStack {
            Text("\(emoji)")
                .font(.largeTitle)
            Spacer()
            TextEditor(text: $feedback)
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
        }
        .padding()
    }
}

#Preview {
    HoroscopeView(emoji: "😓😵‍💫🙏")
}
