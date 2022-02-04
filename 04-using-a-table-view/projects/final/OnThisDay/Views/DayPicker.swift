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

struct DayPicker: View {
  @EnvironmentObject var appState: AppState

  @SceneStorage("selectedDate") var selectedDate: String?

  @State private var month = "January"
  @State private var day = 1

  var body: some View {
    VStack {
      Text("Select a Date")

      HStack {
        Picker("", selection: $month) {
          ForEach(appState.englishMonthNames, id: \.self) {
            Text($0)
          }
        }
        .pickerStyle(.menu)

        Picker("", selection: $day) {
          ForEach(1 ... maxDays, id: \.self) {
            Text("\($0)")
          }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: 60)
        .padding(.trailing, 10)
      }

      if appState.isLoading {
        ProgressView()
          .frame(height: 28)
      } else {
        Button("Get Events") {
          Task {
            await getNewEvents()
          }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
    }
    .padding()
  }

  var maxDays: Int {
    switch month {
    case "February":
      return 29
    case "April", "June", "September", "November":
      return 30
    default:
      return 31
    }
  }

  func getNewEvents() async {
    let monthIndex = appState.englishMonthNames
      .firstIndex(of: month) ?? 0
    let monthNumber = monthIndex + 1
    await appState.getDataFor(month: monthNumber, day: day)
    selectedDate = "\(month) \(day)"
  }
}

struct DayPicker_Previews: PreviewProvider {
  static var previews: some View {
    DayPicker()
      .environmentObject(AppState())
      .frame(width: 200)
  }
}
