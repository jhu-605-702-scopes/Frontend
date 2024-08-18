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
        try await postWithNoResponse("/notifications", body: notificationRegistrationData)
    }
}

struct NotificationAPIResponse: Codable {
    let statusCode: String
    let body: NotificationJSON
    let headers: Headers
}
