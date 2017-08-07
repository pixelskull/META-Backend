//
//  DataSource.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 19.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation


protocol ComputeDataSourceable {
    
    var data:[Any] { get set }
    var results:[Any] { get set }
    
    var dataSemaphore:DispatchSemaphore { get set }
    var resultSemaphore:DispatchSemaphore { get set }
    
    init()
    init(data: [Any])
    init(json: Data)
    
    func isEmpty() -> Bool
    func appendData(_ json: Data)
    
    func hasNextElement() -> Bool
    func getNextElement() -> Any?
    
    func hasNextResult() -> Bool
    func getNextResult() -> Any?
    
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



