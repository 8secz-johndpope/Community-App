//
//  Numbers.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit

extension CGFloat {
    
    static let padding: CGFloat             = 20
    static let shelfCellHeight: CGFloat     = 150
    static let seriesCellHeight: CGFloat    = 150
    static let infoHeight: CGFloat          = 70
    static let textInset: CGFloat           = .padding - 4
    static let mediaProgressHeight: CGFloat = 4
    static let closeButtonWidth: CGFloat    = 58
    static let tablePostHeight: CGFloat     = 300
    
    static var messageVideoHeight: CGFloat {
        return UIScreen.main.width * 0.75
    }
    
}

extension CGSize {
    
    static let shelfSize = CGSize(width: 16/9 * .shelfCellHeight, height: .shelfCellHeight)
    static let seriesSize = CGSize(width: 16/9 * .seriesCellHeight, height: .seriesCellHeight)
    
}
