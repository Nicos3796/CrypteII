import GameplayKit
import SpriteKit

//Etat du jeu
enum GameState {
	case showingLogo
	case playing
	case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	var player: SKSpriteNode!
	var backgroundMusic: SKAudioNode!

	var logo: SKSpriteNode!
	var gameOver: SKSpriteNode!
	var gameState = GameState.showingLogo

	var scoreLabel: SKLabelNode!
    var HighscoreLabel: SKLabelNode!

	var score = 0 {
		didSet {
			scoreLabel.text = "SCORE: \(score)"
		}
	}

    override func didMove(to view: SKView) {
		createSky()
		createBackground()
		createGround()
		createLogos()

		physicsWorld.gravity = CGVector(dx: 0.0, dy: -7.0) //Gravité du monde
		physicsWorld.contactDelegate = self
        
        //Affichage Highscore
        let userScore = UserDefaults()
        userScore.highScore = score
        
        HighscoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        HighscoreLabel.fontSize = 24
        
        HighscoreLabel.position = CGPoint(x: frame.maxX - 80, y: frame.maxY - 525)
        HighscoreLabel.horizontalAlignmentMode = .right
        HighscoreLabel.text = "HIGHSCORE : \(userScore.highScore)"
        HighscoreLabel.fontColor = UIColor.black
        
        addChild(HighscoreLabel)
    

        //Création d'une musique de fond
		if let musicURL = Bundle.main.url(forResource: "music", withExtension: "mp3") {
			backgroundMusic = SKAudioNode(url: musicURL)
			addChild(backgroundMusic)
		}
    }

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		switch gameState {
		case .showingLogo:
			gameState = .playing
            HighscoreLabel.alpha = 0
            createPlayer()
            createScore()
			let fadeOut = SKAction.fadeOut(withDuration: 0.5)
			let remove = SKAction.removeFromParent()
			let wait = SKAction.wait(forDuration: 0.5)
			let activatePlayer = SKAction.run { [unowned self] in
				self.player.physicsBody?.isDynamic = true
				self.startRocks()
			}

			let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
			logo.run(sequence)
            

		case .playing:
			player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
			player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60)) //Force du saut

		case .dead:
			let scene = GameScene(fileNamed: "GameScene")!
			let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
			self.view?.presentScene(scene, transition: transition)
        
		}
	}

	func createPlayer() {
		let playerTexture = SKTexture(imageNamed: "player-1")
		player = SKSpriteNode(texture: playerTexture)
		player.zPosition = 10
		player.position = CGPoint(x: frame.width / 6, y: frame.height * 0.75)

		addChild(player)

		player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
		player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
		player.physicsBody?.isDynamic = false

		player.physicsBody?.collisionBitMask = 0

		let frame2 = SKTexture(imageNamed: "player-2")
		let animation = SKAction.animate(with: [playerTexture, frame2, playerTexture, frame2], timePerFrame: 0.2)
		let runForever = SKAction.repeatForever(animation)

		player.run(runForever)
	}

	func createSky() {
        //Création du ciel au dessus du background
		let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
		topSky.anchorPoint = CGPoint(x: 0.5, y: 1)

		let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
		topSky.anchorPoint = CGPoint(x: 0.5, y: 1)

		topSky.position = CGPoint(x: frame.midX, y: frame.height)
		bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height / 2)

		addChild(topSky)
		addChild(bottomSky)

		bottomSky.zPosition = -40
		topSky.zPosition = -40
	}

	func createBackground() {
		let backgroundTexture = SKTexture(imageNamed: "background")

		for i in 0 ... 1 {
			let background = SKSpriteNode(texture: backgroundTexture)
			background.zPosition = -30
			background.anchorPoint = CGPoint.zero
			background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 100)
			addChild(background)

            //Animation du background
			let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
			let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
			let moveLoop = SKAction.sequence([moveLeft, moveReset])
			let moveForever = SKAction.repeatForever(moveLoop)

			background.run(moveForever)
		}
	}

	func createGround() {
		let groundTexture = SKTexture(imageNamed: "ground")

		for i in 0 ... 1 {
			let ground = SKSpriteNode(texture: groundTexture)
			ground.zPosition = -10
			ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))), y: groundTexture.size().height / 2)

			ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: ground.texture!.size())
			ground.physicsBody?.isDynamic = false

			addChild(ground)

			let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 6.75)
			let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
			let moveLoop = SKAction.sequence([moveLeft, moveReset])
			let moveForever = SKAction.repeatForever(moveLoop)

			ground.run(moveForever)
		}
	}

	func createScore() {
        //Score
		scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
		scoreLabel.fontSize = 24

		scoreLabel.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 40)
		scoreLabel.horizontalAlignmentMode = .right
		scoreLabel.text = "SCORE : 0"
		scoreLabel.fontColor = UIColor.black

		addChild(scoreLabel)
        
	}

	func createLogos() {
		logo = SKSpriteNode(imageNamed: "logo")
		logo.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(logo)

		gameOver = SKSpriteNode(imageNamed: "gameover")
		gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
		gameOver.alpha = 0
		addChild(gameOver)
	}

	func createRocks() {
		// Création des textures des pilliers
		let rockTexture = SKTexture(imageNamed: "rock")
    

		let topRock = SKSpriteNode(texture: rockTexture)
		topRock.physicsBody = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
		topRock.physicsBody?.isDynamic = false
		topRock.zRotation = CGFloat(M_PI)
		topRock.xScale = -1.0

		let bottomRock = SKSpriteNode(texture: rockTexture)
		bottomRock.physicsBody = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
		bottomRock.physicsBody?.isDynamic = false
		topRock.zPosition = -20
		bottomRock.zPosition = -20


		// Création des collisions de Score
		let rockCollision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 32, height: frame.height))
		rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
		rockCollision.physicsBody?.isDynamic = false
		rockCollision.name = "scoreDetect"

		addChild(topRock)
		addChild(bottomRock)
		addChild(rockCollision)


		// Position des pilliers
		let xPosition = frame.width + topRock.frame.width

		let max = Int(frame.height / 3)
		let rand = GKRandomDistribution(lowestValue: -100, highestValue: max)
		let yPosition = CGFloat(rand.nextInt())

		// Change le gap entre les pilliers
        var rockDistance: CGFloat
        rockDistance = 120
        
        if score > 20 {
            rockDistance = 90
        }else if score > 15 {
            rockDistance = 100
        }else if score > 10 {
            rockDistance = 110
        }else if score > 5{
            rockDistance = 120
        }
        

		// Position général
		topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height + rockDistance)
		bottomRock.position = CGPoint(x: xPosition, y: yPosition - rockDistance)
		rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width), y: frame.midY)

		let endPosition = frame.width + (topRock.frame.width * 2)

		let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
		let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
		topRock.run(moveSequence)
		bottomRock.run(moveSequence)
		rockCollision.run(moveSequence)
	}

    //Fonction qui permet de créer des pilliers en permanence
	func startRocks() {
		let create = SKAction.run { [unowned self] in
			self.createRocks()
		}

		let wait = SKAction.wait(forDuration: 3)
		let sequence = SKAction.sequence([create, wait])
		let repeatForever = SKAction.repeatForever(sequence)

		run(repeatForever)
	}

	override func update(_ currentTime: TimeInterval) {
		guard player != nil else { return }

		let value = player.physicsBody!.velocity.dy * 0.001
		let rotate = SKAction.rotate(toAngle: value, duration: 0.1)

		player.run(rotate)
	}

    // Gestion des collisions
	func didBegin(_ contact: SKPhysicsContact) {
        //Collision avec les colonnes de scores
		if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
			if contact.bodyA.node == player {
				contact.bodyB.node?.removeFromParent()
			} else {
				contact.bodyA.node?.removeFromParent()
			}

			let sound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
			run(sound)

			score += 1

			return
		}

        guard contact.bodyA.node != nil && contact.bodyB.node != nil else {
            return
        }

        //Si le joueur rentre en contact avec un autre block de collision
		if contact.bodyA.node == player || contact.bodyB.node == player {
			if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
				explosion.position = player.position
				addChild(explosion)
			}

            //Son activé lors de la mort du joueur
            let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
			run(sound)

			gameOver.alpha = 1
			gameState = .dead
			backgroundMusic.run(SKAction.stop())

			player.removeFromParent()
			speed = 0
            
            //Sauvegarde du score
            print("Votre score : \(score)")
            let userScore = UserDefaults()
            userScore.highScore = score
            
            //Affichage Highscore
            HighscoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
            HighscoreLabel.fontSize = 24
            
            HighscoreLabel.position = CGPoint(x: frame.maxX - 80, y: frame.maxY - 380)
            HighscoreLabel.horizontalAlignmentMode = .right
            HighscoreLabel.text = "HIGHSCORE : \(userScore.highScore)"
            HighscoreLabel.fontColor = UIColor.black
            
            addChild(HighscoreLabel)
            
            
		}

	}
}

//Gestion des scores
extension UserDefaults {
    static let highScoreIntegerKey = "highScoreInteger"
    
    var highScore: Int {
        get {
            print("High Score : ", integer(forKey: UserDefaults.highScoreIntegerKey))
            return integer(forKey: UserDefaults.highScoreIntegerKey)
        }
        set {
            guard newValue > highScore
                else {
                    print("\(newValue) ≤ \(highScore) Réessayer")
                    return
            }
            //Sauvegarde du nouveau score
            set(newValue, forKey: UserDefaults.highScoreIntegerKey)
            print("Nouveau High Score : ", highScore)
        }
    }
    //Fonction à utiliser pour remettre le highscore à 0
    func resetHighScore() {
        removeObject(forKey: UserDefaults.highScoreIntegerKey)
        print("removed object for highScoreIntegerKey")
    }
    
}
