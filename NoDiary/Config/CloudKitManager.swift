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
    
    static func appCloudDataBase() -> CKDatabase? {
        if let _ = FileManager.default.ubiquityIdentityToken {
            var appDb:CKDatabase!
            let dbName =  GKConfig.CloudkitSettings.nameOfprivateDB
            let container = CKContainer(identifier: dbName)
            appDb = container.privateCloudDatabase
            
            return appDb
        } else {
            print("No iCloud access, save to local")
            return nil
        }

    }
    
    static func fetchDiaryForMonth(monthAndYear: String, completion: @escaping (_ records: [CKRecord]?, _ error: Error?) -> Void) {
        
        let predicate = NSPredicate(format: "diaryDayAndMonth == %@", monthAndYear)
        let query = CKQuery(recordType: "Diary", predicate: predicate)
        guard let database = appCloudDataBase() else { return }
        database.perform(query, inZoneWith: nil) { (diaries, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let diaries = diaries else { return }
                for diary in diaries {
                    guard let diaryDate = diary.object(forKey: "diaryDate") as? String,
                        let diaryString = diary.object(forKey: "diary") as? String
                        else { return }
                    if let isDelete = diary.object(forKey: "isDeleted") as? String {
                        if isDelete == "true" {
                            UserDefaults.standard.removeObject(forKey: "\(diaryDate)IsSet")
                            UserDefaults.standard.removeObject(forKey: "\(diaryDate)")
                        } else {
                            UserDefaults.standard.set(true, forKey: "\(diaryDate)IsSet")
                            UserDefaults.standard.set(diaryString, forKey: "\(diaryDate)")
                        }
                    } else {
                        UserDefaults.standard.set(true, forKey: "\(diaryDate)IsSet")
                        UserDefaults.standard.set(diaryString, forKey: "\(diaryDate)")
                    }

                    DispatchQueue.main.async {
                        completion(diaries, error)
                    }
                }
            }
        }
    }
    
    static func checkIfDiaryExsit(date: String, completion: @escaping (_ records: [CKRecord]?, _ hasRecord: Bool) -> Void) {
        let predicate = NSPredicate(format: "diaryDate == %@", date)
        let query = CKQuery(recordType: "Diary", predicate: predicate)
        guard let database = appCloudDataBase() else { return }
        database.perform(query, inZoneWith: nil) { (diaries, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let diaries = diaries else { return }
                if diaries.count != 0 {
                    completion(diaries,true)
                } else {
                    completion(nil, false)
                }
            }
        }
    }

    static func updateDiaryToICloud(record: CKRecord, completion: @escaping () -> Void) {
        guard let database = appCloudDataBase() else { return }

        database.save(record) { (record, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                completion()
            }
        }
    }
    
    static func saveDiaryToICloudIfNotExist(date: String, month: String, diary: String, completion: @escaping () -> Void) {
        let record = CKRecord(recordType: "Diary")
        record.setObject(date as CKRecordValue, forKey: "diaryDate")
        record.setObject(month as CKRecordValue, forKey: "diaryDayAndMonth")
        record.setObject(diary as CKRecordValue, forKey: "diary")
        guard let database = appCloudDataBase() else { return }
        database.save(record) { (savedRecord, error) in
            if let error = error {
                debugPrint(error)
            } else {
                completion()
            }
        }
    }
    
    static func deleteDiaryFromICould(record: CKRecord, completion: @escaping () -> Void) {
        record.setObject("true" as CKRecordValue, forKey: "isDeleted")
        guard let database = appCloudDataBase() else { return }
        database.save(record) { (record, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                completion()
            }
        }
    }
}
