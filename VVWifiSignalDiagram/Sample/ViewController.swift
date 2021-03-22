//
//  ViewController.swift
//  VVWIfiSignalDiagram
//
//  Created by Vivi on 2021/3/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var canvasView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    let twoGHzdataArray = [
        WifiSSIDModel(ssid: "TELUS1087", channel: "1", signal: "-85"),
        WifiSSIDModel(ssid: "DIRECT roku 894", channel: "6", signal: "-65"),
        WifiSSIDModel(ssid: "TELUS2410", channel: "6", signal: "-83"),
        WifiSSIDModel(ssid: "Mikeandcath", channel: "6", signal: "-92"),
        WifiSSIDModel(ssid: "TELUS1146", channel: "11", signal: "-81"),
        WifiSSIDModel(ssid: "Boomer", channel:"11", signal: "-91")
    ]
    
    let fiveGHzdataArray = [
        WifiSSIDModel(ssid: "CSC", channel: "36", signal: "-88"),
        WifiSSIDModel(ssid: "Hidden SSID", channel: "64", signal: "-89"),
        WifiSSIDModel(ssid: "guest", channel: "100", signal: "-72"),
        WifiSSIDModel(ssid: "AIR190", channel: "112", signal: "-60"),
        WifiSSIDModel(ssid: "bkguest", channel: "136", signal: "-75"),
        WifiSSIDModel(ssid: "sym", channel:"157", signal: "-71")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawDiagramOnCanvasView()
        drawDiagramOnScrollView(widthMultiplier: 1.5)
    }
    
    private func drawDiagramOnCanvasView() {
        canvasView.superview?.layoutIfNeeded()
        
//        let diagram = TwoGHzWifiSignalDiagram(frame: canvasView.bounds,
//                                              data: twoGHzdataArray,
//                                              backgroundColor: .white,
//                                              textColor: .black,
//                                              titleFontSize: 13)
        
//        let diagram = FiveGHzWifiSignalDiagram(frame: canvasView.bounds,
//                                               data: fiveGHzdataArray,
//                                               backgroundColor: .white,
//                                               textColor: .black,
//                                               titleFontSize: 13)
        
//        let diagram = WifiSignalDiagram(frame: canvasView.bounds,
//                                        type: .twoGHz,
//                                        data: twoGHzdataArray,
//                                        backgroundColor: .white,
//                                        textColor: .black,
//                                        titleFontSize: 13)
        
        let diagram = WifiSignalDiagram(frame: canvasView.bounds,
                                        type: .fiveGHz,
                                        data: fiveGHzdataArray,
                                        backgroundColor: .white,
                                        textColor: .black,
                                        titleFontSize: 13)
        
        canvasView.addSubview(diagram)
        scrollView.contentSize = canvasView.frame.size
    }
    
    private func drawDiagramOnScrollView(widthMultiplier: CGFloat = 1) {
        scrollView.superview?.layoutIfNeeded()
        let frame = CGRect(x: 0, y: 0, width: scrollView.frame.width * widthMultiplier, height: scrollView.frame.height)
        
//        let diagram = TwoGHzWifiSignalDiagram(frame: frame,
//                                              data: twoGHzdataArray)
        
//        let diagram = FiveGHzWifiSignalDiagram(frame: frame,
//                                               data: fiveGHzdataArray)
        
//        let diagram = WifiSignalDiagram(frame: frame,
//                                        type: .twoGHz,
//                                        data: twoGHzdataArray)
        
        let diagram = WifiSignalDiagram(frame: frame,
                                        type: .fiveGHz,
                                        data: fiveGHzdataArray)
        
        scrollView.addSubview(diagram)
        scrollView.contentSize = frame.size
    }
}
