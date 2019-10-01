//
//  Signal.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation
import Diakoneo

enum Notifier {
    static let onTableChanged              = Signal<Void>()
    static let onPantryChanged             = Signal<Void>()
    static let onCommunityQuestionsChanged = Signal<Void>()
    static let onSearchChanged             = Signal<Void>()
    static let onIntroChanged              = Signal<Void>()
    static let onContentLoaded             = Signal<Void>()
}
