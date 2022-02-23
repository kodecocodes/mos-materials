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

import Cocoa

func runCommand(
  _ command: String,
  with arguments: [String] = []
) async -> String {
  let process = Process()

  process.executableURL = URL(fileURLWithPath: command)
  process.arguments = arguments

  let outPipe = Pipe()
  let outFile = outPipe.fileHandleForReading
  process.standardOutput = outPipe

  do {
    try process.run()

    var returnValue = ""
    while process.isRunning {
      let newString = getAvailableData(from: outFile)
      returnValue += newString
    }
    let newString = getAvailableData(from: outFile)
    returnValue += newString

    return returnValue
      .trimmingCharacters(in: .whitespacesAndNewlines)
  } catch {
    print(error)
  }
  return ""
}

func getAvailableData(from fileHandle: FileHandle) -> String {
  let newData = fileHandle.availableData
  if let string = String(data: newData, encoding: .utf8) {
    return string
  }
  return ""
}

func pathTo(command: String) async -> String {
  await runCommand("/bin/zsh", with: ["-c", "which \(command)"])
}

// Task {
//  let commandPath = await pathTo(command: "cal")
//  let cal = await runCommand(commandPath, with: ["-h"])
//  print(cal)
// }

// Edit these file paths before running the playground

let imagePath = "/path/to/folder/rosella.png"
let imagePathSmall = "/path/to/folder/rosella_small.png"

Task {
  let sipsPath = await runCommand("/bin/zsh", with: ["-c", "which sips"])

  let args = ["--getProperty", "all", imagePath]
  let imageData = await runCommand(sipsPath, with: args)
  print(imageData)

  let resizeArgs = [
    "--resampleWidth", "800",
    imagePath,
    "--out", imagePathSmall
  ]

  let output = await runCommand(sipsPath, with: resizeArgs)
  print("Output: \(output)")
}

// Challenge 1

Task {
  let path = await runCommand("/bin/zsh", with: ["-c", "which sw_vers"])
  let result = await runCommand(path)

  print()
  print("System Version:")
  print(result)
  print()
}

// Challenge 2

// Edit these file paths before running the playground

let imagePathFlipped = "/path/to/folder/rosella_flipped.png"
let imagePathRotated = "/path/to/folder/rosella_rotated.png"

Task {
  let sipsPath = await runCommand("/bin/zsh", with: ["-c", "which sips"])

  let rotateArgs = ["--rotate", "90", imagePath, "--out", imagePathRotated]
  await runCommand(sipsPath, with: rotateArgs)

  let flipArgs = ["--flip", "vertical", imagePath, "--out", imagePathFlipped]
  await runCommand(sipsPath, with: flipArgs)
}
