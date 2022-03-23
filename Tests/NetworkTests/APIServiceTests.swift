//
//  APIServiceTests.swift
//  
//
//  Created by Jeremie Janoir on 23/03/2022.
//

import XCTest
@testable import Network

class APIServiceTests: XCTestCase {

    func testEndpoint_provide_correct_url_request() throws {
        // Given
        let requestHeaders = ["Accept": "application/json"]
        let endpoint = Endpoint(path: "path/to/endpoint", headerParameters: requestHeaders, httpMethod: .get, decoder: JSONReponseDecoder())
        let fakeBaseURL = URL(string: "https://jja.com")!
        let fakeNetworkConfiguration = DefaultNetworkConfiguration(baseURL: fakeBaseURL)
        
        // When
        let urlRequest = endpoint.urlRequest(with: fakeNetworkConfiguration)
        
        // Then
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://jja.com/path/to/endpoint")
        XCTAssertEqual(urlRequest.httpMethod, HTTPMethod.get.rawValue)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, requestHeaders)
    }
    
    func testDefaultAPIService_request_endpoint_success() async throws {
        // Given
        let dummyData = DummyCodable(id: "foo")
        let expectedData = try! JSONEncoder().encode(dummyData)
        let fakeNetworkService = FakeNetworkService(expectedData: expectedData)
        let fakeBaseURL = URL(string: "https://jja.com")!
        let fakeNetworkConfiguration = DefaultNetworkConfiguration(baseURL: fakeBaseURL)
        let defaultAPIService = DefaultAPIService(networkService: fakeNetworkService, networkConfiguration: fakeNetworkConfiguration)
        let endpoint = Endpoint(path: "", headerParameters: [:], httpMethod: .get, decoder: JSONReponseDecoder())
        
        // When
        let dummyResponse: DummyCodable = try await defaultAPIService.request(endpoint: endpoint)
        
        // Then
        XCTAssertEqual(dummyResponse.id, "foo")
    }
    
    func testDefaultAPIService_request_endpoint_fail() async {
        // Given
        let fakeBaseURL = URL(string: "https://jja.com")!
        let fakeNetworkConfiguration = DefaultNetworkConfiguration(baseURL: fakeBaseURL)
        let expectedError = URLError(.badServerResponse)
        let throwingNetworkService = ThrowingNetworkService(expectedError: expectedError)
        let defaultAPIService = DefaultAPIService(networkService: throwingNetworkService, networkConfiguration: fakeNetworkConfiguration)
        let endpoint = Endpoint(path: "", headerParameters: [:], httpMethod: .get, decoder: JSONReponseDecoder())
        
        // When
        do {
            let _: DummyCodable = try await defaultAPIService.request(endpoint: endpoint)
        } catch {
            // Then
            XCTAssertEqual(error as! URLError, expectedError)
        }
    }
}

struct DummyCodable: Codable {
    let id: String
}

final class FakeNetworkService: NetworkService {
    
    let expectedData: Data
    
    init(expectedData: Data) {
        self.expectedData = expectedData
    }
    
    func request(_ request: URLRequest) async throws -> Data {
        return expectedData
    }
}

final class ThrowingNetworkService: NetworkService {
    
    let expectedError: Error
    
    init(expectedError: Error) {
        self.expectedError = expectedError
    }
    
    func request(_ request: URLRequest) async throws -> Data {
        throw expectedError
    }
}
