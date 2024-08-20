//
//  CellSize+Extension.swift
//  IUDI
//
//  Created by LinhMAC on 04/03/2024.
//

import Foundation
protocol CellSizeCaculate {
    func caculateSize(indexNumber: Double, frameSize: Double, defaultNumberItemOneRow: Double,minimumLineSpacing: Double) -> Double
}
extension CellSizeCaculate {
    func caculateSize(indexNumber: Double, frameSize: Double, defaultNumberItemOneRow: Double,minimumLineSpacing: Double) -> Double {
        var imageSize:CGFloat
        if indexNumber <= defaultNumberItemOneRow {
            imageSize = ((frameSize - ((indexNumber - 1) * minimumLineSpacing))/indexNumber)
        } else {
            imageSize = ((frameSize - ((defaultNumberItemOneRow - 1) * minimumLineSpacing))/defaultNumberItemOneRow)
        }
        return imageSize
    }
}
