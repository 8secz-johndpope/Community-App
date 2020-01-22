//
//  ToggleCell.swift
//  community
//
//  Created by Jonathan Landon on 1/21/20.
//

import UIKit
import Diakoneo

final class ToggleCell: CollectionViewCell {
    
    enum Selection: Int {
        case latest   = 0
        case unplayed = 1
        
        var title: String {
            switch self {
            case .latest:   return "Latest"
            case .unplayed: return "Unplayed"
            }
        }
        
        static let items: [String] = [Selection.latest.title, Selection.unplayed.title]
    }
    
    var didSelect: (Selection) -> Void = { _ in }
    
    private let toggle = UISegmentedControl(items: Selection.items)
    
    override func setup() {
        super.setup()
        
        toggle.add(toSuperview: contentView).customize {
            $0.constrainEdgesToSuperview()
            $0.tintColor = .background
            $0.selectedSegmentIndex = 0
            $0.addTarget(for: .valueChanged) { [weak self] in
                guard let self = self, let selection = Selection(rawValue: self.toggle.selectedSegmentIndex) else { return }
                self.didSelect(selection)
            }
        }
    }
    
}
