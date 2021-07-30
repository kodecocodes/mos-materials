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

struct TableView: View {
  @EnvironmentObject var appState: AppState

  @AppStorage("showTotals") var showTotals = true

  @SceneStorage("selectedDate") var selectedDate: String?
  @SceneStorage("searchText") var searchText = ""
  @SceneStorage("eventType") var eventType: EventType?

  @State private var sortOrder = [KeyPathComparator(\Event.year)]
  @State private var selectedEventId: UUID?

  var body: some View {
    VStack {
      HStack {
        Table(tableData, selection: $selectedEventId, sortOrder: $sortOrder) {
          TableColumn("Year", value: \.year)
            .width(60)
          TableColumn("Title", value: \.text) {
            Text($0.text)
          }
        }
        // .tableStyle(.bordered(alternatesRowBackgrounds: false))
        .searchable(text: $searchText, prompt: "Search…")

        if let selectedEvent = selectedEvent {
          EventView(event: selectedEvent)
            .frame(width: 250)
        } else {
          Text("Select an event for more details…")
            .font(.title3)
            .padding(20)
        }
      }
      .padding([.top, .horizontal])
      .padding(.bottom, showTotals ? 0 : 8)

      Spacer()

      if showTotals {
        Text("\(tableData.count) \(tableData.count == 1 ? "entry" : "entries") displayed.")
          .padding(.bottom, 8)
      }
    }
  }

  var tableData: [Event] {
    let events = appState.dataFor(date: selectedDate, eventType: eventType, searchText: searchText)
    return events.sorted(using: sortOrder)
  }

  var selectedEvent: Event? {
    guard let id = selectedEventId else {
      return nil
    }

    let event = tableData.first {
      $0.id == id
    }
    return event
  }
}

struct TableView_Previews: PreviewProvider {
  static var previews: some View {
    let appState = AppState(isPreview: true)
    appState.readSampleData()

    return TableView()
      .environmentObject(appState)
  }
}
