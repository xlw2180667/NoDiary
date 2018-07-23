//
//  CalendarDayItem.swift
//  CornerCal
//
//  Created by Emil Kreutzman on 24/09/2017.
//  Copyright © 2017 Emil Kreutzman. All rights reserved.
//

import Cocoa

class CalendarDayItem: NSCollectionViewItem {
    
    public func setHasRedBackground(isToday: Bool) {
        if (isToday) {
            view.layer?.cornerRadius = (view.layer?.frame.width)! / 2
            view.layer?.backgroundColor = NSColor.red.cgColor
            textField?.textColor = NSColor.white
        } else {
            view.layer?.cornerRadius = 0
            view.layer?.backgroundColor = CGColor.clear
            textField?.textColor = NSColor.textColor
        }
    }
    
    public func setBlackBackground(isSelected: Bool) {
        if isSelected {
            view.layer?.cornerRadius = (view.layer?.frame.width)! / 2
            view.layer?.backgroundColor = NSColor.black.cgColor
            textField?.textColor = NSColor.white
        } else {
            view.layer?.cornerRadius = 0
            view.layer?.backgroundColor = CGColor.clear
            textField?.textColor = NSColor.textColor
        }
    }
    
    public func setGreenBackground(hasDiary: Bool) {
        if hasDiary {
            view.layer?.cornerRadius = (view.layer?.frame.width)! / 2
            view.layer?.backgroundColor = NSColor(red: 55.0/255.0, green: 189.0/255.0, blue: 0.0/255.0, alpha: 1).cgColor
            textField?.textColor = NSColor.white
        } else {
            view.layer?.cornerRadius = 0
            view.layer?.backgroundColor = CGColor.clear
            textField?.textColor = NSColor.textColor
        }
    }

    
    public func setPartlyTransparent(partlyTransparent: Bool) {
        view.layer?.opacity = partlyTransparent ? 0.5 : 1.0
    }
    
    public func setBold(bold: Bool) {
        let fontSize = (textField?.font?.pointSize)!
        if bold {
            textField?.font = NSFont.boldSystemFont(ofSize: fontSize)
        } else {
            textField?.font = NSFont.systemFont(ofSize: fontSize)
        }
    }
    
    
    
    public func setText(text: String) {
        textField?.stringValue = text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        textField?.alignment = NSTextAlignment.center
    }
    
}
