//
//  NetworkService.swift
//  Network
//
//  Created by Jeremie Janoir on 21/03/2022.
//

import Foundation

public protocol NetworkService {
    
    func request(_ request: URLRequest) async throws -> Data
}

public enum NetworkError: Error {
    case badServerResponse
    case serverError(statusCode: Int)
}

public class DefaultNetworkService: NetworkService {
    
    private let session: URLSession
    
    public init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    public func request(_ request: URLRequest) async throws -> Data {
        let result = try await session.data(for: request)
        
        guard let httpResponse = result.1 as? HTTPURLResponse else {
            throw NetworkError.badServerResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        return result.0
    }
}
