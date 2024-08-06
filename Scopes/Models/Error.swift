//
//  Error.swift
//  Scopes
//
//  Created by Michael Eisemann on 8/6/24.
//

import Foundation

struct ScopesError: Codable {
    let code: Int
    let message: String
    
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}
