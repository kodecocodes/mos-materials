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

import AppKit

struct Task: Identifiable, Codable {
  let id: UUID
  var title: String
  var status: TaskStatus = .notStarted
  var startTime: Date?

  var progressPercent: Double {
    switch status {
    case .notStarted:
      return 0
    case .inProgress:
      if let startTime = startTime {
        let elapsedTime = -startTime.timeIntervalSinceNow
        let percentTime = elapsedTime / TaskTimes.taskTime
        return percentTime * 100
      }
      return 0
    case .complete:
      return 100
    }
  }

  mutating func start() {
    status = .inProgress
    startTime = Date(timeIntervalSinceNow: 1)
  }

  mutating func complete() {
    status = .complete
  }

  mutating func reset() {
    status = .notStarted
    startTime = nil
  }
}

extension Task {
  static var sampleTasks: [Task] = [
    Task(id: UUID(), title: "Communications"),
    Task(id: UUID(), title: "Status Meeting"),
    Task(id: UUID(), title: "Project ABC - Ticket 42a"),
    Task(id: UUID(), title: "Project ABC - Ticket 42b"),
    Task(id: UUID(), title: "Project ABC - Ticket 42c"),
    Task(id: UUID(), title: "Testing"),
    Task(id: UUID(), title: "Documentation"),
    Task(id: UUID(), title: "Project ABC - Ticket 123")
  ]

  static var sampleTasksWithStatus: [Task] = [
    Task(
      id: UUID(),
      title: "Communications",
      status: .complete,
      startTime: Date(timeIntervalSinceNow: -600)),
    Task(
      id: UUID(),
      title: "Status Meeting",
      status: .complete,
      startTime: Date(timeIntervalSinceNow: -300)),
    Task(
      id: UUID(),
      title: "Project ABC - Ticket 42a",
      status: .inProgress,
      startTime: Date(timeIntervalSinceNow: -60)),
    Task(id: UUID(), title: "Project ABC - Ticket 42b"),
    Task(id: UUID(), title: "Project ABC - Ticket 42c"),
    Task(id: UUID(), title: "Testing"),
    Task(id: UUID(), title: "Documentation"),
    Task(id: UUID(), title: "Project ABC - Ticket 123")
  ]
}
