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

struct TableView: View {
  var tableData: [Event]
  @AppStorage("showTotals") var showTotals = true

  @State private var sortOrder = [KeyPathComparator(\Event.year)]

  // For single selections:
  @State private var selectedEventID: UUID?

  // For multiple selections:
  // @State private var selectedEventID: Set<UUID> = []

  var body: some View {
    VStack {
      HStack {
        Table(
          sortedTableData,
          selection: $selectedEventID,
          sortOrder: $sortOrder) {
            TableColumn("Year", value: \.year) {
              Text($0.year)
            }
            .width(min: 50, ideal: 60, max: 100)

            TableColumn("Title", value: \.text)
        }

        if let selectedEvent = selectedEvent {
          EventView(event: selectedEvent)
            .frame(width: 250)
        } else {
          Text("Select an event for more details…")
            .font(.title3)
            .padding()
            .frame(width: 250)
        }
      }

      if showTotals {
        Text("\(tableData.count) \(tableData.count == 1 ? "entry" : "entries") displayed.")
          .padding(.bottom, 8)
      }
    }
  }

  var sortedTableData: [Event] {
    return tableData.sorted(using: sortOrder)
  }

  var selectedEvent: Event? {
    guard let selectedEventID = selectedEventID else {
      return nil
    }

    let event = tableData.first {
      $0.id == selectedEventID
    }
    return event
  }
}

struct TableView_Previews: PreviewProvider {
  static var previews: some View {
    TableView(tableData: [Event.sampleEvent])
  }
}
