//
//  DataSource.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 19.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

/**
 protocol for **ComputeDataSource** Implementations. Defines the needed
 variables **data** and **result** as well as the need for semaphores
 
 Also adds some must have funktions like **hasNextElement** and
 **getNextElement** as well as their result counter parts.
 */
protocol ComputeDataSourceable {
    /// stores data objects (MetaComputeDataSet) with **id** for sequential
    /// data usage and **value**.
    var data:[Any] { get set }
    /// stores the result objects (MetaComputeDataSet) similary to **data**
    var results:[Any] { get set }
    
    /// semaphore to protect read and writes from **data** array
    var dataSemaphore:DispatchSemaphore { get set }
    /// semaphore to protect read and writes from **resluts** array
    var resultSemaphore:DispatchSemaphore { get set }
    
    init()
    init(data: [Any])
    init(json: Data)
    
    /// functions for checking if any data is left in DataSource
    func isEmpty() -> Bool
    /// function to append data directly from json object
    func appendData(_ json: Data)
    /// functions for checking if any data is left in DataSource
    func hasNextElement() -> Bool
    /// gives you the first element of **data**
    func getNextElement() -> Any?
    
    /// functions for checking if any result is left in DataSource
    func hasNextResult() -> Bool
    /// gives you the first element of **results**
    func getNextResult() -> Any?
    /// function for storing an result in **results**
    func storeNextResult(_ result: Any)
    
}

class ComputeDataSource: ComputeDataSourceable {
    
    var data:[Any]
    var results:[Any]
    
    var dataSemaphore:DispatchSemaphore = DispatchSemaphore(value: 1)
    var resultSemaphore:DispatchSemaphore = DispatchSemaphore(value: 1)
    
    
    required init() {
        data = [Any]()
        results = [Any]()
        
        dataSemaphore = DispatchSemaphore(value: 1)
        resultSemaphore = DispatchSemaphore(value: 1)
    }
    
    required convenience init(data:[Any]) {
        self.init()
        
        self.data = data
    }
    
    required convenience init(json: Data) {
        self.init()
        appendData(json)
    }
    
    func appendData(_ json: Data) {
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: json, options: []) as? [Int:Any]
            guard jsonDict != nil else { return }
            for (_, value) in jsonDict! {
                data.append(value)
            }
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func isEmpty() -> Bool {
        return data.isEmpty
    }
    
    func hasNextElement() -> Bool {
        return data.first != nil
    }
    
    func getNextElement() -> Any? {
        dataSemaphore.wait()
        let firstElement = data.removeFirst()
        dataSemaphore.signal()
        return firstElement
    }
    
    
    func hasNextResult() -> Bool {
        return results.first != nil
    }
    
    func getNextResult() -> Any? {
        resultSemaphore.wait()
        let firstResult = results.removeFirst()
        resultSemaphore.signal()
        return firstResult
    }
    
    func storeNextResult(_ result: Any) {
        resultSemaphore.wait()
        self.results.append(result)
        resultSemaphore.signal()
    }
}



