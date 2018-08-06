//
//  Inline.swift
//  CommonMark
//
//  Created by Jonathan Landon on 9/10/16.
//  Copyright © 2016 Jonathan Landon. All rights reserved.
//

import Foundation
import cmark

/// An inline element in a Markdown abstract syntax tree.
public enum Inline {
    case text(text: String)
    case softBreak
    case lineBreak
    case code(text: String)
    case html(text: String)
    case emphasis(children: [Inline])
    case strong(children: [Inline])
    case custom(literal: String)
    case link(children: [Inline], title: String?, url: String?)
    case image(children: [Inline], title: String?, url: String?)
}

extension Inline {
    var node: Node {
        switch self {
        case .text(let text):                          return Node(type: CMARK_NODE_TEXT, literal: text)
        case .emphasis(let children):                  return Node(type: CMARK_NODE_EMPH, children: children.nodes)
        case .code(let text):                          return Node(type: CMARK_NODE_CODE, literal: text)
        case .strong(let children):                    return Node(type: CMARK_NODE_STRONG, children: children.nodes)
        case .html(let text):                          return Node(type: CMARK_NODE_HTML_INLINE, literal: text)
        case .custom(let literal):                     return Node(type: CMARK_NODE_CUSTOM_INLINE, literal: literal)
        case .link(let children, let title, let url):  return Node(type: CMARK_NODE_LINK, children: children.nodes, title: title, url: url)
        case .image(let children, let title, let url): return Node(type: CMARK_NODE_IMAGE, children: children.nodes, title: title, url: url)
        case .softBreak:                               return Node(type: CMARK_NODE_SOFTBREAK)
        case .lineBreak:                               return Node(type: CMARK_NODE_LINEBREAK)
        }
    }
}
