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

struct ImageEditView: View {
  @EnvironmentObject var sipsRunner: SipsRunner
  @State private var dragOver = false
  @State private var imageUrl: URL?
  @State private var image: NSImage?
  @State private var picture: Picture?
  @Binding var selectedTab: TabSelection

  let serviceReceivedImageNotification = NotificationCenter.default
    .publisher(for: .serviceReceivedImage)
    .receive(on: RunLoop.main)

  var body: some View {
    VStack {
      HStack {
        Button {
          selectImageFile()
        } label: {
          Text("Select Image File")
        }

        ScrollingPathView(imageUrl: $imageUrl)
      }
      .padding()

      DropImage(imageUrl: $imageUrl)

      Spacer()

      ImageEditControls(imageUrl: $imageUrl, picture: $picture)
        .disabled(picture == nil)
    }
    .onChange(of: imageUrl) { _ in
      Task {
        await getImageData()
      }
    }
    .onReceive(serviceReceivedImageNotification) { notification in
      if let url = notification.object as? URL {
        selectedTab = .editImage
        imageUrl = url
      }
    }
  }

  func selectImageFile() {
    let openPanel = NSOpenPanel()
    openPanel.title = "Select an image file"
    openPanel.canChooseDirectories = false
    openPanel.allowsMultipleSelection = false
    openPanel.allowedContentTypes = [.image]

    openPanel.begin { response in
      if response == .OK {
        imageUrl = openPanel.url
      }
    }
  }

  func getImageData() async {
    guard
      let imageUrl = imageUrl,
      FileManager.default.fileIsImage(url: imageUrl) else {
        return
      }

    let imageData = await sipsRunner.getImageData(for: imageUrl)
    picture = Picture(url: imageUrl, sipsData: imageData)
  }
}

struct ResizeView_Previews: PreviewProvider {
  static var previews: some View {
    ImageEditView(selectedTab: .constant(.editImage))
      .environmentObject(SipsRunner())
  }
}
