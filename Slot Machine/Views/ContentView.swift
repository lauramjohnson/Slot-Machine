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
    let haptics = UINotificationFeedbackGenerator()
    
    @State private var reels: Array = [0, 1, 2]
    @State private var showingInfoView: Bool = false
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "HighScore")
    @State private var coins: Int = 100
    @State private var betAmount: Int = 10
    @State private var showGameOverModal: Bool = false
    @State private var animatingSymbol: Bool = false
    @State private var showSymbols: Bool = true
    @State private var animatingModal: Bool = false
    
    // MARK:  - functions
    
    // spin reels
    func spinReels() {
        reels = reels.map({ _ in
            Int.random(in: 0...symbols.count - 1)
        })
        playSound(sound: "spin", type: "mp3")
        haptics.notificationOccurred(.success)
    }
    
    // check spin status
    func checkSpinStatus() {
        if reels[0] == reels[1] && reels[2] == reels[1] {
            // player wins
            playerWins()
            // new high score
            if coins > highScore {
                newHighScore()
            } else {
                playSound(sound: "win", type: "mp3")
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
        playSound(sound: "high-score", type: "mp3")

    }
    
    func playerLoses() {
        coins -= betAmount
    }
    
    func isGameOver() {
        if coins <= 0 {
            showGameOverModal = true
            playSound(sound: "game-over", type: "mp3")
        }
    }
    
    func resetGame(clearHighScore: Bool) {
        animatingModal = false
        coins = 100
        betAmount = 10
        showGameOverModal = false
        playSound(sound: "chimeup", type: "mp3")
        haptics.notificationOccurred(.success)

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
                        if showSymbols {
                            Image(symbols[reels[0]])
                                .resizable()
                                .modifier(ImageModifier())
                                .opacity(animatingSymbol ? 1 : 0)
                                .offset(y: animatingSymbol ? 0 : -50)
                                .animation(.easeOut(duration: Double.random(in: 0.5...0.7)), value: animatingSymbol)
                                .onAppear(perform: {
                                    self.animatingSymbol.toggle()
                            })
                        }
                    }
                    
                    // MARK:  - reel 2
                    HStack(alignment: .center, spacing: 0) {
                        ZStack {
                            ReelView()
                            if showSymbols {
                                Image(symbols[reels[1]])
                                    .resizable()
                                    .modifier(ImageModifier())
                                    .opacity(animatingSymbol ? 1 : 0)
                                    .offset(y: animatingSymbol ? 0 : -50)
                                    .animation(.easeOut(duration: Double.random(in: 0.7...0.9)), value: animatingSymbol)
                                    .onAppear(perform: {
                                        self.animatingSymbol.toggle()
                                })
                            }
                        }
                        
                        Spacer()
                        
                        // MARK:  - reel 3
                        ZStack {
                            ReelView()
                            if showSymbols {
                                Image(symbols[reels[2]])
                                    .resizable()
                                    .modifier(ImageModifier())
                                    .opacity(animatingSymbol ? 1 : 0)
                                    .offset(y: animatingSymbol ? 0 : -50)
                                    .animation(.easeOut(duration: Double.random(in: 0.9...1.1)), value: animatingSymbol)
                                    .onAppear(perform: {
                                        self.animatingSymbol = true
                                        playSound(sound: "rise-up", type: "mp3")
                                    })
                                    .onDisappear(perform: {
                                        self.animatingSymbol = false
                                        showSymbols.toggle()
                                    })
                            }
                        }
                    }
                    .frame(maxWidth: 500)
                    
                    // MARK:  - spin button
                    
                    Button(action: {
                        showSymbols.toggle()

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
                            playSound(sound: "casino-chips", type: "mp3")
                            haptics.notificationOccurred(.success)

                        }) {
                            Text("20")
                                .fontWeight(.heavy)
                                .foregroundColor(betAmount == 20 ? Constants.Colors.yellow : Color.white)
                                .modifier(BetNumberModifier())
                        }
                        .modifier(BetCapsuleModifier())
                        
                        Image("gfx-casino-chips")
                            .resizable()
                            .offset(x: betAmount == 20 ? 0 : 20)
                            .opacity(betAmount == 20 ? 1 : 0)
                            .modifier(CasinoChipsModifier())
                    }
                    
                    Spacer()
                    
                    // MARK:  - bet 10
                    HStack(alignment: .center, spacing: 10) {
                        Image("gfx-casino-chips")
                            .resizable()
                            .offset(x: betAmount == 10 ? 0 : -20)
                            .opacity(betAmount == 10 ? 1 : 0)
                            .modifier(CasinoChipsModifier())
                        
                        Button(action: {
                            betAmount = 10
                            playSound(sound: "casino-chips", type: "mp3")
                            haptics.notificationOccurred(.success)

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
                    .opacity(animatingModal ? 1 : 0)
                    .offset(y: animatingModal ? 0 : -100)
                    .animation(Animation.spring(response: 0.6, dampingFraction: 1.0, blendDuration: 1.0), value: animatingModal)
                    .shadow(color: Constants.Colors.transparentBlack, radius: 6, x: 0, y: 8)
                    .onAppear(perform: {
                        self.animatingModal = true
                    })
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
