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
    @State private var originalFeedback: String = ""

    @Environment(\.modelContext) private var modelContext
    init(_ horoscope: Horoscope) {
        self.horoscope = horoscope
        _horoscopeFeedback = State(initialValue: horoscope.feedback)
        _originalFeedback = State(initialValue: horoscope.feedback)
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(horoscope.emojiString)
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
        } // VStack
        .padding()
        .toolbar {
            ToolbarItem {
                Button(action: {
                    shareScreenshot()
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle(Text(horoscope.date, style: .date))
        .onDisappear() {
            Task {
                await saveFeedback()
            }
        }
        
    }
    private func saveFeedback() async {
        guard horoscopeFeedback != originalFeedback else { return }

        do {
            horoscope.feedback = horoscopeFeedback
            try await Requests.shared.updateHoroscope(horoscope)
            originalFeedback = horoscopeFeedback
        } catch {
            horoscopeFeedback = originalFeedback // Revert to original feedback if update fails
        }
    }
    
    private func shareScreenshot() {
        let screenshot = self.snapshot()
        let activityVC = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }

}

extension Requests {
    func updateHoroscope(_ horoscope: Horoscope) async throws {
        let endpoint = "/users/\(horoscope.userId)/horoscopes/\(horoscope.isoDateString)"
        let updateData = HoroscopeUpdateData(emojis: horoscope.emojis, feedback: horoscope.feedback)
        try await postWithNoResponse(endpoint, body: updateData)
    }
}

struct HoroscopeUpdateData: Codable {
    let emojis: [String]
    let feedback: String
}


import SwiftUI

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
