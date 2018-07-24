//
//  CalendarViewController.swift
//  NoDiary
//
//  Created by Xie Liwei on 19/07/2018.
//  Copyright © 2018 Xie Liwei. All rights reserved.
//

import Cocoa
import CloudKit
class CalendarViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {
    @IBOutlet var controller: CalendarController!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var monthLabel: NSButton!
    var selectedIndexPath : IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        updateCalendar()
        fetchDiariesOfCurrentMonth()
        // Do view setup here.
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller.itemCount()
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let id = NSUserInterfaceItemIdentifier.init(rawValue: "CalendarDayItem")
        
        let item = collectionView.makeItem(withIdentifier: id, for: indexPath)
        guard let calendarItem = item as? CalendarDayItem else {
            return item
        }
        
        let day = controller.getItemAt(index: indexPath.item)
        
        calendarItem.setBold(bold: !day.isNumber)
        calendarItem.setText(text: day.text)
        calendarItem.setPartlyTransparent(partlyTransparent: !day.isCurrentMonth)
        calendarItem.setHasRedBackground(isToday: day.isToday)
        calendarItem.setGreenBackground(hasDiary: day.hasDiary)
        
        if let selectedIndexPath = selectedIndexPath {
            if selectedIndexPath == indexPath {
                calendarItem.setBlackBackground(isSelected: true)
            }
        } else {
            
        }
        return calendarItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        let day = controller.getItemAt(index: indexPath.item)
        if !day.isNumber {
            return
        }
        if selectedIndexPath == indexPath {
            return
        }
        selectedIndexPath = indexPath
        collectionView.reloadData()
        
        let selectedDate = day.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M-d-yyyy"
        let dateString = dateFormatter.string(from: selectedDate)
        let userInfo = ["date": dateString]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DisplayDiary"), object: nil, userInfo: userInfo)
    }
    
    private func updateCalendar() {
        monthLabel.title = controller.getMonth()
        collectionView.reloadData()
    }
    
    private func getBasicAttributes(button: NSButton, color: NSColor, alpha: CGFloat) -> [NSAttributedStringKey : Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        return [
            NSAttributedStringKey.foregroundColor: color.withAlphaComponent(alpha),
            NSAttributedStringKey.font: NSFont.systemFont(ofSize: (button.font?.pointSize)!, weight: NSFont.Weight.light),
            NSAttributedStringKey.backgroundColor: NSColor.clear,
            NSAttributedStringKey.paragraphStyle: style,
            NSAttributedStringKey.kern: 0.5 // some additional character spacing
        ]
    }
    
    private func applyButtonHighlightSettings(button: NSButton, isAccented: Bool) {
        let color = (isAccented) ? NSColor.systemRed : NSColor.black
        
        let defaultAlpha: CGFloat = (isAccented) ? 1.0 : 0.75
        let pressedAlpha: CGFloat = (isAccented) ? 0.70 : 0.45
        
        let defaultAttributes = getBasicAttributes(button: button, color: color, alpha: defaultAlpha)
        let pressedAttributes = getBasicAttributes(button: button, color: color, alpha: pressedAlpha)
        
        button.attributedTitle = NSAttributedString(string: button.title, attributes: defaultAttributes)
        button.attributedAlternateTitle = NSAttributedString(string: button.title, attributes: pressedAttributes)
        button.alignment = .center
    }
    
    func fetchDiariesOfCurrentMonth() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M-yyyy"
        let currentMonth = dateFormatter.string(from: Date())
        CloudKitManager.fetchDiaryForMonth(monthAndYear: currentMonth) { (diaries, error) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    @IBAction func showNextMonth(_ sender: Any) {
        controller.incrementMonth()
        updateCalendar()
    }
    
    @IBAction func showLastMonth(_ sender: Any) {
        selectedIndexPath = nil
        controller.decrementMonth()
        updateCalendar()

    }
    
    func updateCalender() {
        selectedIndexPath = nil
        monthLabel.title = controller.getMonth()
        collectionView.reloadData()
    }
    
}
