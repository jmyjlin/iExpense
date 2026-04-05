//
//  ContentView.swift
//  iExpense
//
//  Created by Jimmy Lin on 4/1/26.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        
        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationStack {
            List {
                let personalItems = expenses.items.filter {
                    $0.type == "Personal"
                }
                let businessItems = expenses.items.filter {
                    $0.type == "Business"
                }
                Section("Personal") {
                    ForEach(personalItems) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(item.amount > 10 && item.amount < 100 ? .headline : .callout)
                                    .foregroundStyle(item.amount < 10 ? .purple : .black)
                                Text(item.type)
                            }
                            
                            Spacer()
                            
                            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        }
                    }
                    .onDelete { offsets in
                        removeItems(at: offsets, from: personalItems)
                    }
                }
                
                Section("Business") {
                    ForEach(businessItems) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(item.amount > 10 && item.amount < 100 ? .headline : .callout)
                                    .foregroundStyle(item.amount < 10 ? .purple : .black)
                                Text(item.type)
                            }
                            
                            Spacer()
                            
                            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        }
                    }
                    .onDelete { offsets in
                        removeItems(at: offsets, from: businessItems)
                    }
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
    }
    
    func removeItems(at offsets: IndexSet, from filtered: [ExpenseItem]) {
        for index in offsets {
            let item = filtered[index]
            
            if let original = expenses.items.firstIndex(where: { $0.id == item.id }) {
                expenses.items.remove(at: original)
            }
        }
    }
}

#Preview {
    ContentView()
}
