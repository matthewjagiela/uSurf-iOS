import SwiftUI
import StoreKit

class SubscriptionViewModel: ObservableObject {
    @Published var products: [Product] = []
    
    init() {
    }
    
    func fetchSubscriptions() async throws {
        let subscriptionIds: Set<String> = ["com.uapps.uSurf.TestSub"]
        print(try await Product.products(for: subscriptionIds))
        self.products = try await Product.products(for: subscriptionIds)
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            // Successful purhcase
            await transaction.finish()
        case let .success(.unverified(_, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }
}


import SwiftUI

struct SubscriptionView: View {
    @ObservedObject var viewModel: SubscriptionViewModel = SubscriptionViewModel()
    
    var body: some View {
        VStack {
            Text("Available Subscriptions")
                .font(.title)
                .padding()
            
            List(viewModel.products, id: \.id) { product in
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text("\(product.displayPrice)")
                        .font(.subheadline)
                    Text("\(self.subscriptionPeriodString(from: product.subscription!.subscriptionPeriod))")
                }.onTapGesture {
                    Task {
                        try! await self.viewModel.purchase(product)
                    }
                }
            }
        }
        .task {
            try! await viewModel.fetchSubscriptions()
        }
    }
    
    func subscriptionPeriodString(from subscription: Product.SubscriptionPeriod) -> String {
        let unit  = subscription.unit
        
        switch unit {
        case .day:
            return "Day"
        case .week:
            return "Week"
        case .month:
            return "Month"
        case .year:
            return "Year"
        }
    }
}


struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
