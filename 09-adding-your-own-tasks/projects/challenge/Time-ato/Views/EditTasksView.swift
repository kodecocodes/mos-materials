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

struct EditTasksView: View {
  @State private var dataStore = DataStore()
  @State private var tasks: [Task] = []

  var body: some View {
    VStack {
      ForEach($tasks) { $task in
        HStack(spacing: 20) {
          TextField(
            "",
            text: $task.title,
            prompt: Text("Task title"))
            .textFieldStyle(.squareBorder)

          Image(systemName: task.status == .complete
            ? "checkmark.square"
            : "square")
            .font(.title2)

          Button {
            deleteTask(id: task.id)
          } label: {
            Image(systemName: "trash")
          }
        }
      }
      .padding(.top, 12)
      .padding(.horizontal)

      Spacer()

      EditButtonsView(tasks: $tasks, dataStore: dataStore)
    }
    .frame(minWidth: 400, minHeight: 430)
    .onAppear {
      getTaskList()
    }
  }

  func getTaskList() {
    tasks = dataStore.readTasks()
    addEmptyTasks()
  }

  func addEmptyTasks() {
    while tasks.count < 10 {
      tasks.append(Task(id: UUID(), title: ""))
    }
  }

  func deleteTask(id: UUID) {
    let taskIndex = tasks.firstIndex {
      $0.id == id
    }

    if let taskIndex = taskIndex {
      tasks.remove(at: taskIndex)
      addEmptyTasks()
    }
  }
}

struct EditTasksView_Previews: PreviewProvider {
  static var previews: some View {
    EditTasksView()
      .frame(width: 400, height: 430)
  }
}

struct EditButtonsView: View {
  @Binding var tasks: [Task]
  let dataStore: DataStore

  var body: some View {
    HStack {
      Button("Cancel", role: .cancel) {
        closeWindow()
      }
      .keyboardShortcut(.cancelAction)

      Spacer()

      Button("Mark All Incomplete") {
        markAllTasksIncomplete()
      }

      Spacer()

      Button("Save") {
        saveTasks()
      }
    }
    .padding(12)
  }

  func closeWindow() {
    NSApp.keyWindow?.close()
  }

  func saveTasks() {
    tasks = tasks.filter {
      !$0.title.isEmpty
    }
    dataStore.save(tasks: tasks)
    closeWindow()

    NotificationCenter.default.post(
      name: .dataRefreshNeeded,
      object: nil)
  }

  func markAllTasksIncomplete() {
    for index in 0 ..< tasks.count {
      tasks[index].reset()
    }
  }
}
