//
//  DataSource.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 19.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation


protocol ComputeDataSource {
    
    var data:[Any] { get set }
    var results:[Any] { get set }
    
    var dataSemaphore:DispatchSemaphore { get set }
    var resultSemaphore:DispatchSemaphore { get set }
    
    init()
    init(data: [Any])
    
    func hasNextElement() -> Bool
    func getNextElement() -> Any?
    
    func hashNextResult() -> Bool
    func getNextResult() -> Any?
    
    func storeNextResult(_ result: Any)
    
}

extension ComputeDataSource {
    
    init() {
        self.init()
        data = [Any]()
        results = [Any]()
        
        dataSemaphore = DispatchSemaphore(value: 1)
        resultSemaphore = DispatchSemaphore(value: 1)
    }
    
    init(data:[Any]) {
        self.init()
        
        self.data = data
    }
    
    func hasNextElement() -> Bool {
        return data.first != nil
    }
    
    mutating func getNextElement() -> Any? {
        return data.removeFirst()
    }
    
    
    func hasNextResult() -> Bool {
        return results.first != nil
    }
    
    mutating func getNextResult() -> Any? {
        return results.removeFirst()
    }
}



