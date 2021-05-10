//
//  ChannelCoordinateConverter.swift
//  VVWifiSignalDiagram
//
//  Created by Vivi on 2021/3/22.
//

import UIKit

struct CurveCoordinates: CustomStringConvertible {
    let startPoint: CGPoint
    let midPoint: CGPoint
    let endPoint: CGPoint
    
    var description: String {
        return "start: \(startPoint), mid: \(midPoint), end: \(endPoint)"
    }
    
    func applyMultiplier(xMultiplier: CGFloat, yMultiplier: CGFloat) -> CurveCoordinates {
        let start = startPoint.applyMultiplier(xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        let mid = midPoint.applyMultiplier(xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        let end = endPoint.applyMultiplier(xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        return CurveCoordinates(startPoint: start, midPoint: mid, endPoint: end)
    }
}

enum RadioBandType {
    case twoGHz     // 2.4GHz
    case fiveGHz    // 5GHz
}

struct XCoordinates {
    let minX: Double
    let midX: Double
    let maxX: Double
}

enum YAxisMaxValue {
    case zero
    case negativeTen
    case negativeTwenty
    
    var maxIndex: Int {
        switch self {
        case .zero: return 10   // 0 to -100
        case .negativeTen: return 9 // -10 to -100
        case .negativeTwenty: return 8  // -20 to -100
        }
    }
    
    var displayedNumbers: [String] {
        var offset: Int
        switch self {
        case .zero: offset = 0
        case .negativeTen: offset = -10
        case .negativeTwenty: offset = -20
        }
         
        var numbers = Array(0 ... maxIndex).map { "\($0 * -10 + offset)" }
        numbers.removeLast()    // Remove the last -100
        return numbers
    }
}

/// Converts channel into coordinates in CALayer coorninate system (origin at the very top-left corner)
class ChannelCoordinateConverter {
    
    static let fiveGHzGapChannel = -1

    var radioBandType: RadioBandType = .twoGHz
    var yAxisMaxValue: YAxisMaxValue = .zero
    
    init(type: RadioBandType) {
        radioBandType = type
    }
    
    func xCoordinates(channel: Int, bandwidth: Double) -> XCoordinates {
        var minX: Double = 0
        var midX: Double = 0
        var maxX: Double = 0
        
        switch radioBandType {
        case .twoGHz:
            midX = Double(22 + (channel - 1) * 5)
            minX = midX - bandwidth / 2
            maxX = midX + bandwidth / 2
        case .fiveGHz:
            if channel == ChannelCoordinateConverter.fiveGHzGapChannel {
                minX = 48
                midX = 48
                maxX = 48
            } else if channel <= 64 {
                midX = Double(channel - 20)
                minX = Double(channel - Int(bandwidth) / 10 - 20)
                maxX = Double(channel + Int(bandwidth) / 10 - 20)
            } else {
                midX = Double(channel - 48)
                minX = Double(channel - Int(bandwidth) / 10 - 48)
                maxX = Double(channel + Int(bandwidth) / 10 - 48)
            }
        }
        return XCoordinates(minX: minX, midX: midX, maxX: maxX)
    }
    
    func yCoordinate(signal: Double) -> Double {
        switch yAxisMaxValue {
        case .zero: return signal * -1 / 10
        case .negativeTen: return (signal * -1 - 10) / 10
        case .negativeTwenty: return (signal * -1 - 20) / 10
        }
    }
    
    func coordinates(channel: Int, signal: Double, bandwidth: Double) -> CurveCoordinates {
        let maxYIndex = Double(yAxisMaxValue.maxIndex)
        let xValues = xCoordinates(channel: channel, bandwidth: bandwidth)
        let coord = CurveCoordinates(
            startPoint: CGPoint(x: xValues.minX,
                                y: maxYIndex),
            midPoint: CGPoint(x: xValues.midX,
                              y: yCoordinate(signal: signal)),
            endPoint: CGPoint(x: xValues.maxX,
                              y: maxYIndex)
        )
        return coord
    }
}

extension CGPoint {
    func applyMultiplier(xMultiplier: CGFloat, yMultiplier: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * xMultiplier, y: self.y * yMultiplier)
    }
}
