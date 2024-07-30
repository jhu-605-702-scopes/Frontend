//
//  Horoscope.swift
//  Scopes
//
//  Created by Michael Eisemann on 7/30/24.
//

import Foundation
import SwiftData

@Model
final class Horoscope {
    var date: Date
    var emojis: String
    var feedback: String
    
    init(date: Date, emojis: String, feedback: String) {
        self.date = date
        self.emojis = emojis
        self.feedback = feedback
    }
}
