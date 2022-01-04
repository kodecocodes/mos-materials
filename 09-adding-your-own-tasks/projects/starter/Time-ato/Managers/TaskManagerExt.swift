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

import Foundation

extension TaskManager {
  var menuTitleAndIcon: (title: String, icon: String) {
    switch timerState {
    case .runningTask(let taskIndex):
      let task = tasks[taskIndex]
      if let startTime = task.startTime {
        let remainingTime = differenceToHourMinFormat(
          start: startTime,
          duration: TaskTimes.taskTime)
        return ("\(task.title) - \(remainingTime)", task.status.iconName)
      } else {
        return ("Time-ato", "timer")
      }
    case .takingShortBreak(let startTime):
      let remainingTime = differenceToHourMinFormat(
        start: startTime,
        duration: TaskTimes.shortBreakTime)
      return ("Short Break - \(remainingTime)", "cup.and.saucer")
    case .takingLongBreak(let startTime):
      let remainingTime = differenceToHourMinFormat(
        start: startTime,
        duration: TaskTimes.longBreakTime)
      return ("Long Break - \(remainingTime)", "figure.walk")
    case .waiting:
      return ("Time-ato", "timer")
    }
  }

  func differenceToHourMinFormat(start: Date, duration: TimeInterval) -> String {
    let endTime = start.addingTimeInterval(duration)
    let remainingTime = endTime.timeIntervalSince(Date())
    if let difference = dateFormatter.string(from: remainingTime) {
      return difference
    }
    return ""
  }
}

var dateFormatter: DateComponentsFormatter = {
  let formatter = DateComponentsFormatter()
  formatter.allowedUnits = [.minute, .second]
  formatter.zeroFormattingBehavior = .pad
  return formatter
}()
