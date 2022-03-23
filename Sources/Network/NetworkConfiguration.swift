//
//  NetworkConfiguration.swift
//  Network
//
//  Created by Jeremie Janoir on 23/03/2022.
//

import Foundation

public protocol NetworkConfiguration {
    var baseURL: URL { get }
}

public struct DefaultNetworkConfiguration: NetworkConfiguration {
    
    public let baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
