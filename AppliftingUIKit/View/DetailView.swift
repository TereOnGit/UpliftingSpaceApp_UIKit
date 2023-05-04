import SwiftUI

struct DetailView: View {
    var launch: Launch
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text(launch.name)
                    .font(.system(size: 50, weight: .bold))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.3)
                
                Buttons(launch: launch)
                
                Spacer()
                
                VStack {
                    Text("Launched:")
                        .fontWeight(.bold)
                        .padding(.bottom)
                    Text("\(formattedDay())")
                }
                .font(.system(size: 25))
                .foregroundColor(.white)
                
                Spacer()
                
                Group {
                    if let detail = launch.details {
                        Text("Here are some details:")
                            .foregroundColor(.white)
                            .font(.system(size: 30, weight: .bold))
                        Spacer()
                        Text(detail)
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                            .lineSpacing(10)
                    } else {
                        Text("Oops! Looks like the details for this launch are not available at the moment! But check it out later.")
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                            .frame(maxWidth: .infinity)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .background {
            Image("space2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
    
    private func formattedDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d. M. yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm:ss"
        return dateFormatter.string(from: launch.dateUnix) + " at " + timeFormatter.string(from: launch.dateUnix)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(launch: .launchWithoutDetails)
.previewInterfaceOrientation(.landscapeLeft)
        DetailView(launch: .launchWithDetails)
    }
}
