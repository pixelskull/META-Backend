//
//  RabbitMQAdapter.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 06.08.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation
import RMQClient

import ComputeUnitModule


/**
 Adapter class for convenience connection to rabbitmq.
 Uses the Obj-C RMQClient to connect to an configured
 RabbitMQ server instance
 */
class RabbitMQAdapter {
    /// local host name copy from **Config**
    var host: String!
    /// local port number copy from **Config**
    var port: Int!
    /// local queue for reading copy from **Config**
    var readQueue: String!
    /// local exchange name copy from **Config**
    var exchange: String!
    /// local queue for writing copy from **Config**
    var writeQueue: String!
    /// local routing key copy from **Config**
    var routingKey: String!
    /// local user name copy from **Config**
    var user: String!
    /// local password copy from **Config**
    var password: String!
    
    /// Initializer with default values, so that you didn't have to fill them all
    init(hostName: String = "127.0.0.1",
         portNumber: Int = 5672,
         readQueueName: String = "meta.production.test",
         exchangeName: String = "meta.production",
         writeQueueName: String = "meta.production.testfinished",
         routingKeyName: String = "testing",
         userName: String = "guest",
         userPassword: String = "guest") {
        host = hostName
        port = portNumber
        readQueue = readQueueName
        exchange = exchangeName
        writeQueue = writeQueueName
        routingKey = routingKeyName
        user = userName
        password = userPassword
    }
    
    /// convenience initialisation for use with **Config** struct
    convenience init(config: RabbitMQConfig) {
        self.init(hostName: config.host,
                  portNumber: config.port,
                  readQueueName: config.readQueue,
                  exchangeName: config.exchange,
                  writeQueueName: config.writeQueue,
                  routingKeyName: config.routingKey,
                  userName: config.user,
                  userPassword: config.password)
    }
    
    //// helper method for creating rabbitmq channel
    private func getNewChannel() -> RMQChannel {
        // get connection to own machine
        let connection = RMQConnection(delegate: RMQConnectionDelegateLogger())
        print(connection)
        connection.start()
        // get a new channel for communication
        return connection.createChannel()
    }
    
    /// helper method for subscribing from readQueue
    func subscribe() {
        let channel = getNewChannel()
        print(channel)
        // create queue test
        let queue = channel.queue(readQueue)
        print(queue)
        // bind queue to exchange testing
        //TODO: (done by create Queue service? )
//        channel.queueBind(readQueue, exchange: exchange, routingKey: routingKey)
        
        var dataSource: ComputeDataSource!
        var manager: DistributionManager!
        //TODO: use imported one here
        let computeUnit = ComputeUnit()
        
        
        // listen to queue with callback function
        queue.subscribe( { (_ message:RMQMessage) -> Void in
            
            if dataSource.isEmpty() {
                manager.dataSource.appendData(message.body)
            } else {
                dataSource = ComputeDataSource(json: message.body)
                manager = DistributionManager(unit: computeUnit, dataSource: dataSource)
            }
            
            if !manager.running {
                manager.distribute()
            }
        })
    }
    
    /// helper method for publishing to **writeQueue**
    func publish(message: String) {
        // create connection
        let connection = RMQConnection(delegate: RMQConnectionDelegateLogger())
        connection.start()
        // create channel
        let channel = connection.createChannel()
        // get queue
//        let queue = channel.queue(writeQueue)
        //TODO: allready done by create Queue service / configuration?
        channel.queueBind(writeQueue, exchange: exchange, routingKey: routingKey)
        // sending message to exchange via routing key
        channel.defaultExchange().publish(message.data(using: .utf8), routingKey: routingKey)
        //TODO: get right exchange for publishing (meta.production.computed)
        
        
        connection.close()
    }
}
