//
//  Fetcher.swift
//  Scopes
//
//  Created by Michael Eisemann on 7/30/24.
//

import Foundation

import Foundation

import Foundation

actor Fetcher {
    static let shared = Fetcher()
    private init() {}

    let API_HOST: String = "https://localhost:9090"
    let API_BASE: String = "/v1"

    func getRequest<T: Codable>(endpoint: String) async throws -> T {
        try await sendRequest(endpoint: endpoint, method: "GET")
    }

    func postRequest<T: Codable>(endpoint: String, body: Encodable) async throws -> T {
        try await sendRequest(endpoint: endpoint, method: "POST", body: body)
    }

    func putRequest<T: Codable>(endpoint: String, body: Encodable) async throws -> T {
        try await sendRequest(endpoint: endpoint, method: "PUT", body: body)
    }

    private func sendRequest<T: Codable>(endpoint: String, method: String, body: Encodable? = nil) async throws -> T {
        guard let url = URL(string: "\(API_HOST)\(API_BASE)\(endpoint)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum NetworkError: Error {
    case invalidURL
}
