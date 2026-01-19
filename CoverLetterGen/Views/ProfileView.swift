import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Info")) {
                    TextField("Full Name", text: $viewModel.userFullName)
                        .textContentType(.name)
                    TextField("Job Title", text: $viewModel.userJobTitle)
                        .textContentType(.jobTitle)
                    TextField("Email", text: $viewModel.userEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $viewModel.userPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Address")) {
                    TextField("Street Address", text: $viewModel.userAddress)
                        .textContentType(.streetAddressLine1)
                    TextField("City", text: $viewModel.userCity)
                        .textContentType(.addressCity)
                    TextField("State/Province", text: $viewModel.userState)
                        .textContentType(.addressState)
                    TextField("Zip/Postal Code", text: $viewModel.userZip)
                        .textContentType(.postalCode)
                }
            }
            .navigationTitle("Your Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
