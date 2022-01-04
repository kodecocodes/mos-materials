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

class MenuManager: NSObject, NSMenuDelegate {
  let statusMenu: NSMenu
  var menuIsOpen = false

  let taskManager = TaskManager()

  let itemsBeforeTasks = 2
  let itemsAfterTasks = 6

  init(statusMenu: NSMenu) {
    self.statusMenu = statusMenu
    super.init()
  }

  func menuWillOpen(_ menu: NSMenu) {
    menuIsOpen = true
    showTasksInMenu()
  }

  func menuDidClose(_ menu: NSMenu) {
    menuIsOpen = false
    clearTasksFromMenu()
  }

  func clearTasksFromMenu() {
    let stopAtIndex = statusMenu.items.count - itemsAfterTasks

    for _ in itemsBeforeTasks ..< stopAtIndex {
      statusMenu.removeItem(at: itemsBeforeTasks)
    }
  }

  func showTasksInMenu() {
    var index = itemsBeforeTasks
    var taskCounter = 0

    let itemFrame = NSRect(x: 0, y: 0, width: 270, height: 40)

    for task in taskManager.tasks {
      let item = NSMenuItem()
      let view = TaskView(frame: itemFrame)
      view.task = task
      item.view = view

      statusMenu.insertItem(item, at: index)
      index += 1
      taskCounter += 1

      if taskCounter.isMultiple(of: 4) {
        statusMenu.insertItem(NSMenuItem.separator(), at: index)
        index += 1
      }
    }
  }

  func updateMenuItems() {
    for item in statusMenu.items {
      if let view = item.view as? TaskView {
        view.setNeedsDisplay(.infinite)
      }
    }
  }
}
