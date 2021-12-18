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

struct ThumbsView: View {
  @EnvironmentObject var sipsRunner: SipsRunner
  @State private var dragOver = false
  @State private var folderUrl: URL?
  @State private var imageUrls: [URL] = []
  @Binding var selectedTab: TabSelection

  let serviceReceivedFolderNotification = NotificationCenter.default
    .publisher(for: .serviceReceivedFolder)
    .receive(on: RunLoop.main)

  var body: some View {
    VStack {
      HStack {
        Button {
          selectImagesFolder()
        } label: {
          Text("Select Folder of Images")
        }

        ScrollingPathView(imageUrl: $folderUrl)
      }
      .padding()

      ScrollView {
        LazyVStack {
          ForEach(imageUrls, id: \.self) { imageUrl in
            HStack {
              Image(nsImage: NSImage(contentsOf: imageUrl) ?? NSImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
              Text(imageUrl.lastPathComponent)
              Spacer()
            }
          }
        }
      }
      .background(Color.gray.opacity(0.1))
      .padding()

      ThumbControls(imageUrls: imageUrls)
        .disabled(imageUrls.isEmpty)
    }
    .onChange(of: folderUrl) { _ in
      if let folderUrl = folderUrl {
        imageUrls = FileManager.default.imageFiles(in: folderUrl)
      } else {
        imageUrls = []
      }
    }
    .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers in
      for provider in providers {
        provider.loadDataRepresentation(
          forTypeIdentifier: "public.file-url") { data, _ in
            loadUrl(from: data)
        }
      }
      return true
    }
    .onReceive(serviceReceivedFolderNotification) { notification in
      if let url = notification.object as? URL {
        selectedTab = .makeThumbs
        folderUrl = url
      }
    }
  }

  func selectImagesFolder() {
    let openPanel = NSOpenPanel()
    openPanel.title = "Select a folder of images"
    openPanel.canChooseDirectories = true
    openPanel.canChooseFiles = false
    openPanel.allowsMultipleSelection = false

    openPanel.begin { response in
      if response == .OK {
        folderUrl = openPanel.url
      }
    }
  }

  func loadUrl(from data: Data?) {
    guard
      let data = data,
      let filePath = String(data: data, encoding: .ascii),
      let url = URL(string: filePath) else {
        return
      }
    if FileManager.default.isFolder(url: url) {
      folderUrl = url
    }
  }
}

struct ThumbsView_Previews: PreviewProvider {
  static var previews: some View {
    ThumbsView(selectedTab: .constant(.makeThumbs))
      .environmentObject(SipsRunner())
  }
}
