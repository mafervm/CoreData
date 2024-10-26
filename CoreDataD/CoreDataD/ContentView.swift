//
//  ContentView.swift
//  CoreDataD
//
//  Created by ALUMNOS on 25/10/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State var name: String = ""
    @State var quantity: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Product.entity(),
               sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
    private var products: FetchedResults<Product>
    
    private func addProduct() {
        withAnimation {
            let product = Product(context: viewContext)
            product.name = name
            product.quantity = quantity
            saveContext()
        }
    }
    
    private func deleteProducts(offsets: IndexSet) {
        withAnimation {
            offsets.map { products[$0] }.forEach(viewContext.delete)
                saveContext()
            }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("An error occured: \(error)")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(
                    "Product name",
                    text: $name
                )
                .border(Color.blue)
                .cornerRadius(2)
                
                TextField(
                    "Product quantity",
                    text: $quantity
                )
                .border(Color.blue)
                .cornerRadius(2)
                
                HStack {
                    Button("Add") {
                        addProduct()
                    }
                    .bold()
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    NavigationLink(destination: ResultsView(name: name,
                                   viewContext: viewContext))
                    {
                        Text("Find")
                    }
                    .bold()
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button("Clear") {
                        name = ""
                        quantity = ""
                    }
                    .bold()
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                
                List {
                    ForEach(products) { product in
                        HStack {
                            Text(product.name ?? "Not found")
                            Spacer()
                            Text(product.quantity ?? "Not found")
                        }
                    }
                    .onDelete(perform: deleteProducts)
                }
                .navigationTitle("Product Database")
                .background(Color.white)
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
                
            }
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct ResultsView: View {
   
   var name: String
   var viewContext: NSManagedObjectContext
   @State var matches: [Product]?

   var body: some View {
      
       return VStack {
           List {
               ForEach(matches ?? []) { match in
                   HStack {
                       Text(match.name ?? "Not found")
                       Spacer()
                       Text(match.quantity ?? "Not found")
                   }
               }
           }
           .navigationTitle("Results")
           .background(Color.white)
           .scrollContentBackground(.hidden)
           .listStyle(PlainListStyle())
        }
       .task {
           let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
           
           fetchRequest.entity = Product.entity()
           fetchRequest.predicate = NSPredicate(
               format: "name CONTAINS %@", name
           )
           matches = try? viewContext.fetch(fetchRequest)
       }
   }
}

#Preview {
    ContentView()
}
