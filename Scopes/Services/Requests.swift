//
//  Fetcher.swift
//  Scopes
//
//  Created by Michael Eisemann on 7/30/24.
//

import Foundation

actor Requests {
    static let shared = Requests()
    private init() {}

    let API_HOST: String = "https://localhost:9090"
    let API_BASE: String = "/v1"

    func get<T: Codable>(_ endpoint: String) async throws -> T {
        try await sendRequest(endpoint: endpoint, method: "GET")
    }

    func post<T: Codable>(_ endpoint: String, body: Encodable) async throws -> T {
        try await sendRequest(endpoint: endpoint, method: "POST", body: body)
    }

    func put<T: Codable>(_ endpoint: String, body: Encodable) async throws -> T {
        try await sendRequest(endpoint: endpoint, method: "PUT", body: body)
    }
    
    func delete<T: Codable>(_ endpoint: String, body: Encodable) async throws -> T {
        try await sendRequest(endpoint: endpoint, method: "DELETE")
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

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode >= 400 {
            // Try to decode the error response
            if let scopesError = try? JSONDecoder().decode(ScopesError.self, from: data) {
                throw scopesError
            } else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
}

