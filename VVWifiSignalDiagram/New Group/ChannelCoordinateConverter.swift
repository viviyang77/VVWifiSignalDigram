//
//  ChannelCoordinateConverter.swift
//  VVWIfiSignalDiagram
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

/// Converts channel into coordinates in CALayer coorninate system (origin at the very top-left corner)
class ChannelCoordinateConverter {
    
    static let fiveGHzGapChannel = -1

    var radioBandType: RadioBandType = .twoGHz
    
    init(type: RadioBandType) {
        radioBandType = type
    }
    
    func midXCoordinate(channel: Int) -> Double {
        switch radioBandType {
        case .twoGHz:
            if channel == 14 {
                return 12 + (Double(channel) - 2) * 5 + 12
            } else {
                return 12 + (Double(channel) - 1) * 5
            }
        case .fiveGHz:
            if channel == ChannelCoordinateConverter.fiveGHzGapChannel {
                return 10
            } else if channel <= 64 + 2 {
                return 0.25 * Double(channel) - 7
            } else if channel > 64 + 2, channel <= 132 + 2 {
                return 0.0625 * Double(channel) + 4.75
            } else {
                return 0.0625 * Double(channel) + 4.6875
            }
        }
    }
    
    func minXCoordinate(channel: Int) -> Double {
        switch radioBandType {
        case .twoGHz:  return midXCoordinate(channel: channel) - 11.0
        case .fiveGHz: return midXCoordinate(channel: channel - 2)
        }
    }
    
    func maxXCoordinate(channel: Int) -> Double {
        switch radioBandType {
        case .twoGHz:  return midXCoordinate(channel: channel) + 11.0
        case .fiveGHz: return midXCoordinate(channel: channel + 2)
        }
    }
    
    func yCoordinate(signal: Double) -> Double {
        return (signal + 20) / -10
    }
    
    func coordinates(channel: Int, signal: Double) -> CurveCoordinates {
        return CurveCoordinates(startPoint: CGPoint(x: minXCoordinate(channel: channel), y: 8),
                           midPoint: CGPoint(x: midXCoordinate(channel: channel), y: yCoordinate(signal: signal)),
                           endPoint: CGPoint(x: maxXCoordinate(channel: channel), y: 8))
    }
}

extension CGPoint {
    func applyMultiplier(xMultiplier: CGFloat, yMultiplier: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * xMultiplier, y: self.y * yMultiplier)
    }
}
