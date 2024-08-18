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

    let API_HOST: String = "https://api.getscopes.app"
    let API_BASE: String = "/v1"

    func get<T: Codable>(_ endpoint: String) async throws -> T {
        try await sendRequest(endpoint: endpoint, method: "GET")
    }

    func post<T: Codable>(_ endpoint: String, body: Encodable? = nil) async throws -> T {
        try await sendRequest(endpoint: endpoint, method: "POST", body: body)
    }
    
    func postWithNoResponse(_ endpoint: String, body: Encodable? = nil) async throws {
        try await sendRequestWithNoResponse(endpoint: endpoint, method: "POST", body: body)
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
        } else if method == "POST" || method == "PUT" {
            request.setValue("0", forHTTPHeaderField: "Content-Length")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("DEBUG: Response for \(method) \(endpoint):")
            print("DEBUG: \(jsonString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        print(httpResponse.statusCode)

        if httpResponse.statusCode >= 400 {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw ScopesError(error: errorResponse.body.error)
        }

        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw ScopesError(error: errorResponse.body.error)
        }    }
    
    
    private func sendRequestWithNoResponse(endpoint: String, method: String, body: Encodable? = nil) async throws {
        guard let url = URL(string: "\(API_HOST)\(API_BASE)\(endpoint)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } else if method == "POST" || method == "PUT" {
            request.setValue("0", forHTTPHeaderField: "Content-Length")
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode >= 400 {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }


}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case invalidDateFormat(dateString: String)
}



struct LoginAPIResponse: Codable {
    let statusCode: String
    let body: UserJSON
    let headers: Headers
}


struct Headers: Codable {
    let contentType: String

    enum CodingKeys: String, CodingKey {
        case contentType = "Content-Type"
    }
}

extension Encodable {
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}


struct ErrorResponse: Codable {
    let statusCode: String
    let body: ErrorBody
    let headers: Headers
}

struct ErrorBody: Codable {
    let error: String
}
