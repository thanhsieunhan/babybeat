//
//  FileControll.swift
//  FakeMap
//
//  Created by Vinh The on 12/3/16.
//  Copyright © 2016 Hoàng Minh Thành. All rights reserved.
//

import Foundation

let DOCUMENT_DIRECTORY = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

let fileManager = FileManager.default

typealias SuccessHandler = () -> Void
typealias ErrorHandler = (String) -> Void

class FileControll {
    
    class func saveToPlist (plistFileName : String, tempDict : NSDictionary , success : SuccessHandler, error : ErrorHandler) {
        
        if let directory = DOCUMENT_DIRECTORY {
            
            let fileURL = directory.appendingPathComponent(plistFileName).appendingPathExtension("plist")
            
            if !fileManager.fileExists(atPath: fileURL.absoluteString) {
                
                let bundle = Bundle.main.bundleURL.appendingPathComponent(plistFileName).appendingPathExtension("plist")
                
                do {
                    try fileManager.copyItem(at: bundle, to: fileURL)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            
            let tempArray = NSMutableArray(contentsOf: fileURL)
            
            
            if let array = tempArray {
                
                array.add(tempDict)
                
                array.write(to: fileURL, atomically: true)
                
                success()
                
            }else{
                
                error("No Array")
                
            }
            
        }else{
            error("No Directory")
        }
        
    }
    
    class func getFromPlist (plistFileName : String, success : (_ result : NSArray) -> Void, error : ErrorHandler) {
        
        if let directory = DOCUMENT_DIRECTORY {
            
            let fileURL = directory.appendingPathComponent(plistFileName).appendingPathExtension("plist")
            
            let resultArray = NSArray(contentsOf: fileURL)
            
            if let result = resultArray {
                success(result)
            }else{
                error("No result")
            }
            
            
        }else{
            error("No document directory")
        }
        
    }
    
    class func removeFromPlist (plistFileName : String, index : Int , success : SuccessHandler, error : ErrorHandler) {
        
        if let directory = DOCUMENT_DIRECTORY {
            
            let fileURL = directory.appendingPathComponent(plistFileName).appendingPathExtension("plist")
            
            let result = NSMutableArray(contentsOf: fileURL)
            
            if let result = result {
                result.removeObject(at: index)
                
                result.write(to: fileURL, atomically: true)
                
                success()
                
            }else{
                error("No result")
            }
            
        }else{
            error("No document directory")
        }
        
        
    }
    
}
