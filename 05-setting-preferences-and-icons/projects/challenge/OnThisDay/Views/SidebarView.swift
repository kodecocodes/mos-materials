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

struct SidebarView: View {
  @Binding var selection: EventType?

  @EnvironmentObject var appState: AppState

  @AppStorage("showTotals") var showTotals = true
  @AppStorage("showBirths") var showBirths = true
  @AppStorage("showDeaths") var showDeaths = true

  @SceneStorage("selectedDate") var selectedDate: String?

  var body: some View {
    VStack {
      List(selection: $selection) {
        Section(selectedDate?.uppercased() ?? "TODAY") {
          ForEach(validTypes, id: \.self) { type in
            Text(type.rawValue)
              .badge(
                showTotals
                ? appState.countFor(eventType: type, date: selectedDate)
                : 0)
          }
        }

        Section("AVAILABLE DATES") {
          ForEach(appState.sortedDates, id: \.self) { date in
            Button {
              selectedDate = date
            } label: {
              HStack {
                Text(date)
                Spacer()
              }
            }
            .controlSize(.large)
            .modifier(DateButtonViewModifier(selected: date == selectedDate))
          }
        }
      }
      .listStyle(.sidebar)

      Spacer()
      DayPicker()
    }
    .frame(minWidth: 220)
  }

  var validTypes: [EventType] {
    var types = [EventType.events]
    if showBirths {
      types.append(.births)
    }
    if showDeaths {
      types.append(.deaths)
    }
    return types
  }
}

struct DateButtonViewModifier: ViewModifier {
  var selected: Bool

  func body(content: Content) -> some View {
    if selected {
      content
        .buttonStyle(.borderedProminent)
    } else {
      content
    }
  }
}
