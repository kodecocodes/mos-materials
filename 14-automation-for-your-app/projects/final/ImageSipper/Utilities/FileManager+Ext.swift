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

extension FileManager {
  func isFolder(url: URL) -> Bool {
    var isDir: ObjCBool = false

    if self.fileExists(atPath: url.path, isDirectory: &isDir) {
      return isDir.boolValue
    }

    return false
  }

  func imageFiles(in url: URL) -> [URL] {
    do {
      let files = try self.contentsOfDirectory(atPath: url.path)
      let imageFiles = files
        .map { file in
          url.appendingPathComponent(file)
        }
        .filter { url in
          fileIsImage(url: url)
        }
      return imageFiles
    } catch {
      print(error)
      return []
    }
  }

  func changeFileExtension(of url: URL, to newExt: String) -> URL {
    let newUrl = url.deletingPathExtension().appendingPathExtension(newExt)
    return newUrl
  }

  func addSuffix(of suffix: String, to url: URL) -> URL {
    let ext = url.pathExtension
    let fileName = url
      .deletingPathExtension()
      .lastPathComponent
      .components(separatedBy: " -> ")[0]
    let newUrl = url.deletingLastPathComponent()
    let newPath = "\(fileName) \(suffix).\(ext)"
    return newUrl.appendingPathComponent(newPath)
  }

  func fileIsImage(url: URL) -> Bool {
    guard let contentTypeKey = try? url.resourceValues(
      forKeys: [.contentTypeKey]) else {
        return false
      }

    guard let superTypes = contentTypeKey.contentType?.supertypes else {
      return false
    }

    return superTypes.contains(.image)
  }

  func fileCanChangeResolution(url: URL) -> Bool {
    guard let contentTypeKey = try? url.resourceValues(
      forKeys: [.contentTypeKey]) else {
        return false
      }

    if let type = contentTypeKey.contentType?.identifier {
      let validTypes = ["public.png", "public.tiff", "public.heic"]
      if validTypes.contains(type) {
        return true
      }
    }
    return false
  }
}
