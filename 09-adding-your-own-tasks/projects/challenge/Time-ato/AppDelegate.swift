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

import Cocoa
import SwiftUI
import LaunchAtLogin

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  var statusItem: NSStatusItem?
  @IBOutlet weak var statusMenu: NSMenu!
  var menuManager: MenuManager?

  @IBOutlet weak var startStopMenuItem: NSMenuItem!
  @IBOutlet weak var launchOnLoginMenuItem: NSMenuItem!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    statusItem = NSStatusBar.system.statusItem(
      withLength: NSStatusItem.variableLength)

    statusItem?.menu = statusMenu

    statusItem?.button?.title = "Time-ato"
    statusItem?.button?.imagePosition = .imageLeading
    statusItem?.button?.image = NSImage(
      systemSymbolName: "timer",
      accessibilityDescription: "Time-ato")

    statusItem?.button?.font = NSFont.monospacedDigitSystemFont(
      ofSize: NSFont.systemFontSize,
      weight: .regular)

    menuManager = MenuManager(statusMenu: statusMenu)
    statusMenu.delegate = menuManager

    // Un-comment this to print out the app location
    // print(Bundle.main.bundlePath)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // Challenge
  @IBAction func showAbout(_ sender: Any) {
    NSApp.activate(ignoringOtherApps: true)
    NSApp.orderFrontStandardAboutPanel(nil)
  }

  @IBAction func startStopTask(_ sender: Any) {
    menuManager?.taskManager.toggleTask()
  }

  @IBAction func showEditTasksWindow(_ sender: Any) {
    let hostingController = NSHostingController(
      rootView: EditTasksView())

    let window = NSWindow(contentViewController: hostingController)
    window.title = "Edit Tasks"

    let controller = NSWindowController(window: window)

    NSApp.activate(ignoringOtherApps: true)
    controller.showWindow(nil)
  }

  @IBAction func toggleLaunchOnLogin(_ sender: Any) {
    LaunchAtLogin.isEnabled.toggle()
  }

  func updateMenu(title: String, icon: String, taskIsRunning: Bool) {
    statusItem?.button?.title = title
    statusItem?.button?.image =
    NSImage(systemSymbolName: icon, accessibilityDescription: title)

    updateMenuItemTitles(taskIsRunning: taskIsRunning)

    if menuManager?.menuIsOpen == true {
      menuManager?.updateMenuItems()
    }
  }

  func updateMenuItemTitles(taskIsRunning: Bool) {
    if taskIsRunning {
      startStopMenuItem.title = "Mark Task as Complete"
    } else {
      startStopMenuItem.title = "Start Next Task"
    }

    launchOnLoginMenuItem.state = LaunchAtLogin.isEnabled ? .on : .off
  }
}
