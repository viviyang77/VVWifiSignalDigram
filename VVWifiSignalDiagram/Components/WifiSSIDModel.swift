//
//  WifiSSIDModel.swift
//  VVWifiSignalDiagram
//
//  Created by Vivi on 2021/3/22.
//

import Foundation

struct WifiSSIDModel {
    var ssid: String
    var channel: String
    var signal: String
    var bandwidth: String
    
    var signalAsDouble: Double { Double(signal) ?? 0 }
    var channelAsInt: Int { Int(channel) ?? 0 }
    var bandwidthAsDouble: Double { Double(bandwidth) ?? 20 }
}
