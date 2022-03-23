//
//  NetworkConfiguration.swift
//  Network
//
//  Created by Jeremie Janoir on 23/03/2022.
//

import Foundation

protocol NetworkConfiguration {
    var baseURL: URL { get }
}

struct DefaultNetworkConfiguration: NetworkConfiguration {
    
    let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
