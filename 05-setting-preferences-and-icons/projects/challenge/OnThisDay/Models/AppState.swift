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

import Foundation

class AppState: ObservableObject {
  @Published var days: [String: Day] = [:]

  @Published var loadingError = false
  @Published var isLoading = false

  init(isPreview: Bool = false) {
    if isPreview {
      return
    }

    Task {
      await getToday()
    }
  }

  @MainActor func getToday() async {
    let (month, day) = currentMonthAndDay()
    await getDataFor(month: month, day: day)
  }

  @MainActor func getDataFor(month: Int, day: Int) async {
    loadingError = false
    isLoading = true

    defer {
      isLoading = false
    }

    let monthName = Calendar.current.monthSymbols[month - 1]
    let dateString = "\(monthName) \(day)"
    if days[dateString] != nil {
      return
    }

    do {
      let newData = try await Networker.getDataForDay(month: month, day: day)
      days[newData.displayDate] = newData
    } catch {
      loadingError = true
    }
  }

  func toggleEventsFor(date: String?) {
    if let date = date, let day = days[date] {
      days[date] = nil
      days[date] = day
    }
  }

  func currentMonthAndDay() -> (monthNum: Int, dayNum: Int) {
    let calendarDate = Calendar.current.dateComponents([.day, .month], from: Date())

    if let dayNum = calendarDate.day, let monthNum = calendarDate.month {
      return (monthNum, dayNum)
    }
    return (1, 1)
  }

  var sortedDates: [String] {
    let monthNames = Calendar.current.monthSymbols

    let dates = days.values.compactMap { day in
      return day.displayDate
    }

    let sortedDates = dates.sorted { lhs, rhs in
      let lhParts = lhs.components(separatedBy: " ")
      let rhParts = rhs.components(separatedBy: " ")
      let lhMonth = lhParts[0]
      let rhMonth = rhParts[0]
      let lhDay = Int(lhParts[1]) ?? 32
      let rhDay = Int(rhParts[1]) ?? 32
      let lhMonthNumber = monthNames.firstIndex(of: lhMonth) ?? 13
      let rhMonthNumber = monthNames.firstIndex(of: rhMonth) ?? 13
      return (lhMonthNumber * 100 + lhDay) < (rhMonthNumber * 100 + rhDay)
    }

    return sortedDates
  }

  func countFor(date: String?, eventType: EventType?) -> Int {
    if let date = date, let day = days[date] {
      let events: [Event]
      switch eventType {
      case .births:
        events = day.births
      case .deaths:
        events = day.deaths
      case .events:
        events = day.events
      case .none:
        events = []
      }

      return events.count
    }
    return 0
  }

  func dataFor(date: String?, eventType: EventType?, searchText: String) -> [Event] {
    if let date = date {
      if let day = days[date] {
        let events: [Event]
        switch eventType {
        case .births:
          events = day.births
        case .deaths:
          events = day.deaths
        case .events:
          events = day.events
        case .none:
          events = []
        }

        if searchText.isEmpty {
          return events
        } else {
          let searchTextLower = searchText.lowercased()
          let filteredEntries = events.filter { event in
            event.text.lowercased().contains(searchTextLower)
          }
          return filteredEntries
        }
      } else {
        downloadMissingEvents(for: date)
      }
    }
    return []
  }

  func downloadMissingEvents(for date: String) {
    if isLoading {
      return
    }

    isLoading = true
    let dateParts = date.components(separatedBy: " ")
    if dateParts.count < 2 {
      return
    }
    guard let day = Int(dateParts[1]) else {
      return
    }
    guard let monthIndex = Calendar.current.monthSymbols.firstIndex(of: dateParts[0]) else {
      return
    }

    Task {
      await getDataFor(month: monthIndex + 1, day: day)
    }
  }
}

extension AppState {
  func readSampleData() {
    guard let url = Bundle.main.url(forResource: "SampleData", withExtension: "json") else {
      return
    }

    do {
      let data = try Data(contentsOf: url)
      let newData = try JSONDecoder().decode(Day.self, from: data)
      days[newData.displayDate] = newData
      print("got sample data")
    } catch {
      print(error)
    }
  }
}
