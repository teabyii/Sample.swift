//
//  SampleTests.swift
//  SampleTests
//
//  Created by Boom.Lee on 3/28/16.
//  Copyright © 2016 Boom.Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import Sample

class SampleTests: XCTestCase {
  
  let manager = NSFileManager.defaultManager()
  let cwd = NSHomeDirectory()
  
  func testReaddir() {
    do {
      let contents = try Sample.readdir(cwd)
      XCTAssertTrue(contents.contains("Library"))
    } catch {}
  }
  
  func testMkdir() {
    do {
      let path = cwd + "/test"
      try Sample.mkdir(path)
      
      let contents = try Sample.readdir(cwd)
      XCTAssertTrue(contents.contains("test"))
      
      try manager.removeItemAtPath(path)
    } catch {}
  }
  
  func testExists() {
    XCTAssertTrue(Sample.exists(cwd + "/Library"))
  }
  
  func testCreateFile() {
    let path = cwd + "test.txt"
    let str = "hello world"
    
    Sample.appendFile(path, data: str)
    XCTAssertTrue(manager.fileExistsAtPath(path))
    
    do {
      let content = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
      XCTAssertEqual(content, str)
      try manager.removeItemAtPath(path)
    } catch {}
  }
  
  func testAppendFile() {
    let path = cwd + "test.txt"
    let str = "1"
    
    Sample.appendFile(path, data: str)
    Sample.appendFile(path, data: str)
    
    do {
      let content = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
      XCTAssertEqual(content, str + str)
      try manager.removeItemAtPath(path)
    } catch {}
  }
  
  func testAccessWriteMode() {
    let path = cwd + "test.txt"
    Sample.appendFile(path, data: "")
    
    do {
      try Sample.chmod(path, mode: "222")
      XCTAssertTrue(Sample.access(path, mode: Sample.W_OK))
      XCTAssertFalse(Sample.access(path, mode: Sample.R_OK))
      
      try manager.removeItemAtPath(path)
    } catch {}
  }
  
  func testAccessReadMode() {
    let path = cwd + "test.txt"
    Sample.appendFile(path, data: "")
    
    do {
      try Sample.chmod(path, mode: "444")
      XCTAssertTrue(Sample.access(path, mode: Sample.R_OK))
      XCTAssertFalse(Sample.access(path, mode: Sample.X_OK))

      try manager.removeItemAtPath(path)
    } catch {}
  }
  
  func testAccessExecuteMode() {
    let path = cwd + "test.txt"
    Sample.appendFile(path, data: "")
    
    do {
      try Sample.chmod(path, mode: "111")
      XCTAssertTrue(Sample.access(path, mode: Sample.X_OK))
      XCTAssertFalse(Sample.access(path, mode: Sample.W_OK))
      
      try manager.removeItemAtPath(path)
    } catch {}
  }
  
  func testReadFile() {
    let path = cwd + "test"
    let str = "hello world"
    Sample.appendFile(path, data: str)
    do {
      let content = try Sample.readFile(path)
      XCTAssertEqual(content, str)
      
      try manager.removeItemAtPath(path)
    } catch {}
  }
  
  func testWriteFile() {
    let path = cwd + "test"
    let str = "hello world"
    
    Sample.appendFile(path, data: "")
    do {
      try Sample.writeFile(path, data: "hello world")
      
      let content = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
      XCTAssertEqual(content, str)
      
      try manager.removeItemAtPath(path)
    } catch {}
  }
  
  func testChmodByString() {
    let path = cwd + "test"
    Sample.appendFile(path, data: "")
    
    do {
      let mode = "752"
      
      try Sample.chmod(path, mode: mode)
      let dict = try manager.attributesOfItemAtPath(path)
      let realMode = dict[NSFilePosixPermissions]
      
      XCTAssertEqual(realMode as? NSObject, 0o752)
      try manager.removeItemAtPath(path)
    } catch {}
  }
  
  func testChmodByOctal() {
    let path = cwd + "test"
    Sample.appendFile(path, data: "")
    
    do {
      let mode = 0o752
      
      try Sample.chmod(path, mode: mode)
      let dict = try manager.attributesOfItemAtPath(path)
      let realMode = dict[NSFilePosixPermissions]
      
      XCTAssertEqual(realMode as? NSObject, 0o752)
      try manager.removeItemAtPath(path)
    } catch {}
  }
  
  func testChown() {
    // unimplemented
  }
  
  func testRename() {
    let path = cwd + "test"
    
    do {
      try Sample.rename(path, another: "hello")
      XCTAssertFalse(manager.fileExistsAtPath(path))
      XCTAssertTrue(manager.fileExistsAtPath(cwd + "hello"))
      
      try manager.removeItemAtPath(cwd + "hello")
    } catch {}
  }
  
  func testRmdir() {
    let path = cwd + "dir"
    
    do {
      try Sample.mkdir(path)
      XCTAssertTrue(manager.fileExistsAtPath(path))
      try Sample.rmdir(path)
      XCTAssertFalse(manager.fileExistsAtPath(path))
    } catch {}
  }
  
  func testUnlink() {
    let path = cwd + "test"
    Sample.appendFile(path, data: "")
    
    do {
      try Sample.unlink(path)
      XCTAssertFalse(manager.fileExistsAtPath(path))
    } catch {}
  }
  
  func testStat() {
    let path = cwd + "test"
    Sample.appendFile(path, data: "")
    
    do {
      let stats = try Sample.stat(path)
      XCTAssertEqual(stats["NSFileSize"] as? Int, 0)
      XCTAssertEqual(stats["NSFilePosixPermissions"] as? Int, 420)
    } catch {}
  }
}
