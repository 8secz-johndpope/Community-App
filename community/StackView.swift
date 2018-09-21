//
//  StackView.swift
//  community
//
//  Created by Jonathan Landon on 8/6/18.
//

import UIKit
import Alexandria

extension UIView {
    
    convenience init(stackview: UIStackView) {
        self.init()
        stackview.addArrangedSubview(self)
    }
    
    var hasWidthConstraint: Bool {
        return constraints.contains(where: { $0.firstAttribute == .width && $0.secondAttribute == .notAnAttribute })
    }
}

final class StackView: UIView {
    
    enum Element {
        case spacer(CGFloat)
        case label(NSAttributedString)
        case view(UIColor, CGFloat)
        case button(String, CGFloat, () -> Void)
        case stack(StackView)
        case custom(UIView)
        case customPadding(UIView, CGFloat)
    }
    
    let stackView = UIStackView()
    
    required init(
        axis: NSLayoutConstraint.Axis = .horizontal,
        spacing: CGFloat = 0,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .fill,
        elements: [Element] = [])
    {
        super.init(frame: .zero)
        
        stackView.add(toSuperview: self).customize {
            $0.constrainEdgesToSuperview()
            $0.axis = axis
            $0.spacing = spacing
            $0.distribution = distribution
            $0.alignment = alignment
        }
        
        configure(elements: elements)
    }
    
    func reset() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    @discardableResult
    func configure(elements: [Element]) -> [UIView] {
        reset()
        
        var addedViews: [UIView] = []
        
        for element in elements {
            switch element {
            case .spacer(let space):
                addedViews.append(
                    UIView(stackview: stackView).customize {
                        switch stackView.axis {
                        case .horizontal: $0.constrainWidth(to: space)
                        case .vertical:   $0.constrainHeight(to: space)
                        }
                    }
                )
            case .label(let text):
                addedViews.append(
                    UILabel(stackview: stackView).customize {
                        $0.attributedText = text
                        $0.numberOfLines = 0
                    }
                )
            case .view(let backgroundColor, let size):
                addedViews.append(
                    UIView(stackview: stackView).customize {
                        $0.backgroundColor = backgroundColor
                        switch stackView.axis {
                        case .horizontal: $0.constrainWidth(to: size)
                        case .vertical:   $0.constrainHeight(to: size)
                        }
                    }
                )
            case .button(let title, let height, let callback):
                addedViews.append(
                    UIButton().add(toStackview: stackView).customize {
                        $0.setTitle(title, for: .normal)
                        $0.setBackgroundColor(.random, for: .normal)
                        $0.constrainHeight(to: height)
                        $0.addTarget(for: .touchUpInside, actionClosure: callback)
                    }
                )
            case .stack(let stack):
                addedViews.append(stack.add(toStackview: stackView))
            case .custom(let view):
                addedViews.append(
                    UIStackView(stackview: stackView).customize {
                        $0.axis = stackView.axis
                        $0.alignment = view.hasWidthConstraint ? .center : .fill
                        $0.addArrangedSubview(view)
                    }
                )
            case .customPadding(let view, let padding):
                addedViews.append(
                    UIStackView(stackview: stackView).customize {
                        $0.axis = .vertical
                        $0.alignment = view.hasWidthConstraint ? .center : .fill
                        $0.addArrangedSubview(view)
                        $0.layoutMargins = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
                        $0.isLayoutMarginsRelativeArrangement = true
                    }
                )
            }
        }
        
        return addedViews
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
