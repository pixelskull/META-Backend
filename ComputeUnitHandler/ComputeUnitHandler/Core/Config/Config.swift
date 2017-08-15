//
//  Config.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 07.08.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

/// singleton struct for storing global configurations
struct RabbitMQConfig {
    /// singleton access to instance
    static let sharedInstance = RabbitMQConfig()
    /// url for rabbitmq host
    var host: String = "127.0.0.1"
    /// port to rabbitmq host
    var port: Int = 5672
    
    /// rabbitmq queue identifier for subscription
    var readQueue: String = "meta.production.test"
    /// rabbitmq exchange identifier
    var exchange: String = "meta.production"
    /// rabbitmq queue identifier for publishing
    var writeQueue: String = "meta.production.results"
    /// rabbitmq routing key for publishing
    var routingKey: String = "results"
    /// rabbitmq user name
    var user: String = "guest"
    /// rabbitmq password
    var password: String = "guest"
    /// initializes this struct
    private init() {}
}
