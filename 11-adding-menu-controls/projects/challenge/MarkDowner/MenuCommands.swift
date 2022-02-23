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
import KeyWindow

struct MenuCommands: Commands {
  @AppStorage("styleSheet") var styleSheet: StyleSheet = .raywenderlich
  @AppStorage("editorFontSize") var editorFontSize: Double = 14
  @KeyWindowValueBinding(MarkDownerDocument.self) var document: MarkDownerDocument?

  var body: some Commands {
    CommandMenu("Display") {
      ForEach(StyleSheet.allCases, id: \.self) { style in
        Button {
          styleSheet = style
        } label: {
          Text(style.rawValue)
            .foregroundColor(style == styleSheet ? .accentColor : .primary)
        }
        // swiftlint:disable:next force_unwrapping
        .keyboardShortcut(KeyEquivalent(style.rawValue.first!))
      }

      Divider()

      Menu("Font Size") {
        Button("Smaller") {
          if editorFontSize > 8 {
            editorFontSize -= 1
          }
        }.keyboardShortcut("-")

        Button("Reset") {
          editorFontSize = 14
        }.keyboardShortcut("0")

        Button("Larger") {
          editorFontSize += 1
        }.keyboardShortcut("+")
      }
    }

    CommandGroup(replacing: .help) {
      NavigationLink(
        destination:
          WebView(
            html: nil,
            address: "https://bit.ly/3x55SNC")
          .frame(minWidth: 600, minHeight: 600)
      ) {
        Text("Markdown Help")
      }
      .keyboardShortcut("/")
    }

    // Challenge
    
    CommandMenu("Markdown") {
      Menu("Headers") {
        Button("Header 1") {
          document?.text += "# Header\n"
        }.keyboardShortcut("1")

        Button("Header 2") {
          document?.text += "## Header\n"
        }.keyboardShortcut("2")

        Button("Header 3") {
          document?.text += "### Header\n"
        }.keyboardShortcut("3")

        Button("Header 4") {
          document?.text += "#### Header\n"
        }.keyboardShortcut("4")

        Button("Header 5") {
          document?.text += "##### Header\n"
        }.keyboardShortcut("5")

        Button("Header 6") {
          document?.text += "###### Header\n"
        }.keyboardShortcut("6")
      }

      Divider()

      Button("Bold") {
        document?.text += "**BOLD**"
      }.keyboardShortcut("b")

      Button("Italic") {
        document?.text += "_Italic_"
      }.keyboardShortcut("i", modifiers: .command)

      Button("Link") {
        let linkText = "[Title](https://link_to_page)"
        document?.text += linkText
      }.keyboardShortcut("l")

      Button("Image") {
        let imageText = "![alt text](https://link_to_image)"
        document?.text += imageText
      }.keyboardShortcut("j")

      Button("Divider") {
        document?.text += "---\n"
      }.keyboardShortcut("d")
    }

    CommandGroup(after: .importExport) {
      Button("Export HTML…") {
        exportHTML()
      }
      .disabled(document == nil)
      .keyboardShortcut("e")
    }
  }

  func exportHTML() {
    guard let document = document else {
      return
    }

    let savePanel = NSSavePanel()
    savePanel.title = "Save HTML"
    savePanel.nameFieldStringValue = "Export.html"

    savePanel.begin { response in
      if response == .OK, let url = savePanel.url {
        try? document.html.write(
          to: url,
          atomically: true,
          encoding: .utf8)
      }
    }
  }
}
