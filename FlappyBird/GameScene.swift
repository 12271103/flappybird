//
//  File.swift
//  FlappyBird
//
//  Created by 柳澤宏輔 on 2017/08/20.
//  Copyright © 2017年 kousuke.yanagisawa. All rights reserved.
//

import SpriteKit


class GameScene:SKScene, SKPhysicsContactDelegate{
  
  var scrollNode:SKNode!
  var wallNode:SKNode!
  var bird:SKSpriteNode!
  var itemNode:SKNode!
  var itemSprite:SKSpriteNode!
  
  //衝突判定カテゴリー
  let birdCategory: UInt32 = 1 << 0
  let groundCategory: UInt32 = 1 << 1
  let wallCategory: UInt32 = 1 << 2
  let scoreCategory: UInt32 = 1 << 3
  let itemCategory: UInt32 = 1 << 4
  
  //スコア
  //壁の隙間に見えない物体を作り、これとの衝突をカウントする
  var score = 0
  var scoreLabelNode:SKLabelNode!
  var bestScoreLabelNode:SKLabelNode!
  let userDefaults:UserDefaults = UserDefaults.standard
  
  
  //アイテム
  var item = 0
  var itemLabelNode:SKLabelNode!
  
  //効果音用
  var seItem:SKAction?
  var seGameover:SKAction?
  
  
  //SKView上にシーンが表示された時に呼ばれるメソッド
  //didmove:ゲーム画面（SKSceneを継承したクラス）が表示された時に呼ばれるメソッド
  override func didMove(to view: SKView) {
    
    //重力を設定
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
    physicsWorld.contactDelegate = self
    
    //背景色を設定
    backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
    
    //スクロールするスウプライトの親ノード
    //スクロールを一括で止められるようにするため。
    scrollNode = SKNode()
    addChild(scrollNode)
    
    //壁用のノード
    wallNode = SKNode()
    scrollNode.addChild(wallNode)
    
    //アイテム用のノード
    itemNode = SKNode()
    scrollNode.addChild(itemNode)
    
    //効果音を作成
    let seItem = SKAction.playSoundFileNamed("powerup03.mp3", waitForCompletion: false)
    self.seItem = seItem
    
    let seGameover = SKAction.playSoundFileNamed("powerdown07", waitForCompletion: false)
    self.seGameover = seGameover
    
    //各種スプライトを生成する処理
    setupGround()
    setupCloud()
    setupWall()
    setupBird()
    setupItem()
    setupScoreLabel()
  }
  
  
  
  
  func setupCloud(){
    //雲の画像を読み込む
    let cloudTexture = SKTexture(imageNamed:"cloud")
    cloudTexture.filteringMode = SKTextureFilteringMode.nearest
    
    //必要な枚数を計算
    let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
    
    //    スクロールするアクションを作成
    //    左方向に画像一枚文スクロール
    let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
    
    //    元の位置に戻す
    //durationは、元の位置に戻すために何秒かけるかを示している。
    let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)
    
    //    左ー＞元ー＞左　無限アクション
    let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud,resetCloud]))
    
    //    スプライトを配置
    stride(from: 0.0, to: needCloudNumber, by: 1.0).forEach{ i in
      let sprite = SKSpriteNode(texture: cloudTexture)
      sprite.zPosition = -100
      
      //スプライトの表示する位置を指定
      sprite.position = CGPoint(x:i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
      
      //スプライトにアクションを設定
      sprite.run(repeatScrollCloud)
      
      //スプライトを追加
      scrollNode.addChild(sprite)
      
    }
  }
  
  
  
  
  func setupGround(){
    //地面の画像を読み込む
    let groundTexture = SKTexture(imageNamed: "ground")
    groundTexture.filteringMode = SKTextureFilteringMode.nearest
    
    //必要な枚数を計算
    let needNumber:CGFloat = 2.0 + (frame.size.width / groundTexture.size().width)
    print(String(describing: type(of: needNumber)))
    
    //スクロールアクションを作成
    //左方向に画像一枚文スクロールさせる
    let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5.0)
    
    //元のいちに戻すアクション
    let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
    
    //左にスクロールー＞元のいちー＞左にスクロールと無限に切り替える
    let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))
    
    //groundのスプライトを配置する
    //forループになるらしい？
    //stride:範囲を作成する関数
    //なんでこの中に物理演算のプログラムを入れ込んだんだろう？
    stride(from: 0.0, to: needNumber, by: 1.0).forEach{ i in
      let sprite = SKSpriteNode(texture: groundTexture)
      print(i)
      
      //スプライトの表示する位置を指定する
      sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
      
      //スプライトにアクションを設定する
      sprite.run(repeatScrollGround)
      
      //スプライトに物理演算を設定する
      sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
      
      
      //衝突のカテゴリー設定
      sprite.physicsBody?.categoryBitMask = groundCategory
      
      //衝突の時に動かないように設定する
      sprite.physicsBody?.isDynamic = false
      
      //スプライトを追加する
      scrollNode.addChild(sprite)
    }
    
    //テクスチャを指定してスプライトを作成する
    let groundSprite = SKSpriteNode(texture: groundTexture)
    
    //スプライトの表示する位置を指定する
    groundSprite.position = CGPoint(x:size.width/2, y:groundTexture.size().height/2)
    
    //シーンにスプライトを追加する
    addChild(groundSprite)

  }
  
  
  
  
  func setupWall(){
    //壁の画像を読み込む
    let wallTexture = SKTexture(imageNamed: "wall")
    wallTexture.filteringMode = SKTextureFilteringMode.linear
    
    //移動する距離を計算
    let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
    
    //画面がいまで移動するアクションを作成
    let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4.0)
    
    //確認用
    print(movingDistance)
    
    //自身を取り除くアクションを作成
    let removeWall = SKAction.removeFromParent()
    
    //２つのアニメーションを順に実行するアクションを作成
    let WallAnimation = SKAction.sequence([moveWall,removeWall])
    
    //壁を生成するアクションを作成
    let createWallAnimation = SKAction.run({
      //壁関連のノードを乗せるノードを作成
      let wall = SKNode()
      wall.position = CGPoint(x:self.frame.size.width + wallTexture.size().width / 2,y:0.0)
      wall.zPosition = -50.0 //雲より手前、地面より奥
      
      //画面のy軸の中央ち
      let center_y = self.frame.size.height / 2
      
      //壁のy座標を上下ランダムにさせる時の最大値
      let random_y_range = self.frame.size.height / 4
      
      //下の壁のy軸の下限
      let under_wall_lowest_y = UInt32(center_y - wallTexture.size().height / 2 - random_y_range / 2)
      
      //1~random_y_rangeまでのランダムな整数を生成
      let random_y = arc4random_uniform(UInt32(random_y_range))
      
      //y軸の下限にランダムな値を足して、下の壁のy座標を決定
      let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
      
      //キャラが通り抜ける隙間の長さ
      let slit_length = self.frame.size.height/6
      
      //下側の壁を作成
      let under = SKSpriteNode(texture: wallTexture)
      under.position = CGPoint(x:0.0, y:under_wall_y)
      wall.addChild(under)
      
      //スプライトに物理演算を設定する
      under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
      under.physicsBody?.categoryBitMask = self.wallCategory
      
      //衝突の時に動かないようにする
      under.physicsBody?.isDynamic = false
      
      //上側の壁を作成
      let upper = SKSpriteNode(texture: wallTexture)
      upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
      
      //スプライトに物理演算を設定する
      upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
      upper.physicsBody?.categoryBitMask = self.wallCategory
      
      //衝突の時に動かないようにする
      upper.physicsBody?.isDynamic = false
      
      wall.addChild(upper)
      
      //スコアアップ用のノード：透明な物体を作成
      //横幅に鳥の大きさを加えているのはどうして？
      let scoreNode = SKNode()
      scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
      scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
      scoreNode.physicsBody?.isDynamic = false
      scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
      scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
      
      //scorenodeをwall（壁関連のノードを乗せるノード）の子ノードとして追加
      wall.addChild(scoreNode)
      
      //
      wall.run(WallAnimation)
      
      //
      self.wallNode.addChild(wall)
    })
    
    //次の壁作成までの待ち時間のアクションを作成
    let waitAnimation = SKAction.wait(forDuration: 2)
    
    //壁を作成ー＞待ち時間ー＞壁を作成　を無限に繰り返すアクションを作成
    let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
    
    wallNode.run(repeatForeverAnimation)
    
  }
  
  
  
  
  func setupBird(){
    //鳥の画像を読み込む
    let birdTextureA = SKTexture(imageNamed: "bird_a")
    birdTextureA.filteringMode = SKTextureFilteringMode.linear
    
    let birdTextureB = SKTexture(imageNamed: "bird_b")
    birdTextureB.filteringMode = SKTextureFilteringMode.linear
    
    
    //２種類のテクスチャを交互に変更するアニメーションを作成
    let textureAnimation = SKAction.animate(with: [birdTextureA,birdTextureB], timePerFrame: 0.2)
    let flap = SKAction.repeatForever(textureAnimation)
    
    
    //スプライトを作成
    bird = SKSpriteNode(texture: birdTextureA)
    bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
    //bird.position = CGPoint(x: 0, y: 0)　鳥の出現をかくにん！おかしいのはここか
    
    
    //物理演算を設定
    //一番下に追加しても正常に動作した。さすがにスプライト追加の下に置くのは見にくいからやめた方がいいのだろうけど
    bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
    
    
    //衝突した時に回転させない
    bird.physicsBody?.allowsRotation = false
    
    
    //衝突のカテゴリー設定
    bird.physicsBody?.categoryBitMask = birdCategory
    bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
    bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory


    //アニメーションを設定
    bird.run(flap)
    
    
    //スプライトを追加する
    //bird:クラスの初めに宣言したやつ。　var bird:SKSpriteNode!
    addChild(bird)
  }
  
  
  
  
  //@アイテムのメソッド
  func setupItem(){
    let itemTexture = SKTexture(imageNamed: "coin2")
    itemTexture.filteringMode = SKTextureFilteringMode.linear
    
    //移動する距離を計算
    let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width)
    
    //左方向に移動させるアクションを作成（これで画像１枚分動く単位のようなものが作れた
    let moveItem = SKAction.moveBy(x: -415.0, y: 0, duration: 4.0)
    
    //確認用
    print(movingDistance)
    print(self.size.width)
    
    //自身を取り除くアクションを作成
    let removeItem = SKAction.removeFromParent()
    
    
    //アイテムを生成するアクションを作成
    let createItemAnimation = SKAction.run({
     
      //アイテムの座標の目安
      let random_y_range = self.frame.size.height / 4
      
      //1〜random_y_rangeまでのランダムな整数を生成
      let random_y:CGFloat = CGFloat(arc4random_uniform( UInt32(3) ) + 1)
      
      //アイテム表示位置
      let itemIchi = random_y * random_y_range
      
      
      //spriteを作成
      let itemSprite = SKSpriteNode(texture: itemTexture)
      
      //スプライトの表示位置を指定
      //x:ちょうど画面外に隠れる　y:
      itemSprite.position = CGPoint(x: 490 + itemTexture.size().width / 2 , y: itemIchi)
      
      //無限にアクションさせる
      let repeatScrollItem = SKAction.repeatForever(moveItem)
      
      //スプライトにアクションを設定
      itemSprite.run(repeatScrollItem)
      
      //スプライトに物理演算を設定する
      itemSprite.physicsBody = SKPhysicsBody(rectangleOf: itemTexture.size())
      itemSprite.physicsBody?.categoryBitMask = self.itemCategory
      itemSprite.physicsBody?.contactTestBitMask = self.birdCategory
      
      //重力の影響を受けなくする
      itemSprite.physicsBody?.isDynamic = false
      
      //シーンにスプライトを追加
      //scrollNode.を文頭に追加。これでscrollnodeの子ノードとして認識される？
      self.itemNode.addChild(itemSprite)
      
    })
    
    //次のアイテム作成までの待ち時間のアクションを作成
    let waitAnimation = SKAction.wait(forDuration: 4)
    
    //壁を作成　まちじかん　を無限に繰り返す
    let repeatForeverAction = SKAction.repeatForever(SKAction.sequence([createItemAnimation,waitAnimation]))
    
    //
    itemNode.run(repeatForeverAction)
    
  }
  
  
  
  
  //画面をタップした時に呼ばれる
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if scrollNode.speed > 0{
      //鳥の速度をゼロにする
      bird.physicsBody?.velocity = CGVector.zero
      
      //鳥に縦方向の力を与える
      bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
      
    }else if bird.speed == 0{
      
      restart()
    }
  }
  
  
  
  
  //SKPhysicsContactDelegateのメソッド。衝突した時に呼ばれる
  func didBegin(_ contact: SKPhysicsContact){
    //ゲームオーバーの時は何もしない
    if scrollNode.speed <= 0 {
      return
      
    }
    
    //bodyA,Bのプロパティには衝突した２つのノードが代入される
    if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
      //スコア用の物体と衝突した
      print("scoreup")
      score += 1
      scoreLabelNode.text = "Score:\(score)"
      
      
      //ベストスコアが更新されたか確認・更新
      //userDefaultsは初めの方でscoreの下にインスタンスを作っているよ
      //intager()でベストスコアを呼び出す…衝突のたびに毎回やってるのか
      var bestScore = userDefaults.integer(forKey: "BEST")
      if score > bestScore{
        //ベストスコアを更新
        bestScore = score
        
        //ベストスコアのラベルを更新
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        
        //set()でベストスコアをキーを指定して保存
        userDefaults.set(bestScore, forKey:"BEST")
        
        //この時点では即座には保存されないので、syncronize()で保存を反映させる？
        userDefaults.synchronize()
        
        //
        print(bestScore)
        
      }
      
    }else if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
      //アイテムと衝突した
      print("itemget")
      item += 1
      itemLabelNode.text = "item:\(item)"
      
      //a,bどちらがアイテムか検査する
      var itemItem:SKPhysicsBody
      var itemNode:SKSpriteNode
      if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory {
        itemItem = contact.bodyA
      }else{
        itemItem = contact.bodyB
      }
      
      //アイテムからspritenodeを取得
      itemNode = itemItem.node as! SKSpriteNode
      
      //itemSprite.isHidden =　true
      itemNode.removeFromParent()
      
      //効果音を鳴らす
      run(seItem!)
      
      
    }else{
      //壁か地面と接触した
      print("gameover")
      
      //スクロールを停止させる
      scrollNode.speed = 0
      
      bird.physicsBody?.collisionBitMask = groundCategory
      
      let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y)*0.01, duration: 1)
      bird.run(roll, completion:{
        self.bird.speed = 0
      })
      
      run(seGameover!)
    
    }
  }
  
  
  
  
  func restart(){
    //スコアをリセット
    score = 0
    scoreLabelNode.text = String("Score:\(score)")
    
    //とりのいちをリセット
    bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
    
    //速さをリセット
    bird.physicsBody?.velocity = CGVector.zero
    
    //鳥が地面と壁に跳ね返される
    bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
    
    //鳥を正面に向かせる（回転角度を０に
    bird.zRotation = 0.0
    
    //壁を消す
    wallNode.removeAllChildren()
    
    //アイテムを消す
    itemNode.removeAllChildren()
    
    //速さをリセットしてたのでここで初期化？
    bird.speed = 1
    scrollNode.speed = 1
  }
  
  
  
  
  func setupScoreLabel(){
    //スコアのラベルを作成
    score = 0
    scoreLabelNode = SKLabelNode()
    scoreLabelNode.fontColor = UIColor.black
    scoreLabelNode.position = CGPoint(x:10, y:self.frame.size.height - 30)
    scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
    scoreLabelNode.text = "Score:\(score)"
    
    //画面に映す
    self.addChild(scoreLabelNode)
    
    
    //ベストスコアのラベルを作成
    bestScoreLabelNode = SKLabelNode()
    bestScoreLabelNode.fontColor = UIColor.black
    bestScoreLabelNode.position = CGPoint(x:10, y:self.frame.size.height - 60)
    bestScoreLabelNode.zPosition = 100
    bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
    
    //ベストスコアを取得してラベルを書き換える
    let bestScore = userDefaults.integer(forKey: "BEST")
    bestScoreLabelNode.text = "Best Score:\(bestScore)"
    
    //画面に映す
    self.addChild(bestScoreLabelNode)
    
    
    //アイテムのラベルを作成
    item = 0
    itemLabelNode = SKLabelNode()
    itemLabelNode.fontColor = UIColor.black
    itemLabelNode.position = CGPoint(x:10, y:self.frame.size.height - 90)
    itemLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
    itemLabelNode.text = "item:\(item)"
    
    //画面に映す
    self.addChild(itemLabelNode)
  }
}


