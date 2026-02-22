//
//  CreateImpressionFlowView.swift
//  impressionsv1
//

import SwiftUI
import SwiftData

struct CreateImpressionFlowView: View {
    @StateObject private var coordinator = CreateImpressionCoordinator()
    @Environment(UserManager.self) private var userManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appCream.ignoresSafeArea()

            Group {
                switch coordinator.currentStep {
                case .placeSelection:
                    PlaceSelectionView(coordinator: coordinator)

                case .conversational:
                    ConversationalFlowView(coordinator: coordinator)

                case .foodOrder:
                    FoodOrderView(coordinator: coordinator)

                case .widgetBuilder:
                    WidgetBuilderView(coordinator: coordinator)

                case .preview:
                    ImpressionPreviewView(coordinator: coordinator)

                case .publishSuccess:
                    PublishSuccessView(coordinator: coordinator)

                // Legacy steps — should not be reached in new flow
                default:
                    PlaceSelectionView(coordinator: coordinator)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal:   .move(edge: .leading).combined(with: .opacity)
            ))
            .id(coordinator.currentStep)
            .animation(.easeInOut(duration: 0.28), value: coordinator.currentStep)
        }
        .onAppear {
            coordinator.userManager = userManager
            coordinator.modelContext = modelContext
            coordinator.onPublishComplete = { dismiss() }
        }
    }
}

#Preview {
    CreateImpressionFlowView()
}
