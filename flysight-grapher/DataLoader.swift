//
//  DataLoader.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import Foundation
import SwiftCSV
import Charts

func getCSV(_ url: URL) -> CSV? {
    do {
        let csv = try CSV(url: url)
        return csv
    } catch {
        return nil
    }
}

extension CSV {

    // Urgh..
    func minTime() -> Double? {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        var min = Double.greatestFiniteMagnitude
        do {
            try validRows { dict in
                let ts = dateFormatter.date(from: dict["time"]!)!
                let secs = ts.timeIntervalSince1970
                
                if secs < min {
                    min = secs
                }
            }
        } catch {
            return nil
        }
        return min
    }

    func validRows(block: @escaping ([String : String]) -> ()) throws {
        var header = false
        var locked = false
        try self.enumerateAsDict { dict in
            if !header {
                header = true
                return
            }
            if !locked {
                if Int32(dict["numSV"]!)! < 7 {
                    return
                }
                locked = true
            }
            
            block(dict)
        }
    }
}
