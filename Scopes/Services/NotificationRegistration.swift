//
//  NotificationRegistration.swift
//  Scopes
//
//  Created by Michael Eisemann on 8/13/24.
//

import Foundation

struct NotificationJSON: Codable {
    let token: String
}

extension Requests {
    func registerNotifications(token: String) async throws {
        let notificationRegistrationData = NotificationJSON(token: token)
        let response: APIResponse = try await post("/notifications", body: notificationRegistrationData)
    }
}
