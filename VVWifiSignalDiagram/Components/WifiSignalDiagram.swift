//
//  WifiSignalDiagram.swift
//  VVWifiSignalDiagram
//
//  Created by Vivi on 2021/3/22.
//

import UIKit

private extension RadioBandType {
    var diagramTitle: String {
        var title = "Wifi Signal Diagram "
        switch self {
        case .twoGHz: title += "(2.4GHz)"
        case .fiveGHz: title += "(5GHz)"
        }
        return title
    }
    
    var defaultDiagramLabelFontSize: CGFloat {
        switch self {
        case .twoGHz: return 12
        case .fiveGHz: return 11
        }
    }
    
    var channels: [Int] {
        switch self {
        case .twoGHz:
            return Array(1 ... 14)
        case .fiveGHz:
            return [36, 40, 44, 48, 52, 56, 60, 64, ChannelCoordinateConverter.fiveGHzGapChannel, 100, 116, 132, 149, 165]
        }
    }
    
    /// x-axis total index plus margin
    var maxXIndex: Int {
        switch self {
        case .twoGHz: return 95 + 5
        case .fiveGHz: return 15 + 1
        }
    }
}

/// Supports  2.4 GHz and 5 GHz diagram. Set parameters when initializing the diagram. Cannot modify parameters after initializing.
class WifiSignalDiagram: UIView {
    
    var radioBandType: RadioBandType = .twoGHz

    private lazy var title = radioBandType.diagramTitle
    private var xAxisTitle = "Wifi Channels"
    private var yAxisTitle = "Signal Strength [dBm]"
    private var data: [WifiSSIDModel] = []
    private var diagramColors: [UIColor] = [.red, .green, .blue, .gray, .orange, .cyan, .brown, .purple, .magenta]
    private var textColor: UIColor = .white
    private var titleFontSize: CGFloat = 12
    private lazy var labelFontSize: CGFloat = radioBandType.defaultDiagramLabelFontSize
    
    private var xMultiplier: CGFloat = 4    // x-axis width of an index; will be modified according to self.frame
    private var yMultiplier: CGFloat = 13   // x-axis height of an index; will be modified according to self.frame
    
    private let outerMargin: CGFloat = 5
    private let innerMargin: CGFloat = 2
    private let labelHeight: CGFloat = 16
    private let yAxisLabelWidth: CGFloat = 20
    private let topMargin: CGFloat = 5
    
    private var diagramWidth: CGFloat {
        CGFloat(maxXIndex) * xMultiplier
    }
    
    private var diagramHeight: CGFloat {
        CGFloat(maxYIndex) * yMultiplier
    }
    
    private lazy var channels = radioBandType.channels
    
    private lazy var maxXIndex = radioBandType.maxXIndex
    private lazy var maxYIndex: Int = 8     // y-axis total index = 8 (signal: -100 to -20)
    
    private lazy var converter = ChannelCoordinateConverter(type: radioBandType)

    init(frame: CGRect,
         type: RadioBandType,
         data: [WifiSSIDModel],
         title: String? = nil,
         xAxisTitle: String? = nil,
         yAxisTitle: String? = nil,
         backgroundColor: UIColor = .darkGray,
         diagramColors: [UIColor]? = nil,
         textColor: UIColor? = nil,
         titleFontSize: CGFloat? = nil,
         labelFontSize: CGFloat? = nil) {
        
        super.init(frame: frame)
        
        self.radioBandType = type
        self.data = data
        self.title = title ?? self.title
        self.xAxisTitle = xAxisTitle ?? self.xAxisTitle
        self.yAxisTitle = yAxisTitle ?? self.yAxisTitle
        self.backgroundColor = backgroundColor
        self.diagramColors = diagramColors ?? self.diagramColors
        self.textColor = textColor ?? self.textColor
        self.titleFontSize = titleFontSize ?? self.titleFontSize
        self.labelFontSize = labelFontSize ?? self.labelFontSize
        
        makeDiagram()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeDiagram()
    }
    
    private func makeDiagram() {
        
        // We first draw the origin at x = 0, y = maxYIndex * yMultiplier first to simplify the drawing.
        // Later we move the whole diagram downwards by the total heights of layers on top of the diagram,
        // and move rightwards by the total widths of layers to the left of the y-axis.
                
        // The total heights of layers on top of the diagram =
        // outer margin + title height + innerMargin + an additional top margin
        let topDistance = outerMargin + labelHeight + innerMargin + topMargin
        
        // The total widths of layers on the left of the y-axis =
        // outer margin + y-axis title width (which equals to label height) + inner margin + y-axis labels width + inner margin
        let leftDistance = outerMargin + labelHeight + innerMargin + yAxisLabelWidth + innerMargin
        
        // The total heights of layers below the diagram =
        // outer margin + title height + inner margin + x-axis label height + inner margin
        let bottomDistance = outerMargin + labelHeight + innerMargin + labelHeight + innerMargin
        
        // The total widths of layers on the right of the diagram = outer margin
        let rightDistance = outerMargin

        // To calculate the correct x/y multiplier, we need to subtract widths/heights of layers that are not part of
        // the actual diagram itself (eg. titles, labels, outer margins).
        let subtractedHeight = topDistance + bottomDistance
        let subtractedWidth = leftDistance + rightDistance
        
        // Calculate the correct x and y multipliers according to self.frame
        superview?.layoutIfNeeded()
        xMultiplier = (frame.width - subtractedWidth) / CGFloat(maxXIndex)
        yMultiplier = (frame.height - subtractedHeight) / CGFloat(maxYIndex)
        
        drawDiagramTitle()
        drawXLabels()
        drawYLabels()
        drawSupportLines()
        drawXAxisTitle()
        drawYAxisTitle()
        
        // Sort according to wifi signal (weak -> strong)
        let sorted = data.sorted { (data1, data2) -> Bool in
            return data1.signalAsDouble < data2.signalAsDouble
        }
        
        for (index, data) in sorted.enumerated() {
            drawArc(data: data, color: diagramColors[index % diagramColors.count])
        }
        
        // Draw the two axes last so that curves do not appear on top of the axes
        drawAxes()
        
        // Move rightwards & downwards after all layers have been added to the diagram
        layer.sublayers?.forEach { $0.position = CGPoint(x: $0.position.x + leftDistance,
                                                         y: $0.position.y + topDistance) }
    }
    
    /// Draw title of the diagram. Draw as if the diagram is placed to the very top of the canvas (y = 0).
    private func drawDiagramTitle() {
        let textLayer = titleLabelLayer(title: title)
        
        let x: CGFloat = 0
        let y = -labelHeight - innerMargin - topMargin
        let width = diagramWidth
        let height = labelHeight
        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        textLayer.frame = frame
        layer.addSublayer(textLayer)
    }
    
    /// Draw labels below the x-axis. Draw as if the diagram is placed to the very top of the canvas (y = 0).
    private func drawXLabels() {
        let labels = channels
        
        // Labels should be centered horizontally with its corresponding channel
        let labelMidXs = labels.map { CGFloat(converter.midXCoordinate(channel: $0)) * xMultiplier }
        let labelY = diagramHeight + innerMargin
        
        for (index, label) in labels.enumerated() {
            if label == ChannelCoordinateConverter.fiveGHzGapChannel {
                continue
            }
            
            let width = 30 * xMultiplier
            drawText("\(label)",
                     frame: CGRect(x: labelMidXs[index] - width / 2.0,
                                   y: labelY,
                                   width: width,
                                   height: labelHeight),
                     color: textColor)
        }
    }
    
    private func drawYLabels() {
        // We do not show the last label
        let labels = Array(1 ... maxYIndex).reversed().map { "\(($0 - 10) * 10)" }
        let width = yAxisLabelWidth
        let height = labelHeight
        let x = -innerMargin - width
        let yPositions = Array(1 ... maxYIndex).map { CGFloat($0 - 1) * yMultiplier - height / 2 }

        for (index, label) in labels.enumerated() {
            drawText("\(label)",
                     frame: CGRect(x: x,
                                   y: yPositions[index],
                                   width: width,
                                   height: height),
                     color: textColor)
        }
    }
    
    private func drawSupportLines() {
        let yPositions = Array(0 ... maxYIndex).reversed().map { CGFloat($0) * yMultiplier }
        let startPoints = yPositions.map { CGPoint(x: 0, y: $0) }
        let maxX = diagramWidth
        let endPoints = yPositions.map { CGPoint(x: maxX, y: $0) }
        
        var allPoints: [CGPoint] = []
        for i in 0 ..< startPoints.count {
            allPoints.append(startPoints[i])
            allPoints.append(endPoints[i])
        }
        
        let path = UIBezierPath()
        for i in 0 ..< allPoints.count {
            let point = allPoints[i]
            let isStartPoint = i % 2 == 0
            if isStartPoint {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = textColor.withAlphaComponent(0.5).cgColor
        shapeLayer.lineWidth = 0.5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineDashPattern = [3, 3]
        
        layer.addSublayer(shapeLayer)
    }
    
    private func drawXAxisTitle() {
        let textLayer = titleLabelLayer(title: xAxisTitle)
        
        let x: CGFloat = 0
        let y = diagramHeight + innerMargin + labelHeight + innerMargin
        let width = diagramWidth
        let height = labelHeight
        textLayer.frame = CGRect(x: x, y: y, width: width, height: height)
        
        layer.addSublayer(textLayer)
    }
    
    private func drawYAxisTitle() {
        let textLayer = titleLabelLayer(title: yAxisTitle)
        
        let x: CGFloat = -innerMargin - yAxisLabelWidth - innerMargin - labelHeight
        let y: CGFloat = diagramHeight
        let width = diagramHeight
        let height = labelHeight
        textLayer.anchorPoint = CGPoint(x: 0, y: 0)

        textLayer.frame = CGRect(x: x, y: y, width: width, height: height)
        textLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(Double.pi * -90 / 180)))

        layer.addSublayer(textLayer)
    }
    
    private func drawArc(data: WifiSSIDModel, color: UIColor = .blue) {
        let coordinates = converter.coordinates(channel: data.channelAsInt,
                                                signal: data.signalAsDouble)
        let appliedMultiplier = coordinates.applyMultiplier(xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        let path = UIBezierPath()
        path.move(to: appliedMultiplier.startPoint)
        let controlPointXOffset = (coordinates.endPoint.x - coordinates.startPoint.x) * 0.2 * xMultiplier
        path.addQuadCurve(to: appliedMultiplier.midPoint,
                          controlPoint: CGPoint(x: appliedMultiplier.startPoint.x + controlPointXOffset,
                                                y: appliedMultiplier.midPoint.y))
        path.addQuadCurve(to: appliedMultiplier.endPoint,
                          controlPoint: CGPoint(x: appliedMultiplier.endPoint.x - controlPointXOffset,
                                                y: appliedMultiplier.midPoint.y))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.fillColor = color.withAlphaComponent(0.2).cgColor
        layer.addSublayer(shapeLayer)
        
        // Add text
        let height: CGFloat = 15
        let width = 50 * xMultiplier
        let frame = CGRect(x: appliedMultiplier.midPoint.x - width / 2.0,
                           y: appliedMultiplier.midPoint.y - height - innerMargin,
                           width: width,
                           height: height)
        
        drawText(data.ssid, frame: frame, color: color)
    }
    
    private func drawAxes() {
        let startPoint = CGPoint(x: 0, y: 0).applyMultiplier(xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        let secondPoint = CGPoint(x: 0, y: maxYIndex).applyMultiplier(xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        let endPoint = CGPoint(x: maxXIndex, y: maxYIndex).applyMultiplier(xMultiplier: xMultiplier, yMultiplier: yMultiplier)
        
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: secondPoint)
        path.addLine(to: endPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = textColor.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        layer.addSublayer(shapeLayer)
    }
}

// MARK: Helper

extension WifiSignalDiagram {
    
    private func titleLabelLayer(title: String) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.fontSize = titleFontSize
        textLayer.foregroundColor = textColor.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        textLayer.string = title
        return textLayer
    }
    
    private func drawText(_ string: String, frame: CGRect, color: UIColor) {
        let textLayer = CATextLayer()
        textLayer.fontSize = labelFontSize
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .center
        textLayer.string = string
        textLayer.frame = frame
        layer.addSublayer(textLayer)
    }
}
