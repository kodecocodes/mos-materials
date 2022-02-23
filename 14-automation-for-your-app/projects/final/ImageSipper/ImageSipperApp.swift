/// Copyright (c) 2022 Razeware LLC
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
  @StateObject var sipsRunner = SipsRunner()
  var serviceProvider = ServiceProvider()
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDel

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

// To refresh Services menu during testing:
//
//  /System/Library/CoreServices/pbs -flush
//  /System/Library/CoreServices/pbs -update

class ServiceProvider {
  @objc func openFromService(
    _ pboard: NSPasteboard,
    userData: String,
    error: NSErrorPointer
  ) {
    let fileType = NSPasteboard.PasteboardType.fileURL
    guard
      let filePath = pboard.pasteboardItems?.first?
        .string(forType: fileType),
      let url = URL(string: filePath) else {
        return
      }

    NSApp.activate(ignoringOtherApps: true)

    let fileManager = FileManager.default
    if fileManager.isFolder(url: url) {
      NotificationCenter.default.post(
        name: .serviceReceivedFolder,
        object: url)
    } else if fileManager.isImageFile(url: url) {
      NotificationCenter.default.post(
        name: .serviceReceivedImage,
        object: url)
    }
  }
}

extension Notification.Name {
  static let serviceReceivedImage =
  Notification.Name("serviceReceivedImage")
  static let serviceReceivedFolder =
  Notification.Name("serviceReceivedFolder")
}

// If Intent doesn't appear, delete derived data
//
// rm -rf ~/Library/Developer/Xcode/DerivedData

class PrepareForWebIntentHandler: NSObject, PrepareForWebIntentHandling {
  func handle(intent: PrepareForWebIntent) async -> PrepareForWebIntentResponse {
    guard let fileURL = intent.url?.fileURL else {
      return PrepareForWebIntentResponse(
        code: .continueInApp,
        userActivity: nil)
    }

    await SipsRunner().prepareForWeb(fileURL)

    return PrepareForWebIntentResponse(code: .success, userActivity: nil)
  }

  func resolveUrl(for intent: PrepareForWebIntent) async -> INFileResolutionResult {
    guard let url = intent.url else {
      return .confirmationRequired(with: nil)
    }
    return .success(with: url)
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func application(
    _ application: NSApplication,
    handlerFor intent: INIntent
  ) -> Any? {
    if intent is PrepareForWebIntent {
      return PrepareForWebIntentHandler()
    }
    return nil
  }
}
