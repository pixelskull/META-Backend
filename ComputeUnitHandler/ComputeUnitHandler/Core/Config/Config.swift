//
//  Config.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 07.08.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

struct RabbitMQConfig {
    
    static let sharedInstance = RabbitMQConfig()
    
    var host: String = "127.0.0.1"
    var port: Int = 5672
    var readQueue: String = "meta.production.test"
    var exchange: String = "meta.production"
    var writeQueue: String = "meta.production.results"
    var routingKey: String = "results"
    
    var user: String = "guest"
    var password: String = "guest"
    
}
