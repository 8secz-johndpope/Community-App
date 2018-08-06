//
//  Block.swift
//  CommonMark
//
//  Created by Jonathan Landon on 9/10/16.
//  Copyright © 2016 Jonathan Landon. All rights reserved.
//

import Foundation
import cmark

/// A block-level element in a Markdown abstract syntax tree.
public enum Block {
    
    /// The type of a list in Markdown, represented by `Block.List`.
    public enum List {
        case unordered
        case ordered
        
        init(cmarkList: cmark_list_type) {
            self = (cmarkList == CMARK_BULLET_LIST) ? .unordered : .ordered
        }
    }
    
    case list(items: [[Block]], type: List)
    case blockQuote(items: [Block])
    case codeBlock(text: String, language: String?)
    case html(text: String)
    case paragraph(text: [Inline])
    case heading(text: [Inline], level: Int)
    case custom(literal: String)
    case thematicBreak
}

extension Block {
    var node: Node {
        switch self {
        case .paragraph(let children):           return Node(type: CMARK_NODE_PARAGRAPH, children: children.nodes)
        case .list(let items, let type):         return Node(type: CMARK_NODE_LIST, children: items.nodes, listType: type)
        case .blockQuote(let items):             return Node(type: CMARK_NODE_BLOCK_QUOTE, children: items.nodes)
        case .codeBlock(let text, let language): return Node(type: CMARK_NODE_CODE_BLOCK, literal: text, fenceInfo: language)
        case .html(let text):                    return Node(type: CMARK_NODE_HTML_BLOCK, literal: text)
        case .custom(let literal):               return Node(type: CMARK_NODE_CUSTOM_BLOCK, literal: literal)
        case .heading(let text, let level):      return Node(type: CMARK_NODE_HEADING, children: text.nodes, headerLevel: level)
        case .thematicBreak:                     return Node(type: CMARK_NODE_THEMATIC_BREAK)
        }
    }
}
