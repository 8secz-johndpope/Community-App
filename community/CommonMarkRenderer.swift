//
//  CommonMarkRenderer.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation
import CommonMark

extension String {
    
    var renderMarkdown: NSMutableAttributedString? {
        guard let node = Node(markdown: self) else { return nil }
        return node.elements.map { $0.render(font: Block.baseFont) }.join(separator: "\n\n")
    }
    
}

protocol Render {
    func render(font: UIFont) -> NSMutableAttributedString
}

extension Array where Element: NSAttributedString {
    func join(separator: String = "") -> NSMutableAttributedString {
        guard !isEmpty else { return NSMutableAttributedString() }
        let result = self[0].mutable
        for element in suffix(from: 1) {
            result.append(NSAttributedString(string: separator))
            result.append(element)
        }
        return result
    }
}


extension UIFont {
    var regular: UIFont {
        let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)
        return UIFont(descriptor: boldFontDescriptor!, size: 0)
    }
    
    var bold: UIFont {
        let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)
        return UIFont(descriptor: boldFontDescriptor!, size: 0)
    }
    
    var italic: UIFont {
        let italicFontDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic)
        return UIFont(descriptor: italicFontDescriptor!, size: 0)
    }
}

extension NSAttributedString {
    func adding(attribute: NSAttributedString.Key, value: Any) -> NSAttributedString {
        let result = mutableCopy() as! NSMutableAttributedString
        result.addAttribute(attribute, value: value, range: NSRange(location: 0, length: result.length))
        return result
    }
    
    var mutable: NSMutableAttributedString {
        return mutableCopy() as! NSMutableAttributedString
    }
    
    var allAttributes: [NSAttributedString.Key : Any] {
        return attributes(at: 0, effectiveRange: nil)
    }
    
    var range: NSRange {
        return NSRange(location: 0, length: length)
    }
}

extension NSMutableAttributedString {
    
    @discardableResult
    public func url(_ url: URL) -> Self {
        if length > 0 {
            addAttribute(.link, value: url, range: range)
        }
        return self
    }
    
    func insert(string: String, with attributes: [NSAttributedString.Key : Any]) {
        insert(NSAttributedString(string: string, attributes: attributes), at: 0)
    }
}

extension Array where Element: Render {
    
    func renderedString(font: UIFont) -> NSMutableAttributedString {
        return map { $0.render(font: font) }.join()
    }
    
}

extension NSTextAttachment {
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height
        
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
    }
}

extension Inline: Render {
    func render(font: UIFont) -> NSMutableAttributedString {
        switch self {
        case .text(let text):         return text.attributed.font(font).color(.dark)
        case .softBreak:              return "\n".attributed.font(font)
        case .lineBreak:              return "\n\n".attributed.font(font)
        case .code(let text):         return text.attributed.font(font).color(.dark)
        case .html(_):                return "".attributed
        case .emphasis(let children): return children.renderedString(font: font.italic)
        case .strong(let children):   return children.renderedString(font: font.bold)
        case .custom(_):              return "".attributed
        case .link(let children, _, let url):
            return children.renderedString(font: font.bold)
                .url(URL(string: url!)!)
                .color(.orange)
                .underline(style: .single, color: .orange)
        case let .image(_, _, three):
            let attachment = AsyncTextAttachment(imageURL: URL(string: "https:\(three!)"), delegate: nil)
            attachment.displaySize = CGSize(width: 150, height: 150)
            return NSAttributedString(attachment: attachment).mutable
        }
    }
}

extension Block {
    
    static let baseFont: UIFont = .regular(size: 16)
    
    func render(font: UIFont) -> NSMutableAttributedString {
        switch self {
        case .list(let items, let type):
            return items.enumerated().map { index, blocks in
                let string = blocks.map { $0.render(font: font) }.join().mutable
                
                var attributes = string.allAttributes
                attributes[.foregroundColor] = UIColor.dark
                attributes[.font] = UIFont.regular(size: (attributes[.font] as? UIFont)?.pointSize ?? 16)
                attributes[.link] = nil
                attributes[.underlineColor] = nil
                attributes[.underlineStyle] = nil
                
                switch type {
                case .ordered:   string.insert(string: "\(index + 1).\t", with: attributes)
                case .unordered: string.insert(string: "●\t", with: attributes)
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.headIndent = 30
                paragraphStyle.lineSpacing = 5
                paragraphStyle.tabStops = [
                    NSTextTab(textAlignment: .left, location: 0, options: [:]),
                    NSTextTab(textAlignment: .left, location: 30, options: [:])
                ]
                
                return string.adding(attribute: .paragraphStyle, value: paragraphStyle).mutable
                }.join(separator: "\n")
        case .blockQuote(_):   fatalError("Block quote not supported")
        case .codeBlock(_, _): fatalError("Code block not supported")
        case .html(_):         fatalError("HTML not supported")
        case .paragraph(let children):
            return children.map { $0.render(font: font) }.join()
        case .heading(let children, let level):
            
            let headerFont: UIFont
            switch level {
            case 1:  headerFont = Block.baseFont.withSize(24).bold
            case 2:  headerFont = Block.baseFont.withSize(18).bold
            case 3:  headerFont = Block.baseFont.withSize(16).bold
            default: headerFont = Block.baseFont
            }
            
            return children.map { $0.render(font: headerFont) }.join()
        case .custom(_): fatalError("Custom not supported")
        case .thematicBreak: fatalError("Thematic break not supported")
        }
    }
}
