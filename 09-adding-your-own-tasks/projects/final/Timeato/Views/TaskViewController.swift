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

class TaskViewController: NSViewController {
  var task: Task?

  @IBOutlet weak var imageView: NSImageView!
  @IBOutlet weak var titleLabel: NSTextField!
  @IBOutlet weak var infoLabel: NSTextField!
  @IBOutlet weak var progressBar: NSProgressIndicator!

  override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    showTask()
  }

  func showTask() {
    guard let task = task else {
      return
    }

    let color = task.status.textColor

    titleLabel.stringValue = task.title
    titleLabel.textColor = color

    infoLabel.stringValue = task.status.statusText
    infoLabel.textColor = color

    imageView.image = NSImage(
      systemSymbolName: task.status.iconName,
      accessibilityDescription: task.status.statusText
    )
    imageView.contentTintColor = color

    switch task.status {
    case .notStarted:
      progressBar.doubleValue = 0
      progressBar.isHidden = true
    case .inProgress:
      progressBar.doubleValue = task.progressPercent
      progressBar.isHidden = false
    case .complete:
      progressBar.doubleValue = 1
      progressBar.isHidden = true
    }
  }
}
