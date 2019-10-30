import Foundation

let formFields = ["name": "Donny", "family_name": "Wals"]
let imageData = "Image Data".data(using: .utf8)!

func convertFormField(named name: String, value: String, using boundary: String) -> String {
  var fieldString = "--\(boundary)\r\n"
  fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
  fieldString += "\r\n"
  fieldString += "\(value)\r\n"

  return fieldString
}

func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
  let data = NSMutableData()

  data.appendString("--\(boundary)\r\n")
  data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
  data.appendString("Content-Type: \(mimeType)\r\n\r\n")
  data.append(fileData)
  data.appendString("\r\n")

  return data as Data
}

extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

let boundary = "Boundary-\(UUID().uuidString)"

var request = URLRequest(url: URL(string: "https://some-page-on-a-server")!)
request.httpMethod = "POST"
request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

let httpBody = NSMutableData()

for (key, value) in formFields {
  httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
}

httpBody.append(convertFileData(fieldName: "image_field",
                                fileName: "imagename.png",
                                mimeType: "image/png",
                                fileData: imageData,
                                using: boundary))

httpBody.appendString("--\(boundary)--")

request.httpBody = httpBody as Data

print(String(data: httpBody as Data, encoding: .utf8)!)

/*
URLSession.shared.dataTask(with: request) { data, response, error in
  // handle the response here
}.resume()
 */
