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
import Combine
import AppKit

class TaskManager {
  var tasks: [Task] = []
  var dataStore = DataStore()

  var onShortBreak = false
  var onLongBreak = false
  var breakStartTime: Date?

  var timerCancellable: AnyCancellable?
  var refreshNeededFlag: AnyCancellable?

  var activeTaskIndex: Int? {
    return tasks.firstIndex {
      $0.status == .inProgress
    }
  }

  var interaction = Alerter()
  // let interaction = Notifier()

  init() {
    let storedTasks = dataStore.readTasks()
    if storedTasks.isEmpty {
      // FOR TESTING
      tasks = Task.sampleTasks
    } else {
      tasks = dataStore.checkForReset(tasks: storedTasks)
      startTimerPublisher()
    }

    refreshNeededFlag = NotificationCenter.default
      .publisher(for: .dataRefreshNeeded)
      .sink { _ in
        self.tasks = self.dataStore.readTasks()
      }

    interaction.startNextTaskFunc = startNextTask
  }

  // MARK: - Timer

  func startTimerPublisher() {
    timerCancellable = Timer.publish(
      every: 1,
      tolerance: 0.5,
      on: .current,
      in: .common)
      .autoconnect()
      .sink { [self] time in
        checkTasks(at: time)
      }
  }

  func stopTimerPublisher() {
    timerCancellable?.cancel()
    timerCancellable = nil
  }

  func checkTasks(at time: Date) {
    if let activeTaskIndex = activeTaskIndex {
      let activeTask = tasks[activeTaskIndex]
      if activeTask.progressPercent >= 100 {
        if activeTaskIndex == tasks.count - 1 {
          interaction.allTasksComplete()
        } else {
          interaction.taskComplete(task: activeTask)
        }

        stopRunningTask(at: activeTaskIndex)
        return
      }
    }

    if let breakStartTime = breakStartTime {
      let elapsedTime = -breakStartTime.timeIntervalSinceNow
      let maxTime = onLongBreak
      ? TaskTimes.longBreakTime
      : TaskTimes.shortBreakTime
      if elapsedTime >= maxTime {
        stopBreak()
        interaction.breakOver()
      }
    }

    NotificationCenter.default.post(name: .updateNeeded, object: nil)
  }

  // MARK: - Start & Stop

  func toggleTask() {
    if let activeTaskIndex = activeTaskIndex {
      stopRunningTask(at: activeTaskIndex)
    } else {
      startNextTask()
    }
  }

  func startNextTask() {
    let nextTaskIndex = tasks.firstIndex {
      $0.status == .notStarted
    }
    if let nextTaskIndex = nextTaskIndex {
      tasks[nextTaskIndex].start()
      startTimerPublisher()
    }

    stopBreak()

    NotificationCenter.default.post(name: .updateNeeded, object: nil)
    dataStore.save(tasks: tasks)
  }

  func stopRunningTask(at taskIndex: Int) {
    tasks[taskIndex].complete()

    if taskIndex == tasks.count - 1 {
      stopTimerPublisher()
    } else {
      startBreak(after: tasks[taskIndex])
    }

    NotificationCenter.default.post(name: .updateNeeded, object: nil)
    dataStore.save(tasks: tasks)
  }

  func startBreak(after task: Task) {
    if task.id.isMultiple(of: 4) {
      onLongBreak = true
    } else {
      onShortBreak = true
    }
    breakStartTime = Date(timeIntervalSinceNow: 1)
  }

  func stopBreak() {
    onShortBreak = false
    onLongBreak = false
    breakStartTime = nil
  }

  // MARK: - Menu info

  var menuTitleAndIcon: (title: String, icon: String) {
    if let activeTaskIndex = activeTaskIndex {
      let task = tasks[activeTaskIndex]
      if let startTime = task.startTime {
        let remainingTime = differenceToHourMinFormat(
          start: startTime,
          duration: TaskTimes.taskTime
        )
        return ("\(task.title) - \(remainingTime)", task.status.iconName)
      }
    }

    if onShortBreak, let startTime = breakStartTime {
      let remainingTime = differenceToHourMinFormat(
        start: startTime,
        duration: TaskTimes.shortBreakTime
      )
      return ("Short Break - \(remainingTime)", "cup.and.saucer")
    }

    if onLongBreak, let startTime = breakStartTime {
      let remainingTime = differenceToHourMinFormat(
        start: startTime,
        duration: TaskTimes.longBreakTime
      )
      return ("Long Break - \(remainingTime)", "figure.walk")
    }

    return ("Time-ato", "timer")
  }

  func differenceToHourMinFormat(start: Date, duration: TimeInterval)
  -> String {
    let endTime = start.addingTimeInterval(duration)
    let remainingTime = endTime.timeIntervalSince(Date())
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = .pad
    if let difference = formatter.string(from: remainingTime) {
      return difference
    }
    return (Date() ..< endTime).formatted(.timeDuration)
  }
}
