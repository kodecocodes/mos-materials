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

import Combine
import AppKit

class TaskManager {
  var tasks: [Task]
  var timerCancellable: AnyCancellable?
  var timerState = TimerState.waiting
  let dataStore = DataStore()
  var refreshNeededSub: AnyCancellable?

  // Switch comments to change interactions
  // Change checkForBreakFinish(startTime:duration:) too
  let interaction = Alerter()
  // let interaction = Notifier()

  init() {
    tasks = dataStore.readTasks()

    let activeTaskIndex = tasks.firstIndex {
      $0.status == .inProgress
    }
    if let activeTaskIndex = activeTaskIndex {
      timerState = .runningTask(taskIndex: activeTaskIndex)
    }

    startTimer()

    refreshNeededSub = NotificationCenter.default
      .publisher(for: .dataRefreshNeeded)
      .sink { _ in
        self.tasks = self.dataStore.readTasks()
      }
  }

  func startTimer() {
    timerCancellable = Timer
      .publish(
        every: 1,
        tolerance: 0.5,
        on: .current,
        in: .common)
      .autoconnect()
      .sink { _ in
        self.checkTimings()
      }
  }

  func toggleTask() {
    if let activeTaskIndex = timerState.activeTaskIndex {
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
      timerState = .runningTask(taskIndex: nextTaskIndex)
    }

    dataStore.save(tasks: tasks)
  }

  func stopRunningTask(at taskIndex: Int) {
    tasks[taskIndex].complete()
    timerState = .waiting

    if taskIndex < tasks.count - 1 {
      startBreak(after: taskIndex)
    }

    dataStore.save(tasks: tasks)
  }

  func checkTimings() {
    let taskIsRunning = timerState.activeTaskIndex != nil

    switch timerState {
    case .runningTask(let taskIndex):
      checkForTaskFinish(activeTaskIndex: taskIndex)
    case
      .takingShortBreak(let startTime),
      .takingLongBreak(let startTime):
      if let breakDuration = timerState.breakDuration {
        checkForBreakFinish(
          startTime: startTime,
          duration: breakDuration)
      }
    default:
      break
    }

    if let appDelegate = NSApp.delegate as? AppDelegate {
      let (title, icon) = menuTitleAndIcon
      appDelegate.updateMenu(
        title: title,
        icon: icon,
        taskIsRunning: taskIsRunning)
    }
  }

  func checkForTaskFinish(activeTaskIndex: Int) {
    let activeTask = tasks[activeTaskIndex]
    if activeTask.progressPercent >= 100 {
      if activeTaskIndex == tasks.count - 1 {
        interaction.allTasksComplete()
      } else {
        interaction.taskComplete(
          title: activeTask.title,
          index: activeTaskIndex)
      }
      stopRunningTask(at: activeTaskIndex)
    }
  }

  func checkForBreakFinish(startTime: Date, duration: TimeInterval) {
    let elapsedTime = -startTime.timeIntervalSinceNow
    if elapsedTime >= duration {
      timerState = .waiting

      // Un-comment if using Alerter
      let response = interaction.breakOver()
      if response == .alertFirstButtonReturn {
        startNextTask()
      }

      // Un-comment if using Notifier
      //  interaction.startNextTaskFunc = startNextTask
      //  interaction.breakOver()
    }
  }

  func startBreak(after index: Int) {
    let oneSecondFromNow = Date(timeIntervalSinceNow: 1)
    if (index + 1).isMultiple(of: 4) {
      timerState = .takingLongBreak(startTime: oneSecondFromNow)
    } else {
      timerState = .takingShortBreak(startTime: oneSecondFromNow)
    }
  }
}
