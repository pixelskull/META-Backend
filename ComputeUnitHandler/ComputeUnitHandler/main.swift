//
//  main.swift
//  ComputeUnitHandler
//
//  Created by Pascal Schönthier on 16.06.17.
//  Copyright © 2017 Pascal Schönthier. All rights reserved.
//

import Foundation

//print("Hello, World!")

let arguments = CommandLine.arguments

func main(args:[String]) -> Int {
    guard args.count > 1 else {
        print("wrong usage of: " + args.first!)
        return 1
    }
    
    let handler = ComputeUnitHandler()
    let results = handler.compute(withData: [String](args[1...args.count]))
    
    print("RESULTS:")
    print(results)
    
    return 0
}


