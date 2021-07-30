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

struct GridView: View {
  @EnvironmentObject var appState: AppState

  @AppStorage("showTotals") var showTotals = true

  @SceneStorage("selectedDate") var selectedDate: String?
  @SceneStorage("searchText") var searchText = ""
  @SceneStorage("eventType") var eventType: EventType?

  var body: some View {
    VStack {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 40) {
          ForEach(gridData) {
            EventView(event: $0)
              .frame(width: 250, height: 350, alignment: .topLeading)
              .clipped()
              .border(.secondary, width: 1)
              .shadow(color: .primary.opacity(0.3), radius: 3, x: 3, y: 3)
              .padding(.bottom, 6)
          }
        }
        .searchable(text: $searchText, prompt: "Search…")
      }
      .padding(.top)
      .padding(.bottom, showTotals ? 0 : 8)

      Spacer()

      if showTotals {
        Text("\(gridData.count) \(gridData.count == 1 ? "entry" : "entries") displayed.")
          .padding(.bottom, 8)
      }
    }
  }

  var columns: [GridItem] {
    [GridItem(.adaptive(minimum: 250, maximum: 250), spacing: 20)]
  }

  var gridData: [Event] {
    appState.dataFor(date: selectedDate, eventType: eventType, searchText: searchText)
  }
}

struct GridView_Previews: PreviewProvider {
  static var previews: some View {
    let appState = AppState(isPreview: true)
    appState.readSampleData()

    return GridView()
      .environmentObject(appState)
      .frame(maxWidth: .infinity)
  }
}
