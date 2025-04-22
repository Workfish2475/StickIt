//
//  StoreKitManager.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/21/25.
//

import StoreKit


@MainActor
final class StoreKitManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var activeTransations: Set<StoreKit.Transaction> = []
    private var updates: Task<Void, Never>?
    
    init () {
        updates = Task {
            for await update in StoreKit.Transaction.updates {
                if let transaction = try? update.payloadValue {
                    await fetchActiveTransactions()
                    await transaction.finish()
                }
            }
        }
    }
    
    func fetchProducts() async {
        do {
            products = try await Product.products(for: ["1"])
        } catch {
            products = []
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            if let transaction = try? verificationResult.payloadValue {
                activeTransations.insert(transaction)
                await transaction.finish()
            }
        case .userCancelled:
            break
        case.pending:
            break
        @unknown default:
            break
        }
    }
    
    func fetchActiveTransactions() async {
        var activeTransactions: Set<StoreKit.Transaction> = []
        
        for await entitlement in StoreKit.Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue {
                activeTransations.insert(transaction)
            }
        }
        
        self.activeTransations = activeTransactions
    }
}
