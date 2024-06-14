//
//  ContentView.swift
//  Firefly
//
//  Created by Micko, Sebastian (AMM) on 14/06/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var newTodo: String = ""
    @State private var todos: [Todo] = []
    
    private let firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if todos.isEmpty {
                        Text("Add your first todo below")
                    } else {
                        ForEach(todos, id:\.id) { todo in
                            Text(todo.content)
                        }
                        .onDelete(perform: { indexSet in
                            indexSet.forEach { index in
                                firebaseManager.deleteTodo(id: todos[index].id) { error in
                                    if let error  = error {
                                        print("Error: \(error.localizedDescription)")
                                    }
                                }
                            }
                            todos.remove(atOffsets: indexSet)
                        })
                    }
                } header: {
                    Text("Tasks")
                } footer: {
                    Text("You must do these")
                }
            }
            .listStyle(.sidebar)
            
            TextField("Enter a todo:", text: $newTodo)
                .onSubmit {
                    if newTodo.count > 0 {
                        print("Saving to firebase...")
                        firebaseManager.saveTodo(todo: newTodo)
                        newTodo = ""
                    }
                    firebaseManager.getTodos { todos, error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            guard let todos = todos else {
                                print("Something's gone wrong")
                                return
                            }
                            
                            self.todos = todos.sorted {
                                $0.createdAt < $1.createdAt
                            }
                        }
                    }
                }
                .navigationTitle("Firefly")
                .padding()
        }
        .onAppear {
            firebaseManager.getTodos { todos, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    guard let todos = todos else {
                        print("Something's gone wrong")
                        return
                    }
                    
                    self.todos = todos.sorted {
                        $0.createdAt < $1.createdAt
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
