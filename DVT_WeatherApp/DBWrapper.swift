//
//  DBWrapper.swift
//  DVT_WeatherApp
//
//  Created by Priteshsingh Chandel on 05/02/20.
//  Copyright © 2020 Priteshsingh Chandel. All rights reserved.
//

import UIKit
import SQLite3

class DBWrapper: NSObject {

    var nameArr = [String]()
    var latArr = [String]()
    var lonArr = [String]()
    static let sharedObj = DBWrapper()
     
    func getDatabasePath()->String
     {
         let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
         let path = docDir.first!
         
         return path+"/DVTWeatherDatabase.sqlite"
     }
     
    
     
     func executeQuery(query: String)->Bool
     {
         var success = false
         var db:OpaquePointer?
         var stmnt:OpaquePointer?
         let databasePath = getDatabasePath()
         
         if(sqlite3_open(databasePath,&db)==SQLITE_OK)
             {
                 if(sqlite3_prepare_v2(db, query, -1, &stmnt, nil)==SQLITE_OK)
                 {
                     if(sqlite3_step(stmnt) == SQLITE_DONE )
                     {
                         success = true
                         sqlite3_finalize(stmnt!)
                         sqlite3_close(db!)
                     }
                     else
                     {
                         print("Failed Step")
                     }
                 }
                 else
                 {
                     print("Error in prepare statement\(sqlite3_errmsg(stmnt!)!)")
                     
                 }
             }
         else
             {
                 print("Error in opening database \(sqlite3_errmsg(db!)!)")
             }
         
         
         return success
         
     }
     
     
     func selectAllTask(query:String)->Array<Any>
     {
         nameArr = [String]()
         latArr = [String]()
         lonArr = [String]()
         var db:OpaquePointer?
         var stmnt:OpaquePointer?
         let databasePath = getDatabasePath()
         
         if(sqlite3_open(databasePath,&db))==SQLITE_OK
         {
             if(sqlite3_prepare_v2(db, query, -1, &stmnt, nil)==SQLITE_OK)
             {
                 while(sqlite3_step(stmnt) == SQLITE_ROW )
                 {
                     let name = sqlite3_column_text(stmnt!, 0)
                     let latitude = sqlite3_column_text(stmnt!, 1)
                     let longitude = sqlite3_column_text(stmnt!, 2)
                     
                     let name1 = String(cString: name!)
                     let latitude1 = String(cString: latitude!)
                     let longitude1 = String(cString: longitude!)
                     
                     nameArr.append(name1)
                     latArr.append(latitude1)
                    lonArr.append(longitude1)
                     print(nameArr)
                     
                     sqlite3_close(db!)
                 }
             }
             else
             {
                 print("Error in prepare statement\(sqlite3_errmsg(stmnt!)!)")
                 
             }
         }
         else
         {
             print("Error in opening database \(sqlite3_errmsg(db!)!)")
         }
         
         return nameArr
         
     }
     
     func createTable()
     {
         let createQuery = "create Table if not exists FavLocations(name text, lat text, lon text)"
         let isSuccess = executeQuery(query: createQuery)
         if(isSuccess)
         {
             print("Table Creation: Success")
         }
         else
         {
             print("Table Creation: Failed")
         }
     }
    
}
