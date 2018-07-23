//
//  TextFieldViewController.swift
//  NoDiary
//
//  Created by Xie Liwei on 23/07/2018.
//  Copyright © 2018 Xie Liwei. All rights reserved.
//

import Cocoa

class TextFieldViewController: NSViewController {
    @IBOutlet weak var textViewScrollView: NSScrollView!
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        textView.font = NSFont.systemFont(ofSize: 17)

        NotificationCenter.default.addObserver(self, selector: #selector(displayTextView(_:)), name: NSNotification.Name("DisplayDiary"), object: nil)
    }
    
    @objc func displayTextView(_ notification: Notification) {
        let userInfo = notification.userInfo
        let dateString = userInfo!["date"] as! String
        let diary = UserDefaults.standard.string(forKey: "\(dateString)")
        textView.backgroundColor = NSColor.white
        textView.isEditable = true
        textView.string = diary ?? ""
    }
    
}
