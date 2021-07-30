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

enum ViewType: Int {
  case grid
  case table
}

struct MainView: View {
  @EnvironmentObject var appState: AppState

  @AppStorage("showBirths") var showBirths = true
  @AppStorage("showDeaths") var showDeaths = true

  @SceneStorage("selectedDate") var selectedDate: String?
  @SceneStorage("viewType") var viewType = ViewType.grid
  @SceneStorage("eventType") var eventType: EventType?

  var body: some View {
    Group {
      if appState.days.isEmpty {
        LoadingView(loadingError: appState.loadingError)
      } else if viewType == .table {
        TableView()
      } else {
        GridView()
      }
    }
    .toolbar { Toolbar(viewType: $viewType) }
    .navigationTitle(Text(navTitle))
    .onAppear {
      if selectedDate == nil {
        selectedDate = today()
        eventType = .events
        viewType = .grid
      }
    }
    .onChange(of: showBirths) { _ in
      if eventType == .births {
        eventType = .events
        appState.toggleEventsFor(date: selectedDate)
      }
    }
    .onChange(of: showDeaths) { _ in
      if eventType == .deaths {
        eventType = .events
        appState.toggleEventsFor(date: selectedDate)
      }
    }
  }

  var navTitle: String {
    if let date = selectedDate, let type = eventType {
      return "\(date) - \(type.rawValue)"
    }
    return "On This Day"
  }

  func today() -> String? {
    let calendarDate = Calendar.current.dateComponents([.day, .month], from: Date())

    if let dayNum = calendarDate.day, let monthNum = calendarDate.month {
      let month = Calendar.current.monthSymbols[monthNum - 1]
      return "\(month) \(dayNum)"
    }
    return nil
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    let appState = AppState(isPreview: true)
    appState.readSampleData()

    return MainView()
      .environmentObject(appState)
      .frame(maxWidth: .infinity)
  }
}

struct LoadingView: View {
  var loadingError: Bool

  var body: some View {
    if loadingError {
      Text("There was a problem loading the events, probably due to too many requests. Please try again in a minute.")
    } else {
      VStack {
        ProgressView()
          .padding()
        Text("Loading today's events…")
          .font(.title3)
      }
    }
  }
}
