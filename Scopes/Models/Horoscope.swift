//
//  Horoscope.swift
//  Scopes
//
//  Created by Michael Eisemann on 7/30/24.
//

import Foundation
import SwiftData

@Model
final class Horoscope: Codable {
    var date: Date
    var emojis: [String]
    var feedback: String
    
    init(date: Date, emojis: [String], feedback: String) {
        self.date = date
        self.emojis = emojis
        self.feedback = feedback
    }
    
    enum CodingKeys: String, CodingKey {
        case date
        case emojis
        case feedback
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dateString = try container.decode(String.self, forKey: .date)
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
        self.date = date
        
        self.emojis = try container.decode([String].self, forKey: .emojis)
        self.feedback = try container.decode(String.self, forKey: .feedback)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: date)
        try container.encode(dateString, forKey: .date)
        
        try container.encode(emojis, forKey: .emojis)
        try container.encode(feedback, forKey: .feedback)
    }

    func emojiString() -> String {
        return emojis.joined()
    }
    
}
