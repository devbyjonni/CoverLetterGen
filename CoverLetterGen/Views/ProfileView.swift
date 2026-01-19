import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Text("Your personal details are stored privately on this device. They are NEVER sent to OpenAI. The app simply adds them to the top of your letter after it is generated.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                Section(header: HStack {
                    Text("Personal Info")
                    Spacer()
                    Button("Fill Test Data") {
                        viewModel.fillTestProfile()
                    }
                    .font(.caption)
                    .textCase(nil)
                }) {
                    TextField("Full Name", text: $viewModel.userFullName)
                        .textContentType(.name)
                    TextField("Job Title", text: $viewModel.userJobTitle)
                        .textContentType(.jobTitle)
                    TextField("Email", text: $viewModel.userEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Phone", text: $viewModel.userPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Git / Portfolio URL", text: $viewModel.userPortfolio)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
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
                    TextField("Country", text: $viewModel.userCountry)
                        .textContentType(.countryName)
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
