//
//  TestDiagramViewController.swift
//  VVWifiSignalDiagram
//
//  Created by Vivi on 2021/3/22.
//

import UIKit

private extension RadioBandType {
    var title: String {
        switch self {
        case .twoGHz: return "2.4 GHz Diagrams"
        case .fiveGHz: return "5 GHz Diagrams"
        }
    }
    
    var dataArray: [WifiSSIDModel] {
        switch self {
        case .twoGHz:
            return [
                WifiSSIDModel(ssid: "TELUS1087", channel: "1", signal: "-85", bandwidth: "40"),
                WifiSSIDModel(ssid: "DIRECT roku 894", channel: "6", signal: "-65", bandwidth: "20"),
                WifiSSIDModel(ssid: "TELUS2410", channel: "6", signal: "-83", bandwidth: "40"),
                WifiSSIDModel(ssid: "Mikeandcath", channel: "6", signal: "-92", bandwidth: "40"),
                WifiSSIDModel(ssid: "TELUS1146", channel: "11", signal: "-81", bandwidth: "20"),
                WifiSSIDModel(ssid: "Boomer", channel:"13", signal: "-91", bandwidth: "40")
            ]
        case .fiveGHz:
            return [
                WifiSSIDModel(ssid: "CSC", channel: "36", signal: "-88", bandwidth: "80"),
                WifiSSIDModel(ssid: "Hidden SSID", channel: "64", signal: "-89", bandwidth: "160"),
                WifiSSIDModel(ssid: "guest", channel: "100", signal: "-72", bandwidth: "160"),
                WifiSSIDModel(ssid: "AIR190", channel: "112", signal: "-60", bandwidth: "20"),
                WifiSSIDModel(ssid: "bkguest", channel: "136", signal: "-75", bandwidth: "40"),
                WifiSSIDModel(ssid: "sym", channel:"157", signal: "-71", bandwidth: "160")
            ]
        }
    }
}

class TestDiagramViewController: UIViewController {

    var type: RadioBandType = .twoGHz
    
    @IBOutlet private weak var canvasView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = type.title
        drawDiagramOnCanvasView()
        drawDiagramOnScrollView(widthMultiplier: type == .twoGHz ? 1.5 : 2)
    }
    
    private func drawDiagramOnCanvasView() {
        canvasView.superview?.layoutIfNeeded()
        
        let diagram = WifiSignalDiagram(frame: canvasView.bounds,
                                        type: type,
                                        data: type.dataArray,
                                        backgroundColor: .white,
                                        textColor: .black,
                                        titleFontSize: 13)
        
        canvasView.addSubview(diagram)
    }
    
    private func drawDiagramOnScrollView(widthMultiplier: CGFloat = 1) {
        scrollView.superview?.layoutIfNeeded()
        let frame = CGRect(x: 0, y: 0, width: scrollView.frame.width * widthMultiplier, height: scrollView.frame.height)
        
        let diagram = WifiSignalDiagram(frame: frame,
                                        type: type,
                                        data: type.dataArray)
        
        scrollView.addSubview(diagram)
        scrollView.contentSize = frame.size
    }
}
