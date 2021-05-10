//
//  CALayer+ApplyScreenScale.swift
//  VVWifiSignalDiagram
//
//  Created by Vivi on 2021/5/10.
//

import UIKit

extension CALayer {
    func applyScreenScale() {
        contentsScale = UIScreen.main.scale
    }
}
