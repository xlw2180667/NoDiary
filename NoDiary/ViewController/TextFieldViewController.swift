//
//  TextFieldViewController.swift
//  NoDiary
//
//  Created by Xie Liwei on 23/07/2018.
//  Copyright © 2018 Xie Liwei. All rights reserved.
//

import Cocoa
import CloudKit

class TextFieldViewController: NSViewController {
    @IBOutlet weak var textViewScrollView: NSScrollView!
    @IBOutlet weak var topView: NSView!
    @IBOutlet var textView: NSTextView!
    
    @IBOutlet weak var saveDiaryButton: NSButton!
    @IBOutlet weak var DeleteDiaryButton: NSButton!
    var dateString: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        topView.alphaValue = 0
        textView.font = NSFont.systemFont(ofSize: 17)

        NotificationCenter.default.addObserver(self, selector: #selector(displayTextView(_:)), name: NSNotification.Name("DisplayDiary"), object: nil)
    }
    
    @objc func displayTextView(_ notification: Notification) {
        topView.alphaValue = 1
        let userInfo = notification.userInfo
        let dateString = userInfo!["date"] as! String
        self.dateString = dateString
        let diary = UserDefaults.standard.string(forKey: "\(dateString)")
        textView.backgroundColor = NSColor.white
        textView.isEditable = true
        textView.string = diary ?? ""
    }
    
    @IBAction func saveDiary(_ sender: Any) {
        guard let date = dateString else { return }
        if textView.string == "" {return}
        
        let monthString = date.components(separatedBy: "-")[0]
        let yearString = date.components(separatedBy: "-")[2]
        let month = monthString + "-" + yearString
        
        UserDefaults.standard.set(textView.string, forKey: "\(date)")
        UserDefaults.standard.set(true, forKey: "\(date)IsSet")
        view.window?.makeFirstResponder(nil)
        CloudKitManager.checkIfDiaryExsit(date: date) { (records, hasRecord) in
            if hasRecord {
                let record = records![0]
                record.setObject(self.textView.string as CKRecordValue, forKey: "diary")
                CloudKitManager.updateDiaryToICloud(record: record, completion: {
                    print("Success!")
                })
            } else {
                CloudKitManager.saveDiaryToICloudIfNotExist(date: date, month: month, diary: self.textView.string, completion: {
                    print("Success!")
                })
            }
        }
    }
    
    @IBAction func deleteDiary(_ sender: Any) {
        guard let date = dateString else { return }
        if textView.string == "" {return}
        UserDefaults.standard.removeObject(forKey: "\(date)")
        UserDefaults.standard.removeObject(forKey: "\(date)IsSet")
        CloudKitManager.checkIfDiaryExsit(date: date) { (records, hasRecord) in
            if hasRecord {
                CloudKitManager.deleteDiaryFromICould(record: records![0], completion: {
                    DispatchQueue.main.async {
                        self.textView.string = ""
                    }
                })
            }
        }
    }
    
    
    
}
