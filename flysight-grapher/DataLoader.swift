//
//  DataLoader.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import Foundation
import Charts
import MapKit

let NUM_SATS_FOR_LOCK: Int16 = 7

// Contains an array of data points holding:
// - Data before GPS lock removed
// - Times normallised to seconds since data lock
// - All values converted to native types.
//
// It does NOT have:
// - Unit conversions.
struct DataSet {
    let data: Array<DataPoint>
    let exitFrame: Int?
}

struct DataPoint {
    let time: Double
    let position: CLLocationCoordinate2D
    var altitude: Double
    let velN: Double
    let velE: Double
    let velD: Double
    let hAcc: Double
    let vAcc: Double
    let sAcc: Double
    let heading: Double
    let cAcc: Double
    let gpsFix: Int16
    let numSV: Int16

    func vY() -> Double {
        velD
    }

    func vX() -> Double {
        let n = velN
        let e = velE
        return sqrt(n*n + e*e)
    }
    
    func angle() -> Double {
        atan(vY() / vX()) / Double.pi * 180
    }
}

class DataLoader: ParserDelegate {
    var time: Double?
    var lat: Double?
    var lon: Double?
    var altitude: Double?
    var velN: Double?
    var velE: Double?
    var velD: Double?
    var hAcc: Double?
    var vAcc: Double?
    var sAcc: Double?
    var heading: Double?
    var cAcc: Double?
    var gpsFix: Int16?
    var numSV: Int16?
    
    var dateFormatter = DateFormatter()
    
    var locked = false
    var startTime: Double?
    
    var dataSet: Array<DataPoint> = []
    var currentLine: UInt = 0
    
    func clearData() {
        self.time = nil
        self.lat = nil
        self.lon = nil
        self.altitude = nil
        self.velN = nil
        self.velE = nil
        self.velD = nil
        self.hAcc = nil
        self.vAcc = nil
        self.sAcc = nil
        self.heading = nil
        self.cAcc = nil
        self.gpsFix = nil
        self.numSV = nil
    }
    
    /// Called when the parser begins parsing.
    func parserDidBeginDocument(_ parser: CSV.Parser) {
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        self.locked = false
    }
    
    /// Called when the parser finished parsing without errors.
    func parserDidEndDocument(_ parser: CSV.Parser) {
        if let lastPoint = dataSet.last {
            let zeroAGL = lastPoint.altitude
            for (i, _) in dataSet.enumerated() {
                dataSet[i].altitude -= zeroAGL
            }
        }
    }
    
    /// Called when the parser begins parsing a line.
    func parser(_ parser: CSV.Parser, didBeginLineAt index: UInt) {
        self.clearData()
        self.currentLine = index
    }
    
    /// Called when the parser finished parsing a line.
    func parser(_ parser: CSV.Parser, didEndLineAt index: UInt) {
        if !self.locked {
            return
        }
        
        let position = CLLocationCoordinate2D(latitude: self.lat!,
                                              longitude: self.lon!)
        
        let point = DataPoint(
            time: self.time!,
            position: position,
            altitude: self.altitude!,
            velN: self.velN!,
            velE: self.velE!,
            velD: self.velD!,
            hAcc: self.hAcc!,
            vAcc: self.vAcc!,
            sAcc: self.sAcc!,
            heading: self.heading!,
            cAcc: self.cAcc!,
            gpsFix: self.gpsFix!,
            numSV: self.numSV!
        )
        
        self.dataSet.append(point)
    }
    
    /// Called for every field in a line.
    func parser(_ parser: CSV.Parser, didReadFieldAt index: UInt, value: String) {
        if self.currentLine < 2 {
            return
        }
        
        switch index {
        case 0: // time
            let ts = dateFormatter.date(from: value)!
            let secs = ts.timeIntervalSince1970
            
            if self.currentLine == 2 {
                self.startTime = secs
            }
            self.time = secs - self.startTime!
        case 1: // lat
            self.lat = Double(value)
        case 2: // lon
            self.lon = Double(value)
        case 3: // hMSL
            self.altitude = Double(value)
        case 4: // velN
            self.velN = Double(value)
        case 5: // velE
            self.velE = Double(value)
        case 6: // VelD
            self.velD = Double(value)
        case 7: // hAcc
            self.hAcc = Double(value)
        case 8: // vAcc
            self.vAcc = Double(value)
        case 9: // sAcc
            self.sAcc = Double(value)
        case 10: // heading
            self.heading = Double(value)
        case 11: // cAcc
            self.cAcc = Double(value)
        case 12: // gpsFix
            self.gpsFix = Int16(value)
        case 13: // numSV
            self.numSV = Int16(value)
            if self.numSV! >= NUM_SATS_FOR_LOCK {
                self.locked = true
            }
        default:
            print("Uhh.. \(index) \(value)")
        }
    }
    
    func loadFromURL(_ url: URL) -> DataSet? {
        let configuration = CSV.Configuration(delimiter: ",", encoding: .utf8)
        var exitFrame: Int?
        
        let parser = CSV.Parser(url: url, configuration: configuration)!
        parser.delegate = self
        try! parser.parse()
        if self.dataSet.count == 0 {
            return nil
        }
        
        for (i, point) in dataSet.enumerated() {
            if point.vAcc > 3 {
                exitFrame = i
                break
            }
        }
        
        
        return DataSet(
            data: self.dataSet,
            exitFrame: exitFrame
        )
    }
}
