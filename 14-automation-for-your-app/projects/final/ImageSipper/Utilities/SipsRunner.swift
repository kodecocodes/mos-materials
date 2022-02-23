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

import SwiftUI

class SipsRunner: ObservableObject {
  var commandRunner = CommandRunner()

  var sipsCommandPath: String?
  func checkSipsCommandPath() async -> String? {
    if sipsCommandPath == nil {
      sipsCommandPath = await commandRunner.pathTo(command: "sips")
    }
    return sipsCommandPath
  }

  func getImageData(for imageURL: URL) async -> String {
    guard let sipsCommandPath = await checkSipsCommandPath() else {
      return ""
    }

    let args = ["--getProperty", "all", imageURL.path]
    let imageData = await commandRunner
      .runCommand(sipsCommandPath, with: args)
    return imageData
  }

  func resizeImage(
    picture: Picture,
    newWidth: String,
    newHeight: String,
    newFormat: PicFormat
  ) async -> URL? {
    guard let sipsCommandPath = await checkSipsCommandPath() else {
      return nil
    }

    let fileManager = FileManager.default
    let suffix = "-> \(newWidth) x \(newHeight)"
    var newURL = fileManager.addSuffix(of: suffix, to: picture.url)
    newURL = fileManager.changeFileExtension(
      of: newURL,
      to: newFormat.rawValue)

    let args = [
      "--resampleHeightWidth", newHeight, newWidth,
      "--setProperty", "format", newFormat.rawValue,
      picture.url.path,
      "--out", newURL.path
    ]

    _ = await commandRunner.runCommand(sipsCommandPath, with: args)
    return newURL
  }

  func createThumbs(
    in folder: URL,
    from imageURLs: [URL],
    maxDimension: String
  ) async {
    guard let sipsCommandPath = await checkSipsCommandPath() else {
      return
    }

    for imageURL in imageURLs {
      let args = [
        "--resampleHeightWidthMax", maxDimension,
        imageURL.path,
        "--out", folder.path
      ]

      _ = await commandRunner.runCommand(sipsCommandPath, with: args)
    }
  }

  func prepareForWeb(_ url: URL) async {
    guard let sipsCommandPath = await checkSipsCommandPath() else {
      return
    }

    let args = [
      "--resampleHeightWidthMax", "800",
      url.path
    ]

    _ = await commandRunner.runCommand(sipsCommandPath, with: args)
  }
}
