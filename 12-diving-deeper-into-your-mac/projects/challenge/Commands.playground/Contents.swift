// 1
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
    process.waitUntilExit()

    if
      let data = try outFile.readToEnd(),
      let returnValue = String(data: data, encoding: .utf8) {
      return returnValue
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }
  } catch {
    print(error)
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
