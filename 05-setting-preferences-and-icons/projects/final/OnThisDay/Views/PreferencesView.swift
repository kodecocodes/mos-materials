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

struct PreferencesView: View {
  var body: some View {
    TabView {
      ShowView()
        .tabItem {
          Image(systemName: "checkmark.circle")
          Text("Show")
        }

      AppearanceView()
        .tabItem {
          Image(systemName: "sun.min")
          Text("Appearance")
        }
    }
    .frame(width: 200, height: 150)
    .navigationTitle("Settings")
  }
}

struct PreferencesView_Previews: PreviewProvider {
  static var previews: some View {
    ShowView()
      .frame(width: 200, height: 150)

    AppearanceView()
      .frame(width: 200, height: 150)
  }
}

struct ShowView: View {
  @AppStorage("showBirths") var showBirths = true
  @AppStorage("showDeaths") var showDeaths = true
  @AppStorage("showTotals") var showTotals = true

  var body: some View {
    VStack(alignment: .leading) {
      Toggle("Show Births", isOn: $showBirths)
      Toggle("Show Deaths", isOn: $showDeaths)
      Toggle("Show Totals", isOn: $showTotals)
    }
  }
}

struct AppearanceView: View {
  @AppStorage("displayMode") var displayMode = DisplayMode.auto

  var body: some View {
    Picker("", selection: $displayMode) {
      Text("Light").tag(DisplayMode.light)
      Text("Dark").tag(DisplayMode.dark)
      Text("Automatic").tag(DisplayMode.auto)
    }
    .pickerStyle(.radioGroup)
  }
}
