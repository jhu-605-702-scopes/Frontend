import Foundation
import SwiftData

@Model
final class Horoscope {
    var date: Date
    var isoDateString: String
    var emojis: [String]
    var feedback: String
    var userId: String

    init(date: Date, isoDateString: String, emojis: [String], feedback: String, userId: String) {
        self.date = date
        self.isoDateString = isoDateString
        self.emojis = emojis
        self.feedback = feedback
        self.userId = userId
    }

    var emojiString: String {
        return emojis.joined()
    }
}
