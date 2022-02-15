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

struct ImageEditControls: View {
  @Binding var imageURL: URL?
  @Binding var picture: Picture?

  @State private var picWidth = ""
  @State private var picHeight = ""
  @State private var lockAspectRatio = true
  @State private var picFormat = PicFormat.png

  var body: some View {
    GroupBox {
      HStack {
        EditSizeView(
          picWidth: $picWidth,
          picHeight: $picHeight,
          lockAspectRatio: $lockAspectRatio,
          aspectRatio: picture?.aspectRatio ?? 1)

        Spacer()

        Picker("Format:", selection: $picFormat) {
          ForEach(PicFormat.allCases, id: \.self) { format in
            Text(format.rawValue).tag(format)
          }
        }
        .frame(maxWidth: 120)

        Spacer()
        Button("Resize Image") {
          Task {
            await resizeImage()
          }
        }
        .disabled(!pictureHasChanged)
      }
      .padding(.horizontal)
    }
    .padding([.horizontal, .bottom])

    .onChange(of: picture) { _ in
      if let picture = picture {
        picWidth = "\(picture.pixelWidth)"
        picHeight = "\(picture.pixelHeight)"
        picFormat = PicFormat(rawValue: picture.format) ?? .png
      } else {
        picWidth = ""
        picHeight = ""
        picFormat = .png
      }
    }
  }

  var pictureHasChanged: Bool {
    guard let picture = picture else {
      return false
    }

    if picWidth != "\(picture.pixelWidth)" { return true }
    if picHeight != "\(picture.pixelHeight)" { return true }
    if picFormat != PicFormat(rawValue: picture.format) { return true }

    return false
  }

  func resizeImage() async {
  }
}

struct ImageEditControls_Previews: PreviewProvider {
  static var previews: some View {
    ImageEditControls(imageURL: .constant(nil), picture: .constant(nil))
  }
}

struct EditSizeView: View {
  @Binding var picWidth: String
  @Binding var picHeight: String
  @Binding var lockAspectRatio: Bool
  var aspectRatio: Double

  var body: some View {
    HStack {
      VStack {
        HStack {
          Text("Width:").frame(width: 50)
          TextField("", text: $picWidth)
            .frame(maxWidth: 60)
        }
        HStack {
          Text("Height:").frame(width: 50)
          TextField("", text: $picHeight)
            .frame(maxWidth: 60)
        }
      }

      Button {
        toggleAspectRatioLock()
      } label: {
        if lockAspectRatio {
          Image(systemName: "lock")
        } else {
          Image(systemName: "lock.open")
        }
      }
      .font(.title)
      .buttonStyle(.plain)
      .frame(width: 50)
    }
    // onChanges here
  }

  func toggleAspectRatioLock() {
    lockAspectRatio.toggle()
  }

  func adjustAspectRatio(newWidth: String?, newHeight: String?) {
    if !lockAspectRatio {
      return
    }

    if let newWidth = newWidth, let picWidthValue = Double(newWidth) {
      let newHeight = Int(picWidthValue / aspectRatio)
      picHeight = "\(newHeight)"
    } else if let newHeight = newHeight, let picHeightValue = Double(newHeight) {
      let newWidth = Int(picHeightValue * aspectRatio)
      picWidth = "\(newWidth)"
    }
  }
}
