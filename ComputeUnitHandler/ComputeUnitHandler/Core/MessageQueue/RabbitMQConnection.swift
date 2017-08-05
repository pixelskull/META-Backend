//
//  RabbitMQConnection.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 04.08.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation
import librabbitmq

class RabbitMQConnection {
    
    var host:String
    var port:Int
    
    var exchange:String
    var readQueue:String
    var writeQueue:String
    
    var user:String
    var password:String
    
    init(withHost host:String = "127.0.0.1",
         Port port:Int = 5672,
         Exchange exchange:String,
         ReadQueue readQueue:String,
         WriteQueue writeQueue:String,
         Username user:String = "guest",
         Password password:String = "guest") {
        self.host = host
        self.port = port
        
        self.exchange   = exchange
        self.readQueue  = readQueue
        self.writeQueue = writeQueue
        
        self.user       = user
        self.password   = password
    }
    
    func connect() {
        
    }
    
}
