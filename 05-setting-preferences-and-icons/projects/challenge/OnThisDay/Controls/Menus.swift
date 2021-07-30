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

struct Menus: Commands {
  @AppStorage("showTotals") var showTotals = true
  @AppStorage("appearance") var appearance = AppAppearance.system

  var body: some Commands {
    CommandGroup(before: .help) {
      Button("APIzen.Date web site") {
        showApiWebSite()
      }
      .keyboardShortcut("/", modifiers: .command)
    }

    CommandMenu("Display") {
      Toggle(isOn: $showTotals) {
        Text("Show Totals")
      }.keyboardShortcut("t", modifiers: .command)

      Picker("Scheme", selection: $appearance) {
        ForEach(AppAppearance.allCases, id: \.self) {
          Text($0.rawValue).tag($0)
        }
      }
      .onReceive([appearance].publisher.first()) { value in
        AppAppearance.changeColorScheme(to: value)
      }
    }
  }

  func showApiWebSite() {
    let address = "https://apizen.date"
    guard let url = URL(string: address) else {
      fatalError("Invalid address")
    }
    NSWorkspace.shared.open(url)
  }
}

enum AppAppearance: String, CaseIterable {
  case light = "Light"
  case dark = "Dark"
  case system = "System"

  static func changeColorScheme(to scheme: AppAppearance) {
    @AppStorage("appearance") var appearance = AppAppearance.system

    appearance = scheme
    switch scheme {
    case .dark:
      NSApp.appearance = NSAppearance(named: .darkAqua)
    case .light:
      NSApp.appearance = NSAppearance(named: .aqua)
    case .system:
      NSApp.appearance = nil
    }
  }
}
