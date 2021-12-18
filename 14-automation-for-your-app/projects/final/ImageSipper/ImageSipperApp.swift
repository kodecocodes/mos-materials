/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import Intents

@main
struct ImageSipperApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDel

  @StateObject var sipsRunner = SipsRunner()
  @StateObject var serviceProvider = ServiceProvider()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(sipsRunner)
        .onAppear {
          NSApp.servicesProvider = serviceProvider
        }
    }
  }
}

// Service to open image or folder from Services menu

class ServiceProvider: ObservableObject {
  @objc func openFileFromService(
    _ pboard: NSPasteboard,
    userData: String,
    error: NSErrorPointer
  ) {
    let fileType = NSPasteboard.PasteboardType("public.file-url")
    guard
      let filePath = pboard.pasteboardItems?.first?.string(forType: fileType),
      let url = URL(string: filePath) else {
        return
      }

    NSApp.activate(ignoringOtherApps: true)

    let fileManager = FileManager.default
    if fileManager.isFolder(url: url) {
      NotificationCenter.default.post(
        name: .serviceReceivedFolder,
        object: url)
    } else if fileManager.fileIsImage(url: url) {
      NotificationCenter.default.post(
        name: .serviceReceivedImage,
        object: url)
    }
  }
}

extension Notification.Name {
  static let serviceReceivedImage = Notification.Name("serviceReceivedImage")
  static let serviceReceivedFolder = Notification.Name("serviceReceivedFolder")
}

// To refresh Services menu during testing:
//
//  /System/Library/CoreServices/pbs -flush
//  /System/Library/CoreServices/pbs -update


// Shortcuts intent to change image resolution

class AppDelegate: NSObject, NSApplicationDelegate {
  func application(_ application: NSApplication, handlerFor intent: INIntent) -> Any? {
    if intent is ChangeDpiIntent {
      return IntentHandler()
    }
    return nil
  }
}

class IntentHandler: NSObject, ChangeDpiIntentHandling {
  func handle(intent: ChangeDpiIntent) async -> ChangeDpiIntentResponse {
    guard let fileUrl = intent.url?.fileURL else {
      return ChangeDpiIntentResponse(code: .continueInApp, userActivity: nil)
    }

    await SipsRunner().changeResolution(for: fileUrl, to: "72")
    return ChangeDpiIntentResponse(code: .success, userActivity: nil)
  }

  func resolveUrl(for intent: ChangeDpiIntent) async -> ChangeDpiUrlResolutionResult {
    guard
      let url = intent.url,
      let fileUrl = url.fileURL else {
        return .confirmationRequired(with: nil)
      }

    let fileManager = FileManager.default
    if !fileManager.fileCanChangeResolution(url: fileUrl) {
      return .unsupported()
    }

    return .success(with: url)
  }
}
