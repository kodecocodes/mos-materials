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

import Foundation

struct Event: Decodable, Identifiable {
  let id = UUID()
  let text: String
  let year: String
  let links: [EventLink]

  enum CodingKeys: String, CodingKey {
    case text
    case links
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    let rawText = try values.decode(String.self, forKey: .text)
    var textParts = rawText.components(separatedBy: " &#8211; ")
    if textParts.count == 1 {
      textParts = rawText.components(separatedBy: " &amp;#8211; ")
    }
    if textParts.count == 1 {
      textParts = rawText.components(separatedBy: " – ")
    }

    if textParts.count > 1 {
      year = textParts[0]
      text = textParts[1].decoded
    } else {
      year = "?"
      text = textParts[0].decoded
    }

    let allLinks = try values.decode(
      [String: [String: String]].self,
      forKey: .links)
    var processedLinks: [EventLink] = []
    for (_, link) in allLinks {
      if let title = link["2"], let address = link["1"], let url = URL(string: address) {
        processedLinks.append(EventLink(id: UUID(), title: title, url: url))
      }
    }
    links = processedLinks
  }
}

enum EventType: String, CaseIterable {
  case events = "Events"
  case births = "Births"
  case deaths = "Deaths"
}
