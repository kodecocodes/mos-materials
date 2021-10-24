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

import AppKit
import Combine

class MenuManager: NSObject, NSMenuDelegate {
  var statusMenu: NSMenu
  var menuIsOpen = false

  var updateNeededFlag: AnyCancellable?
  var taskManager = TaskManager()

  let itemsBeforeTasks = 2
  let itemsAfterTasks = 6

  var useVC = false

  init(statusMenu: NSMenu) {
    self.statusMenu = statusMenu
    super.init()

    updateNeededFlag = NotificationCenter.default
      .publisher(for: .updateNeeded)
      .sink { _ in
        self.updateMenu()
      }
  }

  func menuWillOpen(_ menu: NSMenu) {
    updateMenu()
    showTasksInMenu()
    menuIsOpen = true
  }

  func menuDidClose(_ menu: NSMenu) {
    menuIsOpen = false
  }

  func clearTasksFromMenu() {
    for _ in itemsBeforeTasks ..< statusMenu.items.count - itemsAfterTasks {
      statusMenu.removeItem(at: itemsBeforeTasks)
    }
  }

  func showTasksInMenu() {
    clearTasksFromMenu()

    if useVC {
      showTasksInMenuVC()
      return
    }

    var index = itemsBeforeTasks
    let itemFrame = NSRect(x: 0, y: 0, width: 270, height: 40)

    for task in taskManager.tasks {
      let view = TaskView(frame: itemFrame)
      view.task = task

      let item = NSMenuItem()
      item.view = view

      statusMenu.insertItem(item, at: index)
      index += 1

      if task.id.isMultiple(of: 4) {
        statusMenu.insertItem(NSMenuItem.separator(), at: index)
        index += 1
      }
    }
  }

  func showTasksInMenuVC() {
    var index = itemsBeforeTasks

    for task in taskManager.tasks {
      let taskVC = TaskViewController(nibName: "TaskViewController", bundle: nil)
      taskVC.task = task

      let item = NSMenuItem()
      item.view = taskVC.view
      statusMenu.insertItem(item, at: index)
      index += 1

      if task.id.isMultiple(of: 4) {
        statusMenu.insertItem(NSMenuItem.separator(), at: index)
        index += 1
      }
    }
  }

  func updateMenu() {
    if let appDelegate = NSApp.delegate as? AppDelegate {
      let (title, icon) = taskManager.menuTitleAndIcon
      appDelegate.statusItem?.button?.title = title
      appDelegate.statusItem?.button?.image =
      NSImage(systemSymbolName: icon, accessibilityDescription: nil)

      let taskIsRunning = taskManager.activeTaskIndex != nil
      appDelegate.updateControlMenuItem(taskIsRunning: taskIsRunning)

      if !menuIsOpen {
        return
      }

      if useVC {
        updateTimerVCsInMenu()
        return
      }

      for item in statusMenu.items {
        if let view = item.view as? TaskView {
          view.setNeedsDisplay(.infinite)
        }
      }
    }
  }

  func updateTimerVCsInMenu() {
    var index = itemsBeforeTasks

    for task in taskManager.tasks {
      let item = statusMenu.items[index]
      let taskVC = TaskViewController(nibName: "TaskViewController", bundle: nil)
      taskVC.task = task
      item.view = taskVC.view
      index += 1

      if task.id.isMultiple(of: 4) {
        index += 1
      }
    }
  }
}
