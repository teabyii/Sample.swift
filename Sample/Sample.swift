//
//  Sample.swift
//  Sample
//
//  Created by Boom.Lee on 3/28/16.
//  Copyright © 2016 Boom.Lee. All rights reserved.
//

import Foundation

public struct Sample {
  
  private static let manager = NSFileManager.defaultManager()
  
  public static let F_OK = 0
  public static let X_OK = 1
  public static let W_OK = 2
  public static let R_OK = 4
  
  // If can access path in mode permission, then return true.
  // Multiple permissions check, you can use X_OK | W_OK
  public static func access(path: String, mode: Int) -> Bool {
    let exists = manager.fileExistsAtPath(path)
    
    return [1, 2, 4].reduce(exists) {
      (result, current) -> Bool in
      
      if mode & current != 0 {
        switch current {
        case 1:
          return result && manager.isExecutableFileAtPath(path)
        case 2:
          return result && manager.isWritableFileAtPath(path)
        case 4:
          return result && manager.isReadableFileAtPath(path)
        default:
          return false
        }
      } else {
        return result
      }
    }
  }
  
  public static func appendFile(filename: String, data: String) {
    let content = data.dataUsingEncoding(NSUTF8StringEncoding)
    
    if !manager.fileExistsAtPath(filename) {
      manager.createFileAtPath(filename,
                               contents: content,
                               attributes: nil)
    } else {
      let handle = NSFileHandle(forWritingAtPath: filename)
      handle?.seekToEndOfFile()
      handle?.writeData(content!)
      handle?.closeFile()
    }
  }
  
  public static func chmod(path: String, mode: Int) throws {
    try manager.setAttributes([NSFilePosixPermissions: mode], ofItemAtPath: path)
  }
  
  public static func chmod(path: String, mode: String) throws {
    try chmod(path, mode: octal(mode)!)
  }
  
  public static func chown(path: String, uid: Int, gid: Int) throws {
    try manager.setAttributes([
      NSFileOwnerAccountID: uid,
      NSFileGroupOwnerAccountID: gid
      ], ofItemAtPath: path)
  }
  
  public static func mkdir(path: String) throws {
    try manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
  }
  
  // Not the same as Node, returns attributes dictionary of file, see:
  // https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSFileManager_Class/#//apple_ref/doc/constant_group/File_Attribute_Keys
  public static func stat(path: String) throws -> [String: AnyObject] {
    return try manager.attributesOfItemAtPath(path)
  }
  
  public static func exists(path: String) -> Bool {
    return manager.fileExistsAtPath(path)
  }
  
  public static func readdir(path: String) throws -> [String] {
    return try manager.contentsOfDirectoryAtPath(path)
  }
  
  public static func readFile(file: String) throws -> String  {
    let fh = NSFileHandle(forReadingAtPath: file)
    let data = fh!.readDataToEndOfFile()
    return NSString(data: data, encoding: NSUTF8StringEncoding) as! String
  }
  
  
  public static func writeFile(file: String, data: String) throws {
    try data.writeToFile(file, atomically: false, encoding: NSUTF8StringEncoding)
  }
  
  public static func rename(path: String, another: String) throws {
    try manager.moveItemAtPath(path, toPath: another)
  }
  
  public static func rmdir(path: String) throws {
    try manager.removeItemAtPath(path)
  }
  
  public static func unlink(path: String) throws {
    try manager.removeItemAtPath(path)
  }
}

func octal(string: String) -> Int? {
  
  if var o = Int(string) {
    var d = 0, i = 0
    
    while o != 0 {
      let remainder = o % 10
      o /= 10
      d += remainder * Int(pow(8, Double(i)))
      i = i + 1
    }
    
    return d
  } else {
    return nil
  }
}
