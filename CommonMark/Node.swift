//
//  Node.swift
//  CommonMark
//
//  Created by Jonathan Landon on 8/29/16.
//  Copyright © 2016 Jonathan Landon. All rights reserved.
//

import Foundation
import cmark

public final class Node {
    let node: UnsafeMutablePointer<cmark_node>
    
    init(node: UnsafeMutablePointer<cmark_node>) {
        self.node = node
    }
    
    public init?(filename: String) {
        guard let node = cmark_parse_file(fopen(filename, "r"), 0) else { return nil }
        self.node = node
    }
    
    public init?(markdown: String) {
        guard let node = cmark_parse_document(markdown, markdown.utf8.count, 0) else { return nil }
        self.node = node
    }
    
    init(type: cmark_node_type,
         children: [Node] = [],
         literal: String? = nil,
         fenceInfo: String? = nil,
         headerLevel: Int? = nil,
         title: String? = nil,
         url: String? = nil,
         listType: Block.List? = nil)
    {
        self.node = cmark_node_new(type)
        self.literal ?= literal
        self.fenceInfo ?= fenceInfo
        self.headerLevel ?= headerLevel
        self.title ?= title
        self.urlString ?= url
        
        if let listType = listType {
            self.listType = (listType == .unordered) ? CMARK_BULLET_LIST : CMARK_ORDERED_LIST
        }
        
        for child in children {
            cmark_node_append_child(node, child.node)
        }
    }
    
    deinit {
        guard type == CMARK_NODE_DOCUMENT else { return }
        cmark_node_free(node)
    }
    
    var type: cmark_node_type {
        return cmark_node_get_type(node)
    }
    
    var listType: cmark_list_type {
        get { return cmark_node_get_list_type(node) }
        set { cmark_node_set_list_type(node, newValue) }
    }
    
    var listStart: Int {
        get { return Int(cmark_node_get_list_start(node)) }
        set { cmark_node_set_list_start(node, Int32(newValue)) }
    }
    
    var typeString: String {
        return String(cString: cmark_node_get_type_string(node)!)
    }
    
    var literal: String {
        get { return String(unsafeCString: cmark_node_get_literal(node)) ?? "" }
        set { cmark_node_set_literal(node, newValue) }
    }
    
    var headerLevel: Int {
        get { return Int(cmark_node_get_heading_level(node)) }
        set { cmark_node_set_heading_level(node, Int32(newValue)) }
    }
    
    var fenceInfo: String? {
        get { return String(unsafeCString: cmark_node_get_fence_info(node)) }
        set { cmark_node_set_fence_info(node, newValue) }
    }
    
    var urlString: String? {
        get { return String(unsafeCString: cmark_node_get_url(node)) }
        set { cmark_node_set_url(node, newValue) }
    }
    
    var title: String? {
        get { return String(unsafeCString: cmark_node_get_title(node)) }
        set { cmark_node_set_title(node, newValue) }
    }
    
    var children: [Node] {
        var result: [Node] = []
        var child = cmark_node_first_child(node)
        while let unwrapped = child {
            result.append(Node(node: unwrapped))
            child = cmark_node_next(child)
        }
        return result
    }
    
    /// Renders the HTML representation
    public var html: String {
        return String(cString: cmark_render_html(node, 0))
    }
    
    /// Renders the XML representation
    public var xml: String {
        return String(cString: cmark_render_xml(node, 0))
    }
    
    /// Renders the CommonMark representation
    public var commonMark: String {
        return String(cString: cmark_render_commonmark(node, CMARK_OPT_DEFAULT, 80))
    }
    
    /// Renders the LaTeX representation
    public var latex: String {
        return String(cString: cmark_render_latex(node, CMARK_OPT_DEFAULT, 80))
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        return "\(typeString) {\n \(literal)\(Array(children)) \n}"
    }
}

extension Node {
    var inline: Inline {
        switch type {
        case CMARK_NODE_TEXT:          return .text(text: literal)
        case CMARK_NODE_SOFTBREAK:     return .softBreak
        case CMARK_NODE_LINEBREAK:     return .lineBreak
        case CMARK_NODE_CODE:          return .code(text: literal)
        case CMARK_NODE_HTML_INLINE:   return .html(text: literal)
        case CMARK_NODE_CUSTOM_INLINE: return .custom(literal: literal)
        case CMARK_NODE_EMPH:          return .emphasis(children: children.inlines)
        case CMARK_NODE_STRONG:        return .strong(children: children.inlines)
        case CMARK_NODE_LINK:          return .link(children: children.inlines, title: title, url: urlString)
        case CMARK_NODE_IMAGE:         return .image(children: children.inlines, title: title, url: urlString)
        default:                       return .text(text: "")
        }
        
    }
    
    var listItem: [Block] {
        switch type {
        case CMARK_NODE_ITEM: return children.blocks
        default:              return []
        }
    }
    
    var block: Block {
        switch type {
        case CMARK_NODE_PARAGRAPH:      return .paragraph(text: children.inlines)
        case CMARK_NODE_BLOCK_QUOTE:    return .blockQuote(items: children.blocks)
        case CMARK_NODE_LIST:           return .list(items: children.list, type: Block.List(cmarkList: listType))
        case CMARK_NODE_CODE_BLOCK:     return .codeBlock(text: literal, language: fenceInfo)
        case CMARK_NODE_HTML_BLOCK:     return .html(text: literal)
        case CMARK_NODE_CUSTOM_BLOCK:   return .custom(literal: literal)
        case CMARK_NODE_HEADING:        return .heading(text: children.inlines, level: headerLevel)
        case CMARK_NODE_THEMATIC_BREAK: return .thematicBreak
        default:                        return .custom(literal: literal)
        }
    }
    
    
}

extension Node {
    /// The abstract syntax tree representation of a Markdown document.
    /// - returns: an array of block-level elements.
    public var elements: [Block] {
        return children.map { $0.block }
    }
}
