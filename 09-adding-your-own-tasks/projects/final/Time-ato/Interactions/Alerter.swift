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

struct Alerter {
  func taskComplete(title: String, index: Int) {
    var breakLength = "\(Int(TaskTimes.shortBreakTime / 60))"
    if (index + 1).isMultiple(of: 4) {
      breakLength = "\(Int(TaskTimes.longBreakTime / 60))"
    }
    let message = "The \"\(title)\" task is complete.\n\n" +
    "Time to take a \(breakLength) minute break."

    openAlert(title: "Task Complete", message: message, buttonTitles: ["Start Break"])
  }

  func allTasksComplete() {
    let message = "Congratulations!\n\n" +
    "All your tasks for today are complete."

    openAlert(title: "All Tasks Complete", message: message)
  }

  func breakOver() -> NSApplication.ModalResponse {
    let message = "Your break time has finished.\n\n" +
    "Start your next task now or use the menu to start it when you're ready."

    let buttonTitles = ["Start Next Task", "OK"]

    let response = openAlert(
      title: "Break Over",
      message: message,
      buttonTitles: buttonTitles)
    return response
  }

  @discardableResult
  func openAlert(
    title: String,
    message: String,
    buttonTitles: [String] = []
  ) -> NSApplication.ModalResponse {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message

    for buttonTitle in buttonTitles {
      alert.addButton(withTitle: buttonTitle)
    }

    NSApp.activate(ignoringOtherApps: true)

    let response = alert.runModal()
    return response
  }
}
