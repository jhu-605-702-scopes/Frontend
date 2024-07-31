//
//  HoroscopeView.swift
//  Scopes
//
//  Created by Michael Eisemann on 7/30/24.
//

import SwiftUI

struct HoroscopeView: View {
    var emojiScope: String
    var horoscopeDate: Date = Date()
    @State var horoscopeFeedback: String = ""

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text(emojiScope)
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

            Text(horoscopeDate, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .padding()
        .navigationTitle(Text(horoscopeDate, style: .date))
    }
}

#Preview {
    HoroscopeView(emojiScope: "😓😵‍💫🙏")
}
