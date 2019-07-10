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
import MapKit

let NUM_SATS_FOR_LOCK = 7

// Contains an array of data points holding:
// - Data before GPS lock removed
// - Times normallised to seconds since data lock
// - All values converted to native types.
//
// It does NOT have:
// - Unit conversions.
struct DataSet {
    let data: Array<DataPoint>
}

struct DataPoint {
    let time: Double
    let position: CLLocationCoordinate2D
    let altitude: Double
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
}

extension CSV {
    func asDataSet() -> DataSet? {
        var data: Array<DataPoint> = []
        let enumeratedHeader = header.enumerated()
        var minTime: Double?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

        var time: Int?
        var lat: Int?
        var lon: Int?
        var hMSL: Int?
        var velN: Int?
        var velE: Int?
        var velD: Int?
        var hAcc: Int?
        var vAcc: Int?
        var sAcc: Int?
        var heading: Int?
        var cAcc: Int?
        var gpsFix: Int?
        var numSV: Int?

        for (index, head) in enumeratedHeader {
            switch head {
            case "time":
                time = index
            case "lat":
                lat = index
            case "lon":
                lon = index
            case "hMSL":
                hMSL = index
            case "velN":
                velN = index
            case "velE":
                velE = index
            case "velD":
                velD = index
            case "hAcc":
                hAcc = index
            case "vAcc":
                vAcc = index
            case "sAcc":
                sAcc = index
            case "heading":
                heading = index
            case "cAcc":
                cAcc = index
            case "gpsFix":
                gpsFix = index
            case "numSV":
                numSV = index
            default:
                print("Unknown key: \(head)")
            }
        }

        var locked = false

        do {
            try enumerateAsArray(startAt: 2) { fields in
                let sats = Int16(fields[numSV!])!
                if !locked {
                    if sats < NUM_SATS_FOR_LOCK {
                        return
                    }
                    locked = true
                }
                
                let position = CLLocationCoordinate2D(latitude: Double(fields[lat!])!,
                                                      longitude: Double(fields[lon!])!)
                let pointTime: Double
                
                let ts = dateFormatter.date(from: fields[time!])!
                let secs = ts.timeIntervalSince1970
                
                if let minTime = minTime {
                    pointTime = secs - minTime
                } else {
                    pointTime = 0
                    minTime = secs
                }
                
                let point = DataPoint(
                    time: pointTime,
                    position: position,
                    altitude: Double(fields[hMSL!])!,
                    velN: Double(fields[velN!])!,
                    velE: Double(fields[velE!])!,
                    velD: Double(fields[velD!])!,
                    hAcc: Double(fields[hAcc!])!,
                    vAcc: Double(fields[vAcc!])!,
                    sAcc: Double(fields[sAcc!])!,
                    heading: Double(fields[heading!])!,
                    cAcc: Double(fields[cAcc!])!,
                    gpsFix: Int16(fields[gpsFix!])!,
                    numSV: sats
                )
                
                data.append(point)
            }
            
            return DataSet(data: data)
        } catch {
            return nil
        }
    }
}
