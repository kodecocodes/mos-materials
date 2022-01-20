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

struct CustomImageView: View {
  @Binding var imageURL: URL?
  @State private var image: NSImage?
  @State private var dragOver = false

  var body: some View {
    Image(nsImage: image ?? NSImage())
      .resizable()
      .aspectRatio(contentMode: .fit)
      .padding()
      .frame(maxWidth: .infinity)
      .background(Color.gray.opacity(0.1))
      .cornerRadius(5)
      .padding(.horizontal)
      .padding(.bottom, 12)
      .onChange(of: imageURL) { _ in
        loadImage()
      }
      .onDrop(
        of: ["public.file-url"],
        isTargeted: $dragOver
      ) { providers in
        if let provider = providers.first {
          provider.loadDataRepresentation(
            forTypeIdentifier: "public.file-url") { data, _ in
              loadURL(from: data)
          }
        }
        return true
      }
  }

  func loadImage() {
    if let imageURL = imageURL {
      image = NSImage(contentsOf: imageURL)
    } else {
      image = nil
    }
  }

  func loadURL(from data: Data?) {
    guard
      let data = data,
      let filePath = String(data: data, encoding: .utf8),
      let url = URL(string: filePath) else {
        return
      }

    imageURL = url
  }
}

struct CustomImageView_Previews: PreviewProvider {
  static var previews: some View {
    CustomImageView(imageURL: .constant(nil))
  }
}
