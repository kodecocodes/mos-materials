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

import SwiftUI

class SipsRunner: ObservableObject {
  @ObservedObject var commandRunner = CommandRunner()
  var sipsCommandPath: String?

  func checkSipsCommandPath() async -> String? {
    if sipsCommandPath == nil {
      sipsCommandPath = await commandRunner.getCommandPath(command: "sips")
    }
    return sipsCommandPath
  }

  func getImageData(for imageUrl: URL) async -> String {
    guard let sipsCommandPath = await checkSipsCommandPath() else {
      return ""
    }

    let args = ["--getProperty", "all", "\(imageUrl.path)"]
    let imageData = await commandRunner.runCommand(sipsCommandPath, with: args)
    return imageData
  }

  func resizeImage(
    picture: Picture,
    newWidth: String,
    newHeight: String,
    newDpi: String,
    newFormat: PicFormat
  ) async -> URL? {
    guard let sipsCommandPath = await checkSipsCommandPath() else {
      return nil
    }

    var picUrl = picture.url

    let fileManager = FileManager.default
    let suffix = "-> \(newWidth) x \(newHeight) @ \(newDpi) dpi"
    var newUrl = fileManager.addSuffix(of: suffix, to: picture.url)
    newUrl = fileManager.changeFileExtension(of: newUrl, to: newFormat.rawValue)

    // For JPGs, changing DPI only works if size is changed too
    // So if the size is the same, save the file out twice,
    // the first time with a slightly different size

    if newDpi != "\(picture.dpiWidth)"
      && picture.format == "jpeg"
      && newFormat.rawValue == "jpeg"
      && newWidth == "\(picture.pixelWidth)"
      && newHeight == "\(picture.pixelHeight)" {
      if
        let widthInt = Int(newWidth),
        let heightInt = Int(newHeight) {
        let args = [
          "--resampleHeightWidth", "\(heightInt + 1)", "\(widthInt + 1)",
          "\(picUrl.path)",
          "--out", "\(newUrl.path)"
        ]

        _ = await commandRunner.runCommand(sipsCommandPath, with: args)
        picUrl = newUrl
      }
    }

    let args = [
      "--resampleHeightWidth", "\(newHeight)", "\(newWidth)",
      "--setProperty", "dpiWidth", "\(newDpi)",
      "--setProperty", "dpiHeight", "\(newDpi)",
      "--setProperty", "format", "\(newFormat.rawValue)",
      "\(picUrl.path)",
      "--out", "\(newUrl.path)"
    ]

    _ = await commandRunner.runCommand(sipsCommandPath, with: args)

    return newUrl
  }

  func createThumbs(in folder: URL, from imageUrls: [URL], maxDimension: String) async {
    guard let sipsCommandPath = await checkSipsCommandPath() else {
      return
    }

    for imageUrl in imageUrls {
      let args = [
        "--setProperty", "dpiWidth", "72",
        "--setProperty", "dpiHeight", "72",
        "--resampleHeightWidthMax", "\(maxDimension)",
        "\(imageUrl.path)",
        "--out", "\(folder.path)"
      ]

      _ = await commandRunner.runCommand(sipsCommandPath, with: args)
    }
  }

  func changeResolution(for url: URL, to dpi: String) async {
    guard let sipsCommandPath = await checkSipsCommandPath() else {
      return
    }

    let args = [
      "--setProperty", "dpiWidth", "\(dpi)",
      "--setProperty", "dpiHeight", "\(dpi)",
      "\(url.path)"
    ]

    _ = await commandRunner.runCommand(sipsCommandPath, with: args)
  }
}
