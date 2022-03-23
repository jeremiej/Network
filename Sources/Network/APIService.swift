//
//  APIService.swift
//  Network
//
//  Created by Jeremie Janoir on 23/03/2022.
//

import Foundation

protocol APIService {
    
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
}

class DefaultAPIService: APIService {
    
    private let networkService: NetworkService
    private let networkConfiguration: NetworkConfiguration
    
    init(networkService: NetworkService, networkConfiguration: NetworkConfiguration) {
        self.networkService = networkService
        self.networkConfiguration = networkConfiguration
    }
    
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let urlRequest = endpoint.urlRequest(with: networkConfiguration)
        let data = try await networkService.request(urlRequest)
        return try endpoint.decoder.decode(data)
    }
}

protocol Requestable {
    var path: String { get }
    var headerParameters: [String: String] { get }
    var httpMethod: HTTPMethod { get }
}

extension Requestable {
    
    func urlRequest(with networkConfiguration: NetworkConfiguration) -> URLRequest {
        let enpointURL = networkConfiguration.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: enpointURL)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headerParameters
        return request
    }
}

protocol ResponseDecodable {
    var decoder: ResponseDecoder { get }
}

protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

class JSONReponseDecoder: ResponseDecoder {
    
    private let decoder = JSONDecoder()
    
    func decode<T>(_ data: Data) throws -> T where T : Decodable {
        return try decoder.decode(T.self, from: data)
    }
}

struct Endpoint: Requestable, ResponseDecodable {
    let path: String
    let headerParameters: [String: String]
    let httpMethod: HTTPMethod
    var decoder: ResponseDecoder
}

enum HTTPMethod: String {
    case get = "GET"
}
