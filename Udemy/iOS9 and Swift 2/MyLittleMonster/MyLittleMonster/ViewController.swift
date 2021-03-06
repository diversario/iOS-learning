//
//  ViewController.swift
//  MyLittleMonster
//
//  Created by Ilya Shaisultanov on 1/6/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var chooseLabel: UILabel!
    @IBOutlet weak var monsterChooseBtn: UIButton!
    @IBOutlet weak var slugChooseBtn: UIButton!
    
    @IBOutlet weak var monsterImg: MonsterImg!
    @IBOutlet weak var slugImg: SlugImg!
    @IBOutlet weak var characterImg: AnimatedImage!
    @IBOutlet weak var foodImg: DragImg!
    @IBOutlet weak var heartImg: DragImg!
    
    @IBOutlet weak var penalty1Img: UIImageView!
    @IBOutlet weak var penalty2Img: UIImageView!
    @IBOutlet weak var penalty3Img: UIImageView!
    
    @IBOutlet weak var livesPanel: UIImageView!
    @IBOutlet weak var skulls: UIStackView!
    @IBOutlet weak var foodHeart: UIStackView!
    
    @IBOutlet weak var rockImage: UIImageView!
    @IBOutlet weak var plantImg: UIImageView!
    
    @IBOutlet weak var gameOverLabel: UILabel!
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
    
    var penalties = 0
    var timer: NSTimer!
    var monsterHappy = false
    var currentItem: UInt32 = 0
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHeart: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector: "itemDroppedOnCharacter:", name: "onTargetDropped", object: nil)
        
        do {
            var resoursePath = NSBundle.mainBundle().pathForResource("cave-music", ofType: "mp3")!
            try musicPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: resoursePath))

            resoursePath = NSBundle.mainBundle().pathForResource("bite", ofType: "wav")!
            try sfxBite = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: resoursePath))
            
            resoursePath = NSBundle.mainBundle().pathForResource("heart", ofType: "wav")!
            try sfxHeart = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: resoursePath))
            
            resoursePath = NSBundle.mainBundle().pathForResource("death", ofType: "wav")!
            try sfxDeath = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: resoursePath))
            
            resoursePath = NSBundle.mainBundle().pathForResource("skull", ofType: "wav")!
            try sfxSkull = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: resoursePath))
            
            musicPlayer.prepareToPlay()
            musicPlayer.volume = 0.01
            musicPlayer.play()
            
            sfxBite.prepareToPlay()
            sfxBite.volume = 0.01
            
            sfxHeart.prepareToPlay()
            sfxHeart.volume = 0.01
            
            sfxDeath.prepareToPlay()
            sfxDeath.volume = 0.01
            
            sfxSkull.prepareToPlay()
            sfxSkull.volume = 0.01
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        startGame()
    }

    func startGame (){
        penalty1Img.alpha = DIM_ALPHA
        penalty2Img.alpha = DIM_ALPHA
        penalty3Img.alpha = DIM_ALPHA

        chooseLabel.hidden = false
        monsterChooseBtn.hidden = false
        slugChooseBtn.hidden = false
        gameOverLabel.hidden = true
        
        monsterImg.hidden = true
        slugImg.hidden = true
        
        livesPanel.hidden = true
        skulls.hidden = true
        foodHeart.hidden = true
        
        rockImage.hidden = true
        plantImg.hidden = true
        
        penalties = 0
        monsterHappy = false
        currentItem = 0
    }
    
    @IBAction func selectCharacter (sender: UIButton) {
        if sender.tag == 0 {
            characterImg = monsterImg
            rockImage.hidden = false
        } else {
            characterImg = slugImg
            plantImg.hidden = false
        }
        
        foodImg.dropTarget = characterImg
        heartImg.dropTarget = characterImg
        characterImg.playIdleAnimation()
        
        chooseLabel.hidden = true
        monsterChooseBtn.hidden = true
        slugChooseBtn.hidden = true
        
        characterImg.hidden = false
        livesPanel.hidden = false
        skulls.hidden = false
        foodHeart.hidden = false
        
        startTimer()
    }
    
    func itemDroppedOnCharacter (notif: AnyObject) {
        monsterHappy = true
        startTimer()
        
        foodImg.alpha = DIM_ALPHA
        foodImg.userInteractionEnabled = false
        heartImg.alpha = DIM_ALPHA
        heartImg.userInteractionEnabled = false
        
        if currentItem == 0 {
            sfxHeart.play()
        } else {
            sfxBite.play()
        }
    }
    
    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeGameState", userInfo: nil, repeats: true)
    }
    
    func changeGameState() {
        if !monsterHappy {
            penalties++
            
            sfxSkull.play()
            
            switch(penalties) {
            case 1:
                penalty1Img.alpha = OPAQUE
                penalty2Img.alpha = DIM_ALPHA
                break
            case 2:
                penalty2Img.alpha = OPAQUE
                penalty3Img.alpha = DIM_ALPHA
                break
            case 3:
                penalty3Img.alpha = OPAQUE
                break
            default:
                penalty1Img.alpha = DIM_ALPHA
                penalty2Img.alpha = DIM_ALPHA
                penalty3Img.alpha = DIM_ALPHA
            }
            
            if penalties >= MAX_PENALTIES {
                gameOver()
            }
        }
        
        let rand = arc4random_uniform(2)
        
        if rand == 0 {
            foodImg.alpha = DIM_ALPHA
            foodImg.userInteractionEnabled = false
            heartImg.alpha = OPAQUE
            heartImg.userInteractionEnabled = true
        } else {
            foodImg.alpha = OPAQUE
            foodImg.userInteractionEnabled = true
            heartImg.alpha = DIM_ALPHA
            heartImg.userInteractionEnabled = false
        }
        
        currentItem = rand
        monsterHappy = false
    }
    
    func gameOver() {
        timer.invalidate()
        characterImg.playDeathAnimation()
        sfxDeath.play()
        
        foodImg.userInteractionEnabled = false
        heartImg.userInteractionEnabled = false
        
        gameOverLabel.hidden = false
        
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "startGame", userInfo: nil, repeats: false)
    }
}

