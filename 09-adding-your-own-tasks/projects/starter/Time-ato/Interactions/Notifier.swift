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
import UserNotifications

class Notifier: NSObject {
  var startNextTaskFunc: (() -> Void)?

  override init() {
    super.init()
    defineActionCategory()
  }

  func taskComplete(title: String, index: Int) {
    var breakLength = "\(Int(TaskTimes.shortBreakTime / 60))"
    if (index + 1).isMultiple(of: 4) {
      breakLength = "\(Int(TaskTimes.longBreakTime / 60))"
    }

    let notificationTitle = "Task Complete"
    let message = "The \"\(title)\" task is complete.\n\n" +
    "Time to take a \(breakLength) minute break."

    sendNotification(title: notificationTitle, message: message)
  }

  func allTasksComplete() {
    let notificationTitle = "All Tasks Complete"
    let message = "Congratulations!\n\n" +
    "All your tasks for today are complete."

    sendNotification(title: notificationTitle, message: message)
  }

  func breakOver() {
    let notificationTitle = "Break Over"
    let message = "Your break time has finished.\n\n" +
    "Start your next task now or use the menu to start it when you're ready."

    sendNotification(
      title: notificationTitle,
      message: message,
      category: "ACTIONS_CATEGORY")
  }

  func sendNotification(
    title: String,
    message: String,
    category: String? = nil
  ) {
    checkNotificationPermissions()

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = message
    content.sound = .default
    content.interruptionLevel = .active

    if let category = category {
      content.categoryIdentifier = category
    }

    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: nil)

    UNUserNotificationCenter.current().add(request)
  }
}

extension Notifier: UNUserNotificationCenterDelegate {
  /// Check notification permissions and request if not already granted.
  func checkNotificationPermissions() {
    UNUserNotificationCenter.current()
      .requestAuthorization(
        options: [.alert, .sound]
      ) { _, error in
        if let error = error {
          print(error.localizedDescription)
        }
      }
  }

  /// Set up an action and action category so the notification can show an action button.
  func defineActionCategory() {
    let startNextAction = UNNotificationAction(
      identifier: "START_NEXT_ACTION",
      title: "Start Next Task")

    let category = UNNotificationCategory(
      identifier: "ACTIONS_CATEGORY",
      actions: [startNextAction],
      intentIdentifiers: [])

    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.delegate = self
    notificationCenter.setNotificationCategories([category])
  }

  /// Wait for the user to interact with the notification.
  /// Check if they have clicked an action button.
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler:
    @escaping () -> Void
  ) {
    switch response.actionIdentifier {
    case "START_NEXT_ACTION":
      startNextTaskFunc?()
    default:
      break
    }
    completionHandler()
  }

  /// Present notification as a banner even if the menu is open.
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler(.banner)
  }
}
