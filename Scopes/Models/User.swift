//
//  User.swift
//  Scopes
//
//  Created by Michael Eisemann on 8/6/24.
//

import Foundation
import SwiftData

@Model
final class User: Codable {
    var id: String
    var name: String
    var username: String
    var email: String
    
    init(id: String, name: String, username: String, email: String) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
    }
    
    convenience init(from signUpData: UserJSON) {
            self.init(id: signUpData.userId!,
                      name: signUpData.name!,
                      username: signUpData.username!,
                      email: signUpData.email)
        }

    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
        case email
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
    }
}
