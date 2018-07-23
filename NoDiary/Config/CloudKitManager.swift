//
//  CloudKitManager.swift
//  NoDiary
//
//  Created by Xie Liwei on 23/07/2018.
//  Copyright © 2018 Xie Liwei. All rights reserved.
//

import Foundation
import CloudKit

final class CloudKitManager {
    
    static func appCloudDataBase() -> CKDatabase {
        var appDb:CKDatabase!
        let dbName =  GKConfig.CloudkitSettings.nameOfprivateDB
        let container = CKContainer(identifier: dbName)
        appDb = container.privateCloudDatabase

        return appDb
    }
    
    static func fetchDiaryForMonth(monthAndYear: String, completion: @escaping (_ records: [CKRecord]?, _ error: Error?) -> Void) {
        
        let predicate = NSPredicate(format: "diaryDayAndMonth == %@", monthAndYear)
        let query = CKQuery(recordType: "Diary", predicate: predicate)
        appCloudDataBase().perform(query, inZoneWith: nil) { (diaries, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let diaries = diaries else { return }
                for diary in diaries {
                    guard let diaryDate = diary.object(forKey: "diaryDate") as? String,
                        let diary = diary.object(forKey: "diary") as? String
                        else { return }
                    UserDefaults.standard.set(true, forKey: "\(diaryDate)IsSet")
                    UserDefaults.standard.set(diary, forKey: "\(diaryDate)")
                    DispatchQueue.main.async {
                        completion(diaries, error)
                    }
                }
            }
        }
        
    }
}
