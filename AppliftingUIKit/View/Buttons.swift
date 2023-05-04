import SwiftUI

struct Buttons: View {
    @State var launch: Launch
    @Environment(\.openURL) var openURL
    
    @State private var showingWikiAlert = false
    @State private var showingStreamAlert = false
    
    var body: some View {
        HStack {
            Button {
                openURL(launch.links.webcast!)
            } label: {
                Text("Livestream")
            }
            .font(.system(size: 20))
            .frame(width: 120, height: 70)
            .background(Color("spaceLight"))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Spacer()
                .frame(width: 100)
            
            Button {
                openURL(launch.links.wikipedia!)
            } label: {
                Text("Wikipedia")
            }
            .font(.system(size: 20))
            .frame(width: 120, height: 70)
            .background(Color("spaceLight"))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
        }
        .tint(.white)
        .padding()
        
        .alert("There is no livestream for this launch, yet. Sorry!", isPresented: $showingStreamAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("No wiki for this launch, sorry!", isPresented: $showingWikiAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        Buttons(launch: .launchWithDetails)
    }
}
