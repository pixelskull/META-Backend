//
//  main.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 16.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

// Loading config file
//let configString = try! String(contentsOfFile: "./config.json", encoding: .utf8)
do {
    let data = try Data(contentsOf: URL(fileURLWithPath: "./config.json"))
    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
    if let json = json {
        var rmqConfig = RabbitMQConfig.sharedInstance
        // set configuration values
        rmqConfig.host          = json["Host"] as! String
        rmqConfig.port          = json["Port"] as! Int
        rmqConfig.readQueue     = json["ReadQueue"] as! String
        rmqConfig.exchange      = json["Exchange"] as! String
        rmqConfig.writeQueue    = json["WriteQueue"] as! String
        rmqConfig.routingKey    = json["RoutingKey"] as! String
        rmqConfig.user          = json["User"] as! String
        rmqConfig.password      = json["Password"] as! String
    }
} catch {
    print(error)
}

RabbitMQAdapter().subscribe()


let startTime = Date()
var signalReceived: sig_atomic_t = 0

signal(SIGINT) { signal in signalReceived = 1 }

var i = 0
while true {
    if signalReceived == 1 { break }
    usleep(500_000)
    i += 1
}

let endTime = Date()
print("Program has run for \(endTime.timeIntervalSince(startTime)) seconds")
