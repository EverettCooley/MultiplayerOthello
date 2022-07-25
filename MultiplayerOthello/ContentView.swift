import SwiftUI

struct ContentView: View {
    
    // current game state
    @State var board = [[0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0],
                        [0,0,0,1,2,0,0,0],
                        [0,0,0,2,1,0,0,0],
                        [0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0]]

    @State var playersTurn = "Player Black's turn"
    @State var whiteScore = 2
    @State var blackScore = 2
    @State var gameOverState = false

    // possible cirlce colors
    let colors = [Color.green, Color.white, Color.black]
    
    var body: some View {
        GeometryReader{ g in
            VStack{
                Text(playersTurn)
                    .padding(5)
                    .font(Font.system(size: g.size.width * 0.09))
                HStack{
                    Text("White Score is:")
                        .font(Font.system(size: g.size.width * 0.05))
                    Text(String(getBoardScore()[0]))
                        .font(Font.system(size: g.size.width * 0.05))
                }
                HStack{
                    Text("Black Score is:")
                        .font(Font.system(size: g.size.width * 0.05))
                    Text(String(getBoardScore()[1]))
                        .font(Font.system(size: g.size.width * 0.05))
                }
                ZStack{ // game board
                    HStack(spacing: 0){
                        ForEach(0..<8) { i in
                            VStack(spacing: 0){
                                ForEach((0..<8)){ j in
                                    Rectangle()
                                        .fill(Color.green)
                                        .border(Color.black, width: 1)
                                        .frame(width: CGFloat(g.size.width / 8), height: CGFloat(g.size.width / 8))
                                        .onTapGesture { squarePressed(x: i, y: j)}
                                }
                            }
                        }
                    }
                    HStack(spacing: 0){
                        ForEach(0..<8) { i in
                            VStack(spacing: 0){
                                ForEach((0..<8)){ j in
                                    Circle()
                                        .fill(colors[board[j][i]])
                                        .border(Color.black, width: 1)
                                        .frame(width: CGFloat(g.size.width / 8), height: CGFloat(g.size.width / 8))
                                        .onTapGesture { squarePressed(x: i, y: j)}
                                }
                            }
                        }
                    }
                }
                Spacer()
                Button("reset game"){
                    resetGame()
                }
                .font(Font.system(size: g.size.width * 0.06))
                .foregroundColor(Color.red)
            }
            .background(Color.gray)
        }
    }
    
    // function called after click on the grid
    func squarePressed(x: Int, y: Int){
        
        if gameOverState == true{
            gameOverState = false
            resetGame()
        }
        
        if board[y][x] != 0 {return}
        
        // set current player
        var currentPlayer = 0
        if playersTurn == "Player White's turn"{
            currentPlayer = 1
        }
        else if playersTurn == "Player Black's turn"{
            currentPlayer = 2
        }
        else{
            print("error currentPlayer = 0 in squarePressed")
        }
        
        var flipped = 0
        // scans
        flipped += scanTopDown(x: x, y: y, currentPlayer: currentPlayer, draw: true)
        flipped += scanBotomUp(x: x, y: y, currentPlayer: currentPlayer, draw: true)
        flipped += scanLeftRight(x: x, y: y, currentPlayer: currentPlayer, draw: true)
        flipped += scanRightLeft(x: x, y: y, currentPlayer: currentPlayer, draw: true)
        flipped += scanTopLeft2BottomRight(x: x, y: y, currentPlayer: currentPlayer, draw: true)
        flipped += scanBottomRight2TopLeft(x: x, y: y, currentPlayer: currentPlayer, draw: true)
        flipped += scanTopRight2BottomLeft(x: x, y: y, currentPlayer: currentPlayer, draw: true)
        flipped += scanBottomLeft2TopRight(x: x, y: y, currentPlayer: currentPlayer, draw: true)
        
        if flipped > 0 { board[y][x] = currentPlayer }
        else {return} // dont switch turns if didnt flip over square
        
        // switch turns
        if playersTurn == "Player White's turn"{
            playersTurn = "Player Black's turn"
        }
        else if playersTurn == "Player Black's turn"{
            playersTurn = "Player White's turn"
        }
        else{
            print("error switching turns in squarePressed")
        }
        calcIfGamover()
    }
    
    // returns the number of circles each player has
    func getBoardScore() -> [Int]{
        var oneCount = 0
        var twoCount = 0
        for i in 0...7{
            for j in 0...7{
                if board[j][i] == 1{
                    oneCount += 1
                }
                else if board[j][i] == 2{
                    twoCount += 1
                }
            }
        }
        return [oneCount, twoCount]
    }
    
    func resetGame(){
        board = [[0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0],
                 [0,0,0,1,2,0,0,0],
                 [0,0,0,2,1,0,0,0],
                 [0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0]]
        playersTurn = "Player Black's turn"
        whiteScore = 2
        blackScore = 2
    }
    
    // check if there are any possible moves
    func calcIfGamover(){
        var blackHasMove = false
        var whiteHasMove = false
        for i in 0...7{
            for j in 0...7{
                if board[j][i] != 0{continue}
                
                // check if white has any moves
                // scan functions are passed false for draw as we are just trying to search for possible moves
                // not draw to the screen
                var moves = 0
                moves += scanTopDown(x: i, y: j, currentPlayer: 1, draw: false)
                moves += scanBotomUp(x: i, y: j, currentPlayer: 1, draw: false)
                moves += scanLeftRight(x: i, y: j, currentPlayer: 1, draw: false)
                moves += scanRightLeft(x: i, y: j, currentPlayer: 1, draw: false)
                moves += scanTopLeft2BottomRight(x: i, y: j, currentPlayer: 1, draw: false)
                moves += scanBottomRight2TopLeft(x: i, y: j, currentPlayer: 1, draw: false)
                moves += scanTopRight2BottomLeft(x: i, y: j, currentPlayer: 1, draw: false)
                moves += scanBottomLeft2TopRight(x: i, y: j, currentPlayer: 1, draw: false)
                if moves > 0{whiteHasMove = true}

                // check if black has any moves
                moves = 0
                moves += scanTopDown(x: i, y: j, currentPlayer: 2, draw: false)
                moves += scanBotomUp(x: i, y: j, currentPlayer: 2, draw: false)
                moves += scanLeftRight(x: i, y: j, currentPlayer: 2, draw: false)
                moves += scanRightLeft(x: i, y: j, currentPlayer: 2, draw: false)
                moves += scanTopLeft2BottomRight(x: i, y: j, currentPlayer: 2, draw: false)
                moves += scanBottomRight2TopLeft(x: i, y: j, currentPlayer: 2, draw: false)
                moves += scanTopRight2BottomLeft(x: i, y: j, currentPlayer: 2, draw: false)
                moves += scanBottomLeft2TopRight(x: i, y: j, currentPlayer: 2, draw: false)
                if moves > 0{blackHasMove = true}
            }
        }

        if blackHasMove == false || whiteHasMove == false{
            let scores = getBoardScore()
            if scores[0] > scores[1]{
                playersTurn = "WHITE WON THE GAME!"
            }
            else if scores[0] < scores[1]{
                playersTurn = "BLACK WON THE GAME!"
            }
            else{
                playersTurn = "THE GAME ENDS IN A TIE!"
            }
            gameOverState = true
        }
    }
    
    // start of scans
    func scanTopDown(x: Int, y: Int, currentPlayer: Int, draw: Bool) -> Int{
        // scan to bottom
        var foundPlayerColor = false
        var intial = 1
        var steps = 1
        
        if y == 7 {return 0} // no need to scan to bottom if y is already at max bottom
        
        // search for player color
        for i in stride(from: y, through: 7, by: 1){
            
            if intial == 1{ intial = 0
                continue
            }
            
            if (board[i][x] == 0){break}  // found green; break
            
            if(board[i][x] == currentPlayer){
                foundPlayerColor = true
                break
            } // found playerColor; break
    
            steps += 1
        }
        
        // flip over circles
        var flipped = 0
        if(foundPlayerColor && steps > 1){
            if draw == false {return 1}
            flipped = 1
            for i in stride(from: y+1, through: 7, by: 1){
                if board[i][x] == currentPlayer{break} // found playerColor; break
                board[i][x] = currentPlayer
            }
        }
        return flipped
    }
    
    func scanBotomUp(x: Int, y: Int, currentPlayer: Int, draw: Bool) -> Int{
        var foundPlayerColor = false
        var intial = true
        var steps = 1
        
        if y == 0 {return 0}

        // search for player color
        for i in stride(from: y, through: 0, by: -1){
            if intial == true{
                intial = false
                continue
            }
            
            if (board[i][x] == 0){break} // found green; break
            
            if(board[i][x] == currentPlayer){ // found playerColor; break
                foundPlayerColor = true
                break
            }
            steps += 1
        }
        
        var flipped = 0
        if(foundPlayerColor && steps > 1){
            if draw == false {return 1}
            flipped = 1
            for i in stride(from: y-1, through: 0, by: -1){
                if board[i][x] == currentPlayer{ // found playerColor; break
                    break
                }
                board[i][x] = currentPlayer
            }
        }
        return flipped
    }
    
    func scanLeftRight(x: Int, y: Int, currentPlayer: Int, draw: Bool) -> Int{
        var foundPlayerColor = false
        var intial = true
        var steps = 1
        
        if x == 7 {return 0}

        // search for player color
        for i in stride(from: x, through: 7, by: 1){
            if intial == true{
                intial = false
                continue
            }

            if (board[y][i] == 0){break} // found green
            
            if(board[y][i] == currentPlayer){ // found playerColor; break
                foundPlayerColor = true
                break
            }
            steps += 1
        }
        
        // flip over circles
        var flipped = 0
        if(foundPlayerColor && steps > 1){
            if draw == false {return 1}
            flipped = 1
            for i in stride(from: x+1, through: 7, by: 1){
                if board[y][i] == currentPlayer{ // found playerColor; break
                    break
                }
                board[y][i] = currentPlayer
            }
        }
        return flipped
    }
    
    func scanRightLeft(x: Int, y: Int, currentPlayer: Int, draw: Bool) -> Int{
        var foundPlayerColor = false
        var intial = true
        var steps = 1
        
        if x == 0 {return 0}
        
        // search for player color
        for i in stride(from: x, through: 0, by: -1){
            if intial == true{
                intial = false
                continue
            }

            if (board[y][i] == 0){break} // found green
            
            if(board[y][i] == currentPlayer){ // found playerColor; break
                foundPlayerColor = true
                break
            }
            steps += 1
        }
        
        // flip over circles
        var flipped = 0
        if(foundPlayerColor && steps > 1){
            if draw == false {return 1}
            flipped = 1
            for i in stride(from: x-1, through: 0, by: -1){
                if board[y][i] == currentPlayer{ // found playerColor; break
                    break
                }
                board[y][i] = currentPlayer
            }
        }
        return flipped
    }
    
    func scanTopLeft2BottomRight(x: Int, y: Int, currentPlayer: Int, draw: Bool) -> Int{
        
        var foundPlayerColor = false
        var steps = 1
        var intial = true
        
        // search for player color
        for i in stride(from: 0, through: 7, by: 1){
            
            if intial == true{intial = false
                continue
            }
            
            if x+i > 7 || y+i > 7 {break}

            if (board[y+i][x+i] == 0){break}  // found green
            
            if(board[y+i][x+i] == currentPlayer){ // found playerColor; break
                foundPlayerColor = true
                break
            }
            steps += 1
        }
        
        // flip over circles
        var flipped = 0
        if(foundPlayerColor && steps > 1){
            if draw == false {return 1}
            intial = true
            flipped = 1
            for i in stride(from: 0, through: 7, by: 1){
                
                if intial == true{intial = false; continue}
                
                if x+i > 7 || y+i > 7 {break}
                
                if board[y+i][x+i] == currentPlayer{break}  // found playerColor; break
                
                board[y+i][x+i] = currentPlayer
            }
        }
        return flipped
    }
    
    func scanBottomRight2TopLeft(x: Int, y: Int, currentPlayer: Int, draw: Bool) -> Int{
        
        var foundPlayerColor = false
        var steps = 1
        var intial = true
        
        // search for player color
        for i in stride(from: 0, through: 7, by: 1){
            
            if intial == true{intial = false
                continue
            }
            
            if x-i < 0 || y-i < 0 {break}
            
            if (board[y-i][x-i] == 0){break}  // found green
            
            if(board[y-i][x-i] == currentPlayer){ // found playerColor; break
                foundPlayerColor = true
                break
            }
            steps += 1
        }
        
        // flip over circles
        var flipped = 0
        if(foundPlayerColor && steps > 1){
            if draw == false {return 1}
            intial = true
            flipped = 1
            for i in stride(from: 0, through: 7, by: 1){

                if intial == true{intial = false; continue}

                if x-i > 7 || y-i > 7 {break}

                if board[y-i][x-i] == currentPlayer{break}  // found playerColor; break

                board[y-i][x-i] = currentPlayer
            }
        }
        return flipped
    }
    
    func scanTopRight2BottomLeft(x: Int, y: Int, currentPlayer: Int, draw: Bool) -> Int{
        
        var foundPlayerColor = false
        var steps = 1
        var intial = true
        
        // search for player color
        for i in stride(from: 0, through: 7, by: 1){
            
            if intial == true{intial = false; continue}
            if x-i < 0 || y+i > 7 {break}
            
            if (board[y+i][x-i] == 0){break}  // found green

            if(board[y+i][x-i] == currentPlayer){ // found playerColor; break
                foundPlayerColor = true
                break
            }
            steps += 1
        }
        
        // flip over circles
        var flipped = 0
        if(foundPlayerColor && steps > 1){
            if draw == false {return 1}
            intial = true
            flipped = 1
            for i in stride(from: 0, through: 7, by: 1){

                if intial == true{intial = false; continue}

                if x-i < 0 || y+i > 7 {break}

                if board[y+i][x-i] == currentPlayer{break}  // found playerColor; break

                board[y+i][x-i] = currentPlayer
            }
        }
        return flipped
    }
    
    func scanBottomLeft2TopRight(x: Int, y: Int, currentPlayer: Int, draw: Bool) -> Int{
        
        var foundPlayerColor = false
        var steps = 1
        var intial = true
        
        // search for player color
        for i in stride(from: 0, through: 7, by: 1){
            
            if intial == true{intial = false; continue}
            if x+i > 7 || y-i < 0 {break}
            
            if (board[y-i][x+i] == 0){break}  // found green

            if(board[y-i][x+i] == currentPlayer){ // found playerColor; break
                foundPlayerColor = true
                break
            }
            steps += 1
        }
        
        // flip over circles
        var flipped = 0
        if(foundPlayerColor && steps > 1){
            if draw == false {return 1}
            intial = true
            flipped = 1
            for i in stride(from: 0, through: 7, by: 1){

                if intial == true{intial = false; continue}

                if x+i > 7 || y-i < 0 {break}

                if board[y-i][x+i] == currentPlayer{break}  // found playerColor; break

                board[y-i][x+i] = currentPlayer
            }
        }
        return flipped
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
