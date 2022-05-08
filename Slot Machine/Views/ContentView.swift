//
//  ContentView.swift
//  Slot Machine
//
//  Created by Laura Johnson on 5/1/22.
//

import SwiftUI

struct ContentView: View {
    // MARK:  - properties
    let symbols = ["gfx-bell", "gfx-coin", "gfx-grape", "gfx-seven", "gfx-cherry", "gfx-strawberry"]
    
    @State private var reels: Array = [0, 1, 2]
    @State private var showingInfoView: Bool = false
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "HighScore")
    @State private var coins: Int = 100
    @State private var betAmount: Int = 10
    @State private var showGameOverModal: Bool = false
    
    // MARK:  - functions
    
    // spin reels
    func spinReels() {
        reels = reels.map({ _ in
            Int.random(in: 0...symbols.count - 1)
        })
    }
    
    // check spin status
    func checkSpinStatus() {
        if reels[0] == reels[1] && reels[2] == reels[1] {
            // player wins
            playerWins()
            // new high score
            if coins > highScore {
                newHighScore()
            }
        } else {
            // player loses
            playerLoses()
            
            // game over
            
        }
    }
    
    func playerWins() {
        coins += betAmount * 10
    }
    
    func newHighScore() {
        highScore = coins
        UserDefaults.standard.set(highScore, forKey: "HighScore")
    }
    
    func playerLoses() {
        coins -= betAmount
    }
    
    func isGameOver() {
        if coins <= 0 {
            showGameOverModal = true
        }
    }
    
    func resetGame(clearHighScore: Bool) {
        coins = 100
        showGameOverModal = false
        if clearHighScore {
            highScore = 0
            UserDefaults.standard.set(highScore, forKey: "HighScore")
        }
    }
    
    // MARK:  - body
    
    var body: some View {
        ZStack {
            // MARK:  - Background
            LinearGradient(gradient: Gradient(colors: [Constants.Colors.pink, Constants.Colors.purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // MARK:  - Interface
            VStack(alignment: .center, spacing: 5) {
               
                // MARK:  - Header
                LogoView()
                Spacer()
                
                // MARK:  - Score
                HStack {
                    HStack {
                        Text("Your\nCoins".uppercased())
                            .scoreLabelStyle()
                            .multilineTextAlignment(.trailing)
                        Text("\(coins)")
                            .scoreNumberStyle()
                            .modifier(ScoreNumberModifier())
                    }
                    .modifier(ScoreContainerModifier())
                    
                    Spacer()
                    
                    HStack {
                        Text("\(highScore)")
                            .scoreNumberStyle()
                            .modifier(ScoreNumberModifier())
                        Text("High\nScore".uppercased())
                            .scoreLabelStyle()
                            .multilineTextAlignment(.leading)

                    }
                    .modifier(ScoreContainerModifier())
                }
                // MARK:  - Slot Machine
                VStack(alignment: .center, spacing: 0) {
                    
                    // MARK:  - reel 1
                    ZStack {
                        ReelView()
                        Image(symbols[reels[0]])
                            .resizable()
                            .modifier(ImageModifier())
                    }
                    
                    // MARK:  - reel 2
                    HStack(alignment: .center, spacing: 0) {
                        ZStack {
                            ReelView()
                            Image(symbols[reels[1]])
                                .resizable()
                                .modifier(ImageModifier())
                        }
                        
                        Spacer()
                        
                        // MARK:  - reel 3
                        ZStack {
                            ReelView()
                            Image(symbols[reels[2]])
                                .resizable()
                                .modifier(ImageModifier())
                        }
                    }
                    .frame(maxWidth: 500)
                    
                    // MARK:  - spin button
                    
                    Button(action: {
                        self.spinReels()
                        self.checkSpinStatus()
                        self.isGameOver()
                    }) {
                        Image("gfx-spin")
                            .renderingMode(.original)
                            .resizable()
                            .modifier(ImageModifier())
                    }
                    
                }
                .layoutPriority(2)
                
                
                // MARK:  - Footer
                Spacer()
                
                HStack {
                    // MARK:  - bet 20
                    HStack(alignment: .center, spacing: 10) {
                        Button(action: {
                            betAmount = 20
                        }) {
                            Text("20")
                                .fontWeight(.heavy)
                                .foregroundColor(betAmount == 20 ? Constants.Colors.yellow : Color.white)
                                .modifier(BetNumberModifier())
                        }
                        .modifier(BetCapsuleModifier())
                        
                        Image("gfx-casino-chips")
                            .resizable()
                            .opacity(betAmount == 20 ? 1 : 0)
                            .modifier(CasinoChipsModifier())
                    }
                    
                    Spacer()
                    
                    // MARK:  - bet 10
                    HStack(alignment: .center, spacing: 10) {
                        Image("gfx-casino-chips")
                            .resizable()
                            .opacity(betAmount == 10 ? 1 : 0)
                            .modifier(CasinoChipsModifier())
                        
                        Button(action: {
                            betAmount = 10
                        }) {
                            Text("10")
                                .fontWeight(.heavy)
                                .foregroundColor(betAmount == 10 ? Constants.Colors.yellow : Color.white)
                                .modifier(BetNumberModifier())
                        }
                        .modifier(BetCapsuleModifier())
                        
                    }
                }
            }
            .overlay(
                // reset
                Button(action: {
                    resetGame(clearHighScore: true)
                }) {
                   Image(systemName: "arrow.2.circlepath.circle")
                }
                .modifier(ButtonModifier()),
                alignment: .topLeading
            )
            .overlay(
                // info
                Button(action: {
                    self.showingInfoView = true
                }) {
                   Image(systemName: "info.circle")
                }
                .modifier(ButtonModifier()),
                alignment: .topTrailing
            )
            .padding()
            .frame(maxWidth: 720)
            .blur(radius: $showGameOverModal.wrappedValue ? 5 : 0, opaque: false)
            // MARK:  - Popup
            
            if $showGameOverModal.wrappedValue {
                ZStack{
                    Constants.Colors.transparentBlack
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        // title
                        Text("Game Over")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.heavy)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Constants.Colors.pink)
                            .foregroundColor(Color.white)
                        
                        Spacer()
                        
                        // message
                        
                        VStack(alignment: .center, spacing: 16) {
                            Image("gfx-seven-reel")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 72)
                            
                            Text("Bad luck! You lost all of the coints. \nLet's play again!")
                                .font(.system(.body, design: .rounded))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.gray)
                                .layoutPriority(1)
                            
                            Button(action: {
                                resetGame(clearHighScore: false)
                            }){
                                Text("New Game".uppercased())
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                                    .accentColor(Constants.Colors.pink)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(minWidth: 128)
                                    .background(
                                        Capsule()
                                            .strokeBorder(lineWidth: 1.75)
                                            .foregroundColor(Constants.Colors.pink)
                                    )
                            }
                        }
                        
                        Spacer()

                    }
                    .frame(minWidth: 280, idealWidth: 280, maxWidth: 320, minHeight: 260, idealHeight: 280, maxHeight: 320, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Constants.Colors.transparentBlack, radius: 6, x: 0, y: 8)
                }
            }

        }
        .sheet(isPresented: $showingInfoView) {
            InfoView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
