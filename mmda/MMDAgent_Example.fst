# 0011-0020 Initialization

0    11   <eps>                               MODEL_ADD|bootscreen|Accessory\bootscreen\bootscreen.pmd|0.0,12.85,17.6|0.0,0.0,0.0|OFF
11   12   MODEL_EVENT_ADD|bootscreen          MODEL_ADD|mei|Model\PMD\PMD\new.pmd|0.0,0.0,-14.0
12   13   <eps>                               MODEL_ADD|menu|Accessory\menu\menu.pmd|0.0,-4.5,0.0|0.0,0.0,0.0|ON|mei
13   14   <eps>                               MOTION_ADD|menu|rotate|Motion\menu_rotation\menu_rotation.vmd|FULL|LOOP|OFF|OFF
14   15   <eps>                               STAGE|Stage\building2\floor1.bmp,Stage\building2\background1.bmp
15   16   <eps>                               MOTION_ADD|mei|base|Motion\mei_wait\mei_wait.vmd|FULL|LOOP|ON|OFF
16   18   <eps>                               TEXTAREA_ADD|msg_textbox|20,0|1,1,0,0|0,0,0,0|0,0,0,1|0,10,10|0,0,0
18   19   <eps>                               TEXTAREA_ADD|msg_text|18,0|1,1,1,1|1,1,1,1|0,0,0,1|0,4,10|0,0,0
19   20   <eps>                               TIMER_START|bootscreen|1.5
20   2    TIMER_EVENT_STOP|bootscreen         MODEL_DELETE|bootscreen

# 0021-0030 Idle behavior

2    3     <eps>                            TIMER_START|idle1|3
#21   22   TIMER_EVENT_START|idle1           TIMER_START|idle2|10
#22   23   TIMER_EVENT_START|idle2           TIMER_START|idle3|20
#23   24   TIMER_EVENT_START|idle3           TIMER_START|idle4|25
#24   1    TIMER_EVENT_START|idle4           VALUE_SET|random|0|100
1    1     RECOG_EVENT_START                MOTION_ADD|mei|listen|Expression\mei_listen\mei_listen.vmd|PART|ONCE
#1    1    TIMER_EVENT_STOP|idle1            MOTION_ADD|mei|idle|Motion\mei_idle\mei_idle_boredom.vmd|PART|ONCE
#1    1    TIMER_EVENT_STOP|idle2            MOTION_ADD|mei|idle|Motion\mei_idle\mei_idle_touch_clothes.vmd|PART|ONCE
#1    2    TIMER_EVENT_STOP|idle3            MOTION_ADD|mei|idle|Motion\mei_idle\mei_idle_think.vmd|PART|ONCE
#1    1    TIMER_EVENT_STOP|idle3            MOTION_ADD|mei|idle|Motion\mei_idle\mei_idle_think.vmd|PART|ONCE
#1    2    TIMER_EVENT_STOP|idle4            SYNTH_START|mei|mei_voice_normal|マーカー

# 起動 難易度選択
# メイはプレイヤーに対して「難易度を選択してください」と発話し、ユーザからの応答を待つ。
3   439   TIMER_EVENT_STOP|idle1            MOTION_ADD|mei|aisatu|Motion\mei_greeting\mei_greeting.vmd|PART|ONCE
#443 25   <eps>                             <eps>
439 440   <eps>                             TEXTAREA_SET|msg_textbox|Accessory\img\sentence_txtbox.png
440 441   <eps>                             SYNTH_START|mei|mei_voice_normal|ようこそ。はじめましてでよかったでしょうか？
441 444   <eps>                             TEXTAREA_SET|msg_text|"ようこそ。はじめましてでよかったでしょうか？"
444 445   RECOG_EVENT_STOP|はい             SYNTH_START|mei|mei_voice_normal|わたしのなまえはメイです。みてのとおり、アンドロイドです。
444 445   RECOG_EVENT_STOP|そう             SYNTH_START|mei|mei_voice_normal|わたしのなまえはメイです。みてのとおり、アンドロイドです。
444 445   RECOG_EVENT_STOP|はじめまして     SYNTH_START|mei|mei_voice_normal|わたしのなまえはメイです。みてのとおり、アンドロイドです。
444 445   MMD_CAMERA_GET|はい               SYNTH_START|mei|mei_voice_normal|わたしのなまえはメイです。みてのとおり、アンドロイドです。
445 446   <eps>                             TEXTAREA_SET|msg_text|"わたしのなまえはメイです。\nみてのとおり、アンドロイドです。"
446 4     <eps>                             MOTION_ADD|mei|self_introduction|Motion\mei_self_introduction\mei_self_introduction.vmd|PART|ONCE
444 447   RECOG_EVENT_STOP|いいえ           SYNTH_START|mei|mei_voice_normal|じゃあやるべきことはわかっていますね？カードのじゅんびはできましたか？
444 447   RECOG_EVENT_STOP|違い,ます        SYNTH_START|mei|mei_voice_normal|じゃあやるべきことはわかっていますね？カードのじゅんびはできましたか？
444 447   MMD_CAMERA_GET|いいえ             SYNTH_START|mei|mei_voice_normal|じゃあやるべきことはわかっていますね？カードのじゅんびはできましたか？
447 448   <eps>                             MOTION_ADD|mei|mei_panel|Motion\mei_panel\mei_panel_on.vmd|PART|ONCE
448 8810  <eps>                             TEXTAREA_SET|msg_text|"じゃあやるべきことはわかっていますね？\nカードのじゅんびはできましたか？"
4   34    SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|あなたはここにとじこめられています。ここを出るにはわたしをたおすしかありません。
34   5    <eps>                             TEXTAREA_SET|msg_text|"あなたはここにとじこめられています。\nここを出るにはわたしをたおすしかありません。"
5   6     <eps>                             MOTION_ADD|mei|mei_panel|Motion\mei_panel\mei_panel_on.vmd|PART|ONCE
6   36    SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|用意したデッキからカードを5枚引いてください。その中に攻撃カードはありますか？
36  7     <eps>                             TEXTAREA_SET|msg_text|"デッキからカードを５枚引いてください。\nその中にこうげきカードはありますか？"
7   8     SYNTH_EVENT_STOP|mei              <eps>
8   39    RECOG_EVENT_STOP|はい             SYNTH_START|mei|mei_voice_normal|カードの準備は整いましたね。
8   39    RECOG_EVENT_STOP|ある             SYNTH_START|mei|mei_voice_normal|カードの準備は整いましたね。
8   39    RECOG_EVENT_STOP|あり,ます        SYNTH_START|mei|mei_voice_normal|カードの準備は整いましたね。
8   39    MMD_CAMERA_GET|はい               SYNTH_START|mei|mei_voice_normal|カードの準備は整いましたね。
39  9     <eps>                             TEXTAREA_SET|msg_text|"カードのじゅんびは整いましたね。"
9   908   <eps>                             MOTION_ADD|mei|mei_guide_happy|Motion\mei_guide\mei_guide_happy.vmd|PART|ONCE
8   310   RECOG_EVENT_STOP|いいえ           SYNTH_START|mei|mei_voice_normal|持っているカードを全てデッキに戻して、カードをデッキから5枚引いてください。その中に攻撃カードはありますか？
8   310   RECOG_EVENT_STOP|ない             SYNTH_START|mei|mei_voice_normal|持っているカードを全てデッキに戻して、カードをデッキから5枚引いてください。その中に攻撃カードはありますか？
8   310   RECOG_EVENT_STOP|あり,ませ,ん     SYNTH_START|mei|mei_voice_normal|持っているカードを全てデッキに戻して、カードをデッキから5枚引いてください。その中に攻撃カードはありますか？
8   310   MMD_CAMERA_GET|いいえ             SYNTH_START|mei|mei_voice_normal|持っているカードを全てデッキに戻して、カードをデッキから5枚引いてください。その中に攻撃カードはありますか？
310 10    <eps>                             TEXTAREA_SET|msg_text|"持っているカードを全てデッキに戻して、\nカードをデッキから５枚引いてください。"
10  8     SYNTH_EVENT_STOP|mei              <eps>

908  909  SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|ルールはかんたんです。ターンごとにこうたいでカードをつかってたたかいます。
909  9010 <eps>                             TEXTAREA_SET|msg_text|"ルールはかんたんです。\nターンごとにこうたいでカードをつかってたたかいます。"
9010 9011 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|わたしの体力を0にすればあなたのかち,あなたの体力を0にすれば、わたしのかちです。
9011 9012 <eps>                             TEXTAREA_SET|msg_text|"わたしの体力を0にすればあなたのかち、\nあなたの体力を0にすれば、わたしのかちです。"
9012 9013 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|あなたがかてば、ここから出ることができます。
9013 9014 <eps>                             TEXTAREA_SET|msg_text|"あなたがかてば、ここから出ることができます。"
9014 9015 <eps>                             MOTION_ADD|mei|mei_panel|Motion\mei_panel\mei_panel_on.vmd|PART|ONCE
9015 9016 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|もしわたしがかてば、あなたはカードのいちぶとなり、えいえんにここからでることはできません。
9016 9017 <eps>                             TEXTAREA_SET|msg_text|"もしわたしがかてば、あなたはカードのいちぶとなり、\nえいえんにここからでることはできません。"
9017 9018 <eps>                             MOTION_ADD|mei|self_introduction|Motion\mei_self_introduction\mei_self_introduction.vmd|PART|ONCE
9018 9019 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|かんたんですよね？
9019 9020 <eps>                             TEXTAREA_SET|msg_text|"かんたんですよね？"
9020 9021 <eps>                             MOTION_ADD|mei|mei_guide_happy|Motion\mei_guide\mei_guide_happy.vmd|PART|ONCE
9021 9022 SYNTH_EVENT_STOP|mei              TIMER_START|wait|0.8
9022 9023 TIMER_EVENT_STOP|wait             SYNTH_START|mei|mei_voice_normal|ただのこうげきカードだけではつまらないので”とくしゅカード”もよういしました。
9023 9024 <eps>                             TEXTAREA_SET|msg_text|"ただのこうげきカードだけではつまらないので\n”とくしゅカード”もよういしました。"
9024 9025 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|ふつうのこうかは発動できますが、ミッションをクリアするとこうかをアップして発動できます。がんばってください。
9025 9026 <eps>                             TEXTAREA_SET|msg_text|"ふつうのこうかははつどうできますが、\nミッションをクリアするとこうかをアップしてはつどうできます。"
9026 9027 SYNTH_EVENT_STOP|mei              TIMER_START|wait|0.8
9027 9028 TIMER_EVENT_STOP|wait             SYNTH_START|mei|mei_voice_normal|ここからがちゅういです。ターン中に一回しかこうげきカードがつかえません。
9028 9029 <eps>                             TEXTAREA_SET|msg_text|"ここからがちゅういです。\nターン中に１回しかこうげきカードがつかえません。"
9029 9030 <eps>                             MOTION_ADD|mei|mei_imagine_left_normal|Motion\mei_imagine\mei_imagine_left_normal.vmd|PART|ONCE
9030 9031 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|こうげきがおわったらあなたのターンはおわりなので気をつけてください。こうげきカードいがいのカードはなんかいでもつかえます。
9031 9032 <eps>                             TEXTAREA_SET|msg_text|"こうげきがおわったらあなたのターンはおわりなので気をつけてください。\nこうげきカードいがいのカードは何回でもつかえます。"
9032 9100 SYNTH_EVENT_STOP|mei              TIMER_START|wait|0.8

9100 9102 TIMER_EVENT_STOP|wait             SYNTH_START|mei|mei_voice_normal|なにかわからないことはありますか？このリストの中のことばをいえば、そのせつめいをします。
9101 9102 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|ほかにわからないことはありますか？
9102 9103 <eps>                             TEXTAREA_SET|msg_text|"ルール　とくしゅカード　おだい　ターン"
9103 9101 RECOG_EVENT_STOP|ルール           SYNTH_START|mei|mei_voice_normal|ルールはかんたんです。ターンごとにこうたいでカードをつかってわたしの体力を0にすればあなたのかち,あなたの体力を0にすれば、わたしのかちです。
9103 9101 MMD_CAMERA_GET|ルール             SYNTH_START|mei|mei_voice_normal|ルールはかんたんです。ターンごとにこうたいでカードをつかってわたしの体力を0にすればあなたのかち,あなたの体力を0にすれば、わたしのかちです。
9103 9101 RECOG_EVENT_STOP|とくしゅカード   SYNTH_START|mei|mei_voice_normal|ただのこうげきカードだけではつまらないので”とくしゅカード”もよういしました。
9103 9101 MMD_CAMERA_GET|とくしゅカード     SYNTH_START|mei|mei_voice_normal|ただのこうげきカードだけではつまらないので”とくしゅカード”もよういしました。
9103 9101 RECOG_EVENT_STOP|お題             SYNTH_START|mei|mei_voice_normal|ふつうのこうかははつどうできますが、ミッションをクリアするとこうかをアップしてはつどうできます。がんばってください。
9103 9101 MMD_CAMERA_GET|お題               SYNTH_START|mei|mei_voice_normal|ふつうのこうかははつどうできますが、ミッションをクリアするとこうかをアップしてはつどうできます。がんばってください。
9103 9101 RECOG_EVENT_STOP|ターン           SYNTH_START|mei|mei_voice_normal|ターン中に1かいしかこうげきカードがつかえません。こうげきがおわったらあなたのターンはおわりなのできをつけてください。こうげきカードいがいのカードはなんかいでもつかえます。
9103 9101 MMD_CAMERA_GET|ターン             SYNTH_START|mei|mei_voice_normal|ターン中に1かいしかこうげきカードがつかえません。こうげきがおわったらあなたのターンはおわりなのできをつけてください。こうげきカードいがいのカードはなんかいでもつかえます。

9103 9104 RECOG_EVENT_STOP|ない             SYNTH_START|mei|mei_voice_normal|せつめいはこれでおわりです。
9103 9104 RECOG_EVENT_STOP|いいえ           SYNTH_START|mei|mei_voice_normal|せつめいはこれでおわりです。
9103 9104 RECOG_EVENT_STOP|大丈夫           SYNTH_START|mei|mei_voice_normal|せつめいはこれでおわりです。
9103 9104 RECOG_EVENT_STOP|あり,ませ,ん     SYNTH_START|mei|mei_voice_normal|せつめいはこれでおわりです。
9103 9104 MMD_CAMERA_GET|いいえ             SYNTH_START|mei|mei_voice_normal|せつめいはこれでおわりです。
9104 8810 <eps>                             TEXTAREA_SET|msg_text|"せつめいはこれでおわりです。"
#9105 8810 SYNTH_EVENT_STOP|mei              <eps>

8810 8811 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|ではバトルをはじめましょう。ここをでるためにわたしをたおしてください！
8811 8812 <eps>                             TEXTAREA_SET|msg_text|"ではバトルをはじめましょう。\nここをでるためにわたしをたおしてください！"
8812 8813 <eps>                             MOTION_ADD|mei|toridasi|Motion\mei_adv\kado_toridasi.vmd|PART|ONCE
8813 8814 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|難易度を選択して。簡単、普通、難しいの中から選んでください。
8814 21   <eps>                             TEXTAREA_SET|msg_text|"　　かんたん　ふつう　むずかしい"

#20   21   SYNTH_EVENT_STOP|mei              <eps>
21   22   MMD_CAMERA_GET|簡単               <eps>
21   22   RECOG_EVENT_STOP|簡単             <eps>
21   23   RECOG_EVENT_STOP|普通             <eps>
21   24   RECOG_EVENT_STOP|難しい           <eps>
22   25   <eps>                             SYNTH_START|mei|mei_voice_normal|簡単を選択しました。
23   25   <eps>                             SYNTH_START|mei|mei_voice_normal|普通を選択しました。
24   25   <eps>                             SYNTH_START|mei|mei_voice_normal|難しいを選択しました。
25   26   SYNTH_EVENT_STOP|mei              TEXTAREA_SET|msg_textbox|Accessory\img\clean.png
26  100   <eps>                             TEXTAREA_SET|msg_text|Accessory\img\clean.png
27  100   SYNTH_EVENT_STOP|mei              <eps>


# バトル
100  999  <eps>                             SYNTH_START|mei|mei_voice_normal|それではバトル開始。
999  1001 SYNTH_EVENT_STOP|mei              <eps>
1001 1002 <eps>                             SYNTH_START|mei|mei_voice_normal|あなたのターンです。カードを1まいひいてください
1002 1001 MMD_CAMERA_GET|ERROR              <eps>
1002 1102 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|カメラを起動します。使用するカードをかざしてください。
1102 1300 MMD_CAMERA_GET|marker             SYNTH_START|mei|mei_voice_normal|カードを読み込みました。
1102 1331 MMD_CAMERA_GET|used               SYNTH_START|mei|mei_voice_normal|使用済みのカードです。別のカードをかざしてください。
1331 1102 SYNTH_EVENT_STOP|mei              <eps>
# ここでお題の表示する （攻撃カードならなし？）
1300 1301 SYNTH_EVENT_STOP|mei              <eps>
1301 1007 MMD_CAMERA_GET|atk                <eps>
1301 1400 MMD_CAMERA_GET|def                <eps>
1301 1400 MMD_CAMERA_GET|heal               <eps>
1301 1400 MMD_CAMERA_GET|buff               <eps>
1400 1401 <eps>                             SYNTH_START|mei|mei_voice_normal|とくしゅカードをよみこみました。それではお題を抽選します。
1401 1400 MMD_CAMERA_GET|ERROR              <eps>
1401 1003 MMD_CAMERA_GET|push_ups           SYNTH_START|mei|mei_voice_normal|腕立て伏せ。が選択されました。
1401 1003 MMD_CAMERA_GET|squats             SYNTH_START|mei|mei_voice_normal|スクワット。が選択されました。
1401 1003 MMD_CAMERA_GET|crunches           SYNTH_START|mei|mei_voice_normal|腹筋。が選択されました。
1401 1003 MMD_CAMERA_GET|red                SYNTH_START|mei|mei_voice_normal|赤色を探せ。が選択されました。
1401 1003 MMD_CAMERA_GET|blue               SYNTH_START|mei|mei_voice_normal|青色を探せ。が選択されました。
1401 1003 MMD_CAMERA_GET|green              SYNTH_START|mei|mei_voice_normal|緑色を探せ。が選択されました。   

1003 1004 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|お題に挑戦しますか？
1004 1100 RECOG_EVENT_STOP|はい             SYNTH_START|mei|mei_voice_normal|お題に挑戦します。それではがんばってください、むずかしいときは、「ギブアップ」ということでしっぱいあつかいでしゅうりょうできます
1004 1507 RECOG_EVENT_STOP|いいえ           SYNTH_START|mei|mei_voice_normal|お題に挑戦しません。こんかいは,ついかこうかなしでとくしゅこうかをはつどうします。
1507 1007 SYNTH_EVENT_STOP|mei              <eps>
1007 1008 <eps>                             SYNTH_START|mei|mei_voice_normal|カードを発動します。
1008 200  MMD_CAMERA_GET|atk                <eps>
1008 300  MMD_CAMERA_GET|def                <eps>
1008 400  MMD_CAMERA_GET|heal               <eps>
1008 500  MMD_CAMERA_GET|buff               <eps>
1011 7000 <eps>                             <eps>

1004 1100 MMD_CAMERA_GET|はい               SYNTH_START|mei|mei_voice_normal|お題に挑戦します。それではがんばってください、むずかしいときは、「ギブアップ」ということでしっぱいあつかいでしゅうりょうできます
1004 1507 MMD_CAMERA_GET|いいえ             SYNTH_START|mei|mei_voice_normal|お題に挑戦しません。こんかいは,ついかこうかなしでとくしゅこうかをはつどうします。


# ダメ計
7000 7001 <eps>                             SYNTH_START|mei|mei_voice_normal|ダメージ計算
7001 7002 SYNTH_EVENT_STOP|mei              <eps>
# mei<player
7002 4000 MMD_CAMERA_GET|勝ち               <eps>
# mei>player
7002 3000 MMD_CAMERA_GET|負け               <eps>

7002 1001 MMD_CAMERA_GET|続行               SYNTH_START|mei|mei_voice_normal|次のターンです。

# mei Win
3000 3001 <eps>                             SYNTH_START|mei|mei_voice_normal|わたしのかちです。まだまだですね。
3001 3002 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|まだあなたはここからでることはできません。
3002 3003 SYNTH_EVENT_STOP|mei              <eps>
3003 7700 <eps>                             MOTION_ADD|mei|action|Motion\mei_adv\lose.vmd|PART|ONCE

# mei Lose
4000 4001 <eps>                             SYNTH_START|mei|mei_voice_normal|わたしをたおすなんてなかなかやりますね…
4001 4002 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|たのしいバトルでした。またバトルできることをたのしみにしています。
4002 4003 SYNTH_EVENT_STOP|mei              <eps>
4003 7700 <eps>                             MOTION_ADD|mei|action|Motion\mei_adv\win.vmd|PART|ONCE

# 終わり（仮）
7700 2 <eps>                                SYNTH_START|mei|mei_voice_normal|ゲーム終了


# プレイヤー攻撃
200 201 <eps>                               SYNTH_START|mei|mei_voice_normal|攻撃カードですね。
201 202 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|あなたの力をわたしに見せてください。
202 204 SYNTH_EVENT_STOP|mei                <eps>
204 205 <eps>                               SYNTH_START|mei|mei_voice_normal|なかなかやりますね。
205 206 SYNTH_EVENT_STOP|mei                <eps>
206 600 <eps>                               <eps>

# mei攻撃
600 601 <eps>                               SYNTH_START|mei|mei_voice_normal|さて、わたしのターンですね！くらえ！
601 602 SYNTH_EVENT_STOP|mei                <eps>
602 603 <eps>                               MOTION_ADD|mei|action|Motion\mei_adv\syoukan.vmd|PART|ONCE
603 7000 <eps>                              <eps>

# プレイヤー防御
300 301 <eps>                               SYNTH_START|mei|mei_voice_normal|防御します。
301 302 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|攻撃以外なのでもう一度あなたのターンです。
302 1001 SYNTH_EVENT_STOP|mei               <eps>

# プレイヤー回復
400 401 <eps>                               SYNTH_START|mei|mei_voice_normal|回復します。
401 402 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|攻撃以外なのでもう一度あなたのターンです。
402 1001 SYNTH_EVENT_STOP|mei               <eps>

# プレイヤーバフ
500 501 <eps>                               SYNTH_START|mei|mei_voice_normal|バフをかけます。
501 502 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|攻撃以外なのでもう一度あなたのターンです。
502 1001 SYNTH_EVENT_STOP|mei               <eps>

# お題待機
1100 1101 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|お題を表示します。
1101 1110 SYNTH_EVENT_STOP|mei              <eps>
#1102 1110 MMD_CAMERA_GET|push_ups          SYNTH_START|mei|mei_voice_normal|腕立て伏せ
#1102 1110 MMD_CAMERA_GET|squats            SYNTH_START|mei|mei_voice_normal|スクワット
#1102 1110 MMD_CAMERA_GET|crunches          SYNTH_START|mei|mei_voice_normal|腹筋
#1102 1110 MMD_CAMERA_GET|red               SYNTH_START|mei|mei_voice_normal|赤色
#1102 1110 MMD_CAMERA_GET|blue              SYNTH_START|mei|mei_voice_normal|青色
#1102 1110 MMD_CAMERA_GET|green             SYNTH_START|mei|mei_voice_normal|緑色

1110 1111 MMD_CAMERA_GET|成功               SYNTH_START|mei|mei_voice_normal|お題成功
1110 1111 MMD_CAMERA_GET|失敗               SYNTH_START|mei|mei_voice_normal|お題失敗
1110 1112 RECOG_EVENT_STOP|ギブアップ       SYNTH_START|mei|mei_voice_normal|ギブアップしますか？
1110 1112 RECOG_EVENT_STOP|諦める           SYNTH_START|mei|mei_voice_normal|ギブアップしますか？
1112 1113 RECOG_EVENT_STOP|はい             SYNTH_START|mei|mei_voice_normal|ギブアップします。
1112 1110 RECOG_EVENT_STOP|いいえ           SYNTH_START|mei|mei_voice_normal|ギブアップしません。
1113 1111 SYNTH_EVENT_STOP|mei              <eps>
1111 1007 <eps>                             <eps>

## 0031-0040 Hello
#
#1    31   RECOG_EVENT_STOP|マーカー        SYNTH_START|mei|mei_voice_normal|マーカーをかざしてください。
#1    31   RECOG_EVENT_STOP|まーか          SYNTH_START|mei|mei_voice_normal|マーカーをかざしてください。
#1    31   RECOG_EVENT_STOP|マーカ          SYNTH_START|mei|mei_voice_normal|マーカーをかざしてください。
#31   32   <eps>                            MOTION_ADD|mei|action|Motion\mei_greeting\mei_greeting.vmd|PART|ONCE
#32   2    SYNTH_EVENT_STOP|mei             <eps>
#
## 0041-0050 Self introduction
#
#1    41   RECOG_EVENT_STOP|自己紹介           SYNTH_START|mei|mei_voice_normal|メイと言います。
#1    41   RECOG_EVENT_STOP|あなた,誰          SYNTH_START|mei|mei_voice_normal|メイと言います。
#1    41   RECOG_EVENT_STOP|君,誰              SYNTH_START|mei|mei_voice_normal|メイと言います。
#41   42   <eps>                               MOTION_ADD|mei|action|Motion\mei_self_introduction\mei_self_introduction.vmd|PART|ONCE
#42   43   SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|よろしくお願いします。
#43   2    SYNTH_EVENT_STOP|mei                <eps>
#
## 0051-0060 Thank you
#
#1    51   RECOG_EVENT_STOP|ありがと           SYNTH_START|mei|mei_voice_normal|どういたしまして。
#1    51   RECOG_EVENT_STOP|ありがとう         SYNTH_START|mei|mei_voice_normal|どういたしまして。
#1    51   RECOG_EVENT_STOP|有難う             SYNTH_START|mei|mei_voice_normal|どういたしまして。
#1    51   RECOG_EVENT_STOP|有り難う           SYNTH_START|mei|mei_voice_normal|どういたしまして。
#51   52   <eps>                               MOTION_ADD|mei|expression|Expression\mei_happiness\mei_happiness.vmd|PART|ONCE
#52   53   SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_happy|いつでも、話しかけてくださいね。
#53   54   <eps>                               MOTION_CHANGE|mei|base|Motion\mei_guide\mei_guide_happy.vmd
#54   2    SYNTH_EVENT_STOP|mei                MOTION_CHANGE|mei|base|Motion\mei_wait\mei_wait.vmd
#
## 0061-0070 Positive comments

#1    61   RECOG_EVENT_STOP|可愛い             VALUE_EVAL|random|LE|80
#1    61   RECOG_EVENT_STOP|かわいい           VALUE_EVAL|random|LE|80
#1    61   RECOG_EVENT_STOP|綺麗               VALUE_EVAL|random|LE|80
#1    61   RECOG_EVENT_STOP|きれい             VALUE_EVAL|random|LE|80
#61   62   VALUE_EVENT_EVAL|random|LE|80|TRUE  SYNTH_START|mei|mei_voice_bashful|恥ずかしいです。
#61   62   VALUE_EVENT_EVAL|random|LE|80|FALSE SYNTH_START|mei|mei_voice_bashful|ありがとう。
#62   63   <eps>                               MOTION_ADD|mei|expression|Expression\mei_bashfulness\mei_bashfulness.vmd|PART|ONCE
#63   2    SYNTH_EVENT_STOP|mei                <eps>



1    140  MMD_CAMERA_GET|user_attack          MOTION_ADD|mei|idle|Motion\mei_idle\damage.vmd|PART|ONCE
140  141  <eps>                               SYNTH_START|mei|mei_voice_normal|攻撃を受けました。 
141  2    SYNTH_EVENT_STOP|mei                <eps>

1    142  MMD_CAMERA_GET|user_lose            SYNTH_START|mei|mei_voice_normal|わたしの勝ちです。
142  2    SYNTH_EVENT_STOP|mei                <eps>

1    144  MMD_CAMERA_GET|user_win             SYNTH_START|mei|mei_voice_normalあなたの勝ちです。
144  2    SYNTH_EVENT_STOP|mei                <eps>
