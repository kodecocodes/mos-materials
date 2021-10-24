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

struct DataStore {
  func readTasks() -> [Task] {
    guard let url = dataFileURL() else {
      return []
    }

    do {
      let data = try Data(contentsOf: url)
      let tasks = try JSONDecoder()
        .decode([Task].self, from: data)
      let sortedTasks = reassignIDs(tasks: tasks)
      return sortedTasks
    } catch {
      return []
    }
  }

  func save(tasks: [Task]) {
    let tasksToSave = reassignIDs(tasks: tasks)

    guard
      let url = dataFileURL(),
      let data = try? JSONEncoder().encode(tasksToSave) else {
        return
      }

    try? data.write(to: url)
  }

  func dataFileURL() -> URL? {
    let fileManager = FileManager.default

    do {
      let docsFolder = try fileManager.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      let dataURL = docsFolder.appendingPathComponent("Tasks.json")
      return dataURL
    } catch {
      return nil
    }
  }

  func checkForReset(tasks: [Task]) -> [Task] {
    // When tasks are loaded in, if any are complete or in progress
    // check their dates to see if they are today.
    // If not, reset them all.
    let startTimes = tasks.compactMap {
      $0.startTime
    }
    if startTimes.isEmpty {
      return tasks
    }

    let calendar = Calendar.current
    for startTime in startTimes {
      if !calendar.isDateInToday(startTime) {
        let resetTasks = tasks.map { task -> Task in
          var resetTask = task
          resetTask.reset()
          return resetTask
        }
        return resetTasks
      }
    }

    return tasks
  }

  func reassignIDs(tasks: [Task]) -> [Task] {
    var sortedTasks = tasks.sorted { $0.id < $1.id }
    for index in 0 ..< sortedTasks.count {
      sortedTasks[index].id = index + 1
    }
    return sortedTasks
  }
}
