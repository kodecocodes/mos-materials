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

struct ContentView: View {
  @Binding var document: MarkDownerDocument
  @State private var previewState = PreviewState.web
  @AppStorage("editorFontSize") var editorFontSize: Double = 14

  var body: some View {
    HSplitView {
      TextEditor(text: $document.text)
        .frame(minWidth: 200)
      if previewState == .web {
        WebView(html: document.html)
          .frame(minWidth: 200)
      } else if previewState == .code {
        ScrollView {
          Text(document.html)
            .frame(minWidth: 200)
            .frame(
              maxWidth: .infinity,
              maxHeight: .infinity,
              alignment: .topLeading)
            .padding()
            .textSelection(.enabled)
        }
      }
    }
    .frame(
      minWidth: 400,
      idealWidth: 600,
      maxWidth: .infinity,
      minHeight: 300,
      idealHeight: 400,
      maxHeight: .infinity)
    .font(.system(size: editorFontSize))
    .keyWindow(
      MarkDownerDocument.self,
      $document)
    .toolbar {
      ToolbarItem {
        Picker("", selection: $previewState) {
          Image(systemName: "network")
            .tag(PreviewState.web)
          Image(systemName: "chevron.left.forwardslash.chevron.right")
            .tag(PreviewState.code)
          Image(systemName: "nosign")
            .tag(PreviewState.off)
        }
        .pickerStyle(.segmented)
        .help("Hide preview, show HTML or web view")
      }
    }
    .touchBar {
      TouchbarCommands()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(document: .constant(MarkDownerDocument()))
  }
}

enum PreviewState {
  case web
  case code
  case off
}
