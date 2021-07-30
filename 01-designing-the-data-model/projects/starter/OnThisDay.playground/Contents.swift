import Cocoa

extension String {
  // String extension to decode HTML entities
  var decoded: String {
    let attr = try? NSAttributedString(
      data: Data(utf8),
      options: [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
      ],
      documentAttributes: nil)

    return attr?.string ?? self
  }
}

enum FetchError: Error {
  case badUrl
  case badResponse
  case badJson
}

func getDataForDay(month: Int, day: Int) async throws {
  let address = "https://apizen.date/api/\(month)/\(day)"
  guard let url = URL(string: address) else {
    throw FetchError.badUrl
  }
  let request = URLRequest(url: url)

  let (data, response) = try await URLSession.shared.data(for: request)
  guard let response = response as? HTTPURLResponse, response.statusCode < 400 else {
    throw FetchError.badResponse
  }

  if let jsonString = String(data: data, encoding: .utf8) {
    saveSampleData(json: jsonString)
  }
}

Task {
  do {
    try await getDataForDay(month: 2, day: 29)
  } catch {
    print(error)
  }
}
