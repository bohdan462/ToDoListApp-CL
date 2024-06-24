//
//  main.swift
//  TodoListProject2024
//
//  Created by Bohdan Tkachenko on 6/21/24.
//

import Foundation


// * Create the `Todo` struct.
// * Ensure it has properties: id (UUID), title (String), and isCompleted (Bool).
struct Todo: CustomStringConvertible, Codable {
    
    let id: UUID
    let title: String
    var isCompleted: Bool
}
// The `TodosManager` class should have:
// * A function `func listTodos()` to display all todos.
// * A function named `func addTodo(with title: String)` to insert a new todo.
// * A function named `func toggleCompletion(forTodoAtIndex index: Int)`
//   to alter the completion status of a specific todo using its index.
// * A function named `func deleteTodo(atIndex index: Int)` to remove a todo using its index.

final class TodosManager {
    
    let fileManager: Cache
    
    var array: [Todo] = []
    
    init(fileManager: Cache = JSONFileManagerCache()) {
        self.fileManager = fileManager
        if let todos = fileManager.load() {
            array = todos
        } else {
            array = []
        }
    }
    
    func loadTodos(){
        guard let todos = fileManager.load() else { return }
        array = todos
    }
    
    func addTodoWith(title: String) {
        array.append(Todo(id: UUID(), title: title, isCompleted: false))
        fileManager.save(todos: array)
    }
    
    func deleteTodo(index: Int) {
        guard !array.isEmpty else { return }
        array.remove(at: index - 1)
        fileManager.save(todos: array)
        
    }
    
    func list() {
        var output = ""
        
        guard !array.isEmpty else { return }
        for (index, item) in array.enumerated() {
            output += "\(index + 1) \(item.description)\n"
            
        }
        print(output)
        
        
    }
    
    func toggleTodoAt(index: Int) {
        guard !array.isEmpty else { return }
        array[index - 1].isCompleted.toggle()
        fileManager.save(todos: array)
    }
    
    
}

extension Todo {
    var description: String {
        return "\(isCompleted ? "✅" : "❌") <---- \(title) ---->"
    }
}

// * The `App` class should have a `func run()` method, this method should perpetually
//   await user input and execute commands.
//  * Implement a `Command` enum to specify user commands. Include cases
//    such as `add`, `list`, `toggle`, `delete`, and `exit`.
//  * The enum should be nested inside the definition of the `App` class

final class App {
    
    enum Command {
        case non
        case add
        case list
        case toggle
        case delete
    }
    
    let manager: TodosManager = TodosManager()
    
    
    func run() {
        
        var command: Command = .non
        
        print("Welcome to To Do CLI")
        print()
        
        manager.list()
        
        print("What would you like to do? (add, list, toggle, delete, exit): ", terminator: "")
        
        while let input = readLine() {
            guard input != "exit" else { break }
            
            switch input {
            case "add":
                command = .add
            case "list":
                command = .list
            case "toggle":
                command = .toggle
            case "delete":
                command = .delete
                
            default:
                print("Please, pick one of the commands, or type exit to close Todos CLI")
            }
            
            switch command {
            case .non:
                print()
            case .add:
                print("Enter Title: ", terminator: "")
                if let input = readLine() {
                    manager.addTodoWith(title: input)
                    manager.list()
                    print("Added: \(input)")
                }
            case .list:
                manager.list()
            case.toggle:
                manager.list()
                print("What number to toggle: ", terminator: "")
                if let input = readLine() {
                    manager.toggleTodoAt(index: Int(input)!)
                    manager.list()
                }
            case .delete:
                manager.list()
                print("What number to delete: ", terminator: "")
                if let input = readLine() {
                    manager.deleteTodo(index: Int(input)!)
                    manager.list()
                }
            }
            
            print("What would you like to do? (add, list, toggle, delete, exit): ", terminator: "")
        }
        
    }
}

// Create the `Cache` protocol that defines the following method signatures:
//  `func save(todos: [Todo])`: Persists the given todos.
//  `func load() -> [Todo]?`: Retrieves and returns the saved todos, or nil if none exist.
protocol Cache {
    func save(todos: [Todo])
    func load() -> [Todo]?
}

// `FileSystemCache`: This implementation should utilize the file system
// to persist and retrieve the list of todos.
// Utilize Swift's `FileManager` to handle file operations.
final class JSONFileManagerCache: Cache {
    
    private func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    
    func save(todos: [Todo]) {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(todos)
            let url = getDocumentsDirectory().appendingPathComponent("Todos")
            try data.write(to: url)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func load() -> [Todo]? {
        let decoder = JSONDecoder()
        var todos: [Todo] = []
        
        do {
            let url = getDocumentsDirectory().appendingPathComponent("Todos")
            let data = try Data(contentsOf: url)
            todos = try decoder.decode([Todo].self, from: data)
            
        } catch {
            print(error.localizedDescription)
        }
        return todos
    }
    
}

let app = App()
app.run()
