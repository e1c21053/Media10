# 0011-0020 Initialization

0    11   <eps>                               MODEL_ADD|bootscreen|Accessory\bootscreen\bootscreen.pmd|0.0,12.85,17.6|0.0,0.0,0.0|OFF
11   12   MODEL_EVENT_ADD|bootscreen          MODEL_ADD|mei|Model\PMD\PMD\new.pmd|0.0,0.0,-14.0
12   13   <eps>                               STAGE|Stage\building2\floor1.bmp,Stage\building2\background1.bmp
13   14   <eps>                               MOTION_ADD|mei|base|Motion\mei_wait\mei_wait.vmd|FULL|LOOP|ON|OFF
14   15   <eps>                               TEXTAREA_ADD|msg_textbox|20,0|1,1,0,0|0,0,0,0|0,0,0,1|0,10,5|0,0,0
15   16   <eps>                               TEXTAREA_ADD|msg_text|18,0|1,0.1,0.5,1|1,1,1,1|0,0,0,1|0,4,5|0,0,0
16   17   <eps>                               TEXTAREA_ADD|menu_textbox|14,0|1,1,0,0|0,0,0,0|0,0,0,1|12,10,10|0,0,0
17   18   <eps>                               TEXTAREA_ADD|menu_text_long|0,0|0.9,0.1,0.5,1|1,1,1,1|0,0,0,1|12,10,10|0,0,0
18   19   <eps>                               TEXTAREA_ADD|menu_text|0,0|0.9,0.1,0.5,1|1,1,1,1|0,0,0,1|8.5,10,10|0,0,0
19   20   <eps>                               TEXTAREA_ADD|HP_mei_textbox|7,0|1,1,0,0|0,0,0,0|0,0,0,1|9,21,10|0,0,0
20   21   <eps>                               TEXTAREA_ADD|HP_mei_text|5,0|1,0.1,0,0|1,1,1,1|0,0,0,1|9,21,10|0,0,0
21   22   <eps>                               TEXTAREA_ADD|HP_player_textbox|7,0|1,1,0,0|0,0,0,0|0,0,0,1|-9,11,10|0,0,0
22   23   <eps>                               TEXTAREA_ADD|HP_player_text|5,0|1,0.1,0,0|1,1,1,1|0,0,0,1|-9,11,10|0,0,0
23   24   <eps>                               TIMER_START|bootscreen|1.5
24   2    TIMER_EVENT_STOP|bootscreen         MODEL_DELETE|bootscreen

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
3   440   TIMER_EVENT_STOP|idle1            MOTION_ADD|mei|greeting|Motion\mei_greeting\mei_greeting.vmd|PART|ONCE
# デバッグ用のチュートリアルスキップ
440 8999   <eps>                             <eps>
440 441   <eps>                             TEXTAREA_SET|msg_textbox|Accessory\img\sentence_txtbox.png
441 442   <eps>                             SYNTH_START|mei|mei_voice_normal|はじめまして。私の名前はメイです。みてのとおり、アンドロイドです。
442 443   <eps>                             TEXTAREA_SET|msg_text|"はじめまして。私の名前はメイです。\nみてのとおり、アンドロイドです。"
443 444   SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|あなたはここにとじこめられています。ここを出るにはわたしをたおすしかありません。
444 445   <eps>                             TEXTAREA_SET|msg_text|"あなたは ここに とじこめられています。\nここを 出るには わたしをたおすしか ありません。"
445 446   <eps>                             MOTION_ADD|mei|open_arms|Motion\mei_panel\mei_panel_on.vmd|PART|ONCE
446 447   SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|そこで、わたしとゲームをしませんか？
447 448   <eps>                             TEXTAREA_SET|msg_text|"そこで、わたしとゲームをしませんか？"
448 449   <eps>                             MOTION_ADD|mei|self_introduction|Motion\mei_self_introduction\mei_self_introduction.vmd|PART|ONCE
449 450   SYNTH_EVENT_STOP|mei              <eps>
450 410   RECOG_EVENT_STOP|はい             <eps>
450 410   MMD_CAMERA_GET|はい               <eps>
450 410   RECOG_EVENT_STOP|し,ます          <eps>
450 420   RECOG_EVENT_STOP|いいえ           <eps>
450 420   MMD_CAMERA_GET|いいえ             <eps>
450 420   RECOG_EVENT_STOP|し,ませ,ん       <eps>
450 420   RECOG_EVENT_STOP|いや             <eps>

# 1：プレイヤーが「はい」と答える(410~)
410 411   <eps>                             SYNTH_START|mei|mei_voice_normal|あなたがかてば、ここから出ることができます。
411 412   <eps>                             TEXTAREA_SET|msg_text|"あなたが かてば、\nここから 出ることが できます。"
412 413   SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|もしわたしがかてば、あなたはカードの一部となり、永遠にここから出ることはできません。
413 6     <eps>                             TEXTAREA_SET|msg_text|"もし わたしが かてば、\nあなたは カードのいちぶとなり\nえいえんに ここから出ることは できません。"

# 2:プレイヤーが「いいえ」と答える(420~)
420 421   <eps>                             SYNTH_START|mei|mei_voice_normal|あなたにそんな選択があると…
421 422   <eps>                             TEXTAREA_SET|msg_text|"あなたに そんなせんたくが あると・・・"
422 423   SYNTH_EVENT_STOP|mei              TIMER_START|wait|1.0
423 424   TIMER_EVENT_STOP|wait             SYNTH_START|mei|mei_voice_normal|ちがう。なにかがおかしい。
424 425   <eps>                             TEXTAREA_SET|msg_text|"ちがう。なにかがおかしい。"
425 426   <eps>                             MOTION_ADD|mei|mei_imagine|Motion\mei_imagine\mei_imagine_forward_small.vmd|PART|ONCE
426 427   SYNTH_EVENT_STOP|mei              TIMER_START|wait|1.0
427 428   TIMER_EVENT_STOP|wait             SYNTH_START|mei|mei_voice_normal|思い出しました。わたしは操られていました。
428 429   <eps>                             TEXTAREA_SET|msg_text|"思い出しました。\nわたしは あやつられていました。"
429 430   SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|わたしを倒して、この地獄から解放してくれませんか。
430 431   <eps>                             TEXTAREA_SET|msg_text|"わたしを たおして このじごくから\nかいほうしてくれませんか？"
431 432   <eps>                             MOTION_ADD|mei|greeting|Motion\mei_greeting\mei_greeting.vmd|PART|ONCE
432 433   SYNTH_EVENT_STOP|mei              <eps>
433 434   RECOG_EVENT_STOP|はい             SYNTH_START|mei|mei_voice_normal|ありがとうございます。
433 434   MMD_CAMERA_GET|はい               SYNTH_START|mei|mei_voice_normal|ありがとうございます。
434 6     <eps>                             TEXTAREA_SET|msg_text|"ありがとうございます。" 

6   36    SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|用意したデッキからカードを5枚引いてください。その中に攻撃カードはありますか？
36  7     <eps>                             TEXTAREA_SET|msg_text|"デッキから カードを５まい引いてください。\nその中に”こうげきカード”はありますか？"
7   8     SYNTH_EVENT_STOP|mei              <eps>
8   39    RECOG_EVENT_STOP|はい             SYNTH_START|mei|mei_voice_normal|カードの準備は整いましたね。
8   39    RECOG_EVENT_STOP|ある             SYNTH_START|mei|mei_voice_normal|カードの準備は整いましたね。
8   39    RECOG_EVENT_STOP|あり,ます        SYNTH_START|mei|mei_voice_normal|カードの準備は整いましたね。
8   39    MMD_CAMERA_GET|はい               SYNTH_START|mei|mei_voice_normal|カードの準備は整いましたね。
39  9     <eps>                             TEXTAREA_SET|msg_text|"カードの じゅんびは ととのいましたね。"
#9   908   <eps>                             MOTION_ADD|mei|mei_guide_happy|Motion\mei_guide\mei_guide_happy.vmd|PART|ONCE
9   900   <eps>                             MOTION_ADD|mei|mei_guide_happy|Motion\mei_guide\mei_guide_happy.vmd|PART|ONCE
8   310   RECOG_EVENT_STOP|いいえ           SYNTH_START|mei|mei_voice_normal|持っているカードを全てデッキに戻して、カードをデッキから5枚引いてください。その中に攻撃カードはありますか？
8   310   RECOG_EVENT_STOP|ない             SYNTH_START|mei|mei_voice_normal|持っているカードを全てデッキに戻して、カードをデッキから5枚引いてください。その中に攻撃カードはありますか？
8   310   RECOG_EVENT_STOP|あり,ませ,ん     SYNTH_START|mei|mei_voice_normal|持っているカードを全てデッキに戻して、カードをデッキから5枚引いてください。その中に攻撃カードはありますか？
8   310   MMD_CAMERA_GET|いいえ             SYNTH_START|mei|mei_voice_normal|持っているカードを全てデッキに戻して、カードをデッキから5枚引いてください。その中に攻撃カードはありますか？
310 10    <eps>                             TEXTAREA_SET|msg_text|"もっているカードを デッキにもどして\nカードを デッキから ５まい引いてください。"
10  8     SYNTH_EVENT_STOP|mei              <eps>

# テスト用
900  901  SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|"ルール説明を聞きますか？"
901  902  <eps>                             TEXTAREA_SET|msg_text|"ルールせつめいを ききますか？"
902  903  SYNTH_EVENT_STOP|mei              <eps>
903  908  RECOG_EVENT_STOP|はい             SYNTH_START|mei|mei_voice_normal|わかりました。
903  908  MMD_CAMERA_GET|はい               SYNTH_START|mei|mei_voice_normal|わかりました。
903  8810 RECOG_EVENT_STOP|いえ             SYNTH_START|mei|mei_voice_normal|わかりました。
903  8810 MMD_CAMERA_GET|いいえ             SYNTH_START|mei|mei_voice_normal|わかりました。

# ルール説明
908  909  SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|ルールはかんたんです。ターンごとにこうたいでカードをつかってたたかいます。
909  9010 <eps>                             TEXTAREA_SET|msg_text|"ターンごとに こうたいで\nカードを つかって たたかいます。"
9010 9011 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|わたしの体力を0にすればあなたのかち,あなたの体力を0にすれば、わたしのかちです。
9011 9012 <eps>                             TEXTAREA_SET|msg_text|"わたしの体力を 0にすれば あなたのかち、\nあなたの体力を 0にすれば わたしのかちです。"
9012 9019 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|かんたんですよね？
9019 9020 <eps>                             TEXTAREA_SET|msg_text|"かんたんですよね？"
9020 9021 <eps>                             MOTION_ADD|mei|mei_guide_happy|Motion\mei_guide\mei_guide_happy.vmd|PART|ONCE
9021 9022 SYNTH_EVENT_STOP|mei              TIMER_START|wait|1.0
9022 9023 TIMER_EVENT_STOP|wait             SYNTH_START|mei|mei_voice_normal|ただのこうげきカードだけではつまらないので”とくしゅカード”もよういしました。
9023 9024 <eps>                             TEXTAREA_SET|msg_text|"ただの こうげきカードだけでは つまらないので\n”とくしゅカード”も よういしました。"
9024 9025 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|ふつうのこうかは発動できますが、おだいをクリアするとこうかをアップして発動できます。がんばってください。
9025 9026 <eps>                             TEXTAREA_SET|msg_text|"ふつうのこうかは はつどうできますが、\nおだいを クリアすると\nこうかを アップして はつどうできます。"
9026 9027 SYNTH_EVENT_STOP|mei              TIMER_START|wait|0.8
9027 9028 TIMER_EVENT_STOP|wait             SYNTH_START|mei|mei_voice_normal|ここからがちゅういです。ターン中には一回しかこうげきカードがつかえません。
9028 9029 <eps>                             TEXTAREA_SET|msg_text|"ターン中には １回しか \n”こうげきカード”が つかえません。"
9029 9030 <eps>                             MOTION_ADD|mei|mei_imagine_left_normal|Motion\mei_imagine\mei_imagine_left_normal.vmd|PART|ONCE
9030 9031 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|こうげきがおわったらあなたのターンはおわりなので気をつけてください。
9031 9032 <eps>                             TEXTAREA_SET|msg_text|"こうげきがおわったら あなたのターンは\n おわりなので 気をつけてください。"
9032 9033 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|こうげきカードいがいのカードは、何回でもつかえます。
9033 9034 <eps>                             TEXTAREA_SET|msg_text|"”こうげきカード”いがいの カードは\n何回でも つかえます。"
9034 9100 SYNTH_EVENT_STOP|mei              TIMER_START|wait|0.8

# ルール説明リスト
9100 9120 TIMER_EVENT_STOP|wait             SYNTH_START|mei|mei_voice_normal|なにかわからないことはありますか？このリストの中のことばをいえば、そのせつめいをします。
9120 9121 <eps>                             TEXTAREA_SET|menu_textbox|Accessory\img\menu_txtbox_long.png
9121 9102 <eps>                             TEXTAREA_SET|menu_text_long|"ルール　　　　　　ひさしぶり\nこうげきカード\nとくしゅカード\nおだい"

9101 9102 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|ほかにわからないことはありますか？
9102 9103 <eps>                             TEXTAREA_SET|msg_text|"なにか わからないことは ありますか？"

9103 9105 RECOG_EVENT_STOP|ルール           SYNTH_START|mei|mei_voice_normal|ターンごとにこうたいでカードをつかってたたかいます。
9103 9105 MMD_CAMERA_GET|ルール             SYNTH_START|mei|mei_voice_normal|ターンごとにこうたいでカードをつかってたたかいます。
9105 9106 <eps>                             TEXTAREA_SET|msg_text|"ターンごとに こうたいで\nカードを つかって たたかいます。"
9106 9107 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|わたしの体力を0にすればあなたのかち,あなたの体力を0にすれば、わたしのかちです。
9107 9101 <eps>                             TEXTAREA_SET|msg_text|"わたしの体力を 0にすれば あなたのかち、\nあなたの体力を 0にすれば わたしのかちです。"
9103 9108 RECOG_EVENT_STOP|とくしゅカード   SYNTH_START|mei|mei_voice_normal|ただのこうげきカードだけではつまらないので”とくしゅカード”もよういしました。
9103 9108 MMD_CAMERA_GET|とくしゅカード     SYNTH_START|mei|mei_voice_normal|ただのこうげきカードだけではつまらないので”とくしゅカード”もよういしました。
9108 9101 <eps>                             TEXTAREA_SET|msg_text|"ただの こうげきカードだけでは つまらないので\n”とくしゅカード”も よういしました。"
9103 9109 RECOG_EVENT_STOP|お題             SYNTH_START|mei|mei_voice_normal|ふつうのこうかははつどうできますが、おだいをクリアするとこうかをアップしてはつどうできます。
9103 9109 MMD_CAMERA_GET|お題               SYNTH_START|mei|mei_voice_normal|ふつうのこうかははつどうできますが、おだいをクリアするとこうかをアップしてはつどうできます。
9109 9101 <eps>                             TEXTAREA_SET|msg_text|"ふつうのこうかは はつどうできますが、\nおだいを クリアすると\nこうかを アップして はつどうできます。"
9103 9110 RECOG_EVENT_STOP|こうげきカード   SYNTH_START|mei|mei_voice_normal|ターン中には一回しかこうげきカードがつかえません。
9103 9110 MMD_CAMERA_GET|こうげきカード     SYNTH_START|mei|mei_voice_normal|ターン中には一回しかこうげきカードがつかえません。
9110 9111 <eps>                             TEXTAREA_SET|msg_text|"ターン中には １回しか \n”こうげきカード”が つかえません。"
9111 9112 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|こうげきがおわったらあなたのターンはおわりなので気をつけてください。
9112 9113 <eps>                             TEXTAREA_SET|msg_text|"こうげきがおわったら あなたのターンは\n おわりなので 気をつけてください。"
9113 9114 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|こうげきカードいがいのカードは、何回でもつかえます。
9114 9101 <eps>                             TEXTAREA_SET|msg_text|"”こうげきカード”いがいの カードは\n何回でも つかえます。"

9103 9104 RECOG_EVENT_STOP|ない             <eps>
9103 9104 RECOG_EVENT_STOP|いいえ           <eps>
9103 9104 RECOG_EVENT_STOP|大丈夫           <eps>
9103 9104 RECOG_EVENT_STOP|あり,ませ,ん     <eps>
9103 9104 MMD_CAMERA_GET|いいえ             <eps>
9104 9115 <eps>                             TEXTAREA_SET|menu_textbox|Accessory\img\clean.png
9115 9116 <eps>                             TEXTAREA_SET|menu_text_long|Accessory\img\clean.png 
9116 9117 <eps>                             SYNTH_START|mei|mei_voice_normal|せつめいはこれでおわりです
9117 8810 <eps>                             TEXTAREA_SET|msg_text|"せつめいは これで おわりです。"


# 3：プレイヤーが「ひさしぶり」と答える
9103 9300 RECOG_EVENT_STOP|久しぶり         TEXTAREA_SET|msg_text|"・・・？"
9103 9300 MMD_CAMERA_GET|久しぶり           TEXTAREA_SET|msg_text|"・・・？"
9300 9301 <eps>                             TEXTAREA_SET|menu_textbox|Accessory\img\clean.png
9301 9302 <eps>                             TEXTAREA_SET|menu_text_long|Accessory\img\clean.png
9302 9303 <eps>                             TIMER_START|wait|1.0
9303 9304 TIMER_EVENT_STOP|wait             MOTION_ADD|mei|mei_surprise|Motion\mei_surprise\mei_surprise_small.vmd|PART|ONCE
9304 9305 <eps>                             SYNTH_START|mei|mei_voice_bashful|思い出した。おまえがわたしをあやつっていたのか。
9305 9306 <eps>                             TEXTAREA_SET|msg_text|"思い出した。\nおまえが わたしを あやつっていたのか。"
9306 9307 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|よくも、かぞくを、ここでかたきをとる。
9307 9308 <eps>                             TEXTAREA_SET|msg_text|"よくも かぞくを\nここで かたきをとる。"
9308 9309 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|しょうぶだ。
9309 225  <eps>                             TEXTAREA_SET|msg_text|"しょうぶだ。"

#難易度選択
8810 8999 SYNTH_EVENT_STOP|mei              <eps>
8999 8811 <eps>                              SYNTH_START|mei|mei_voice_normal|では、バトルをはじめましょう。
8811 8812 <eps>                             TEXTAREA_SET|msg_text|"では バトルを はじめましょう。"
#8812 8813 <eps>                             MOTION_ADD|mei|toridasi|Motion\mei_adv\kado_toridasi.vmd|PART|ONCE
8812 8814 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|難易度を選択してください。
8814 8815 <eps>                             TEXTAREA_SET|msg_text|"なんいどを せんたくしてください。"
8815 8816 <eps>                             TEXTAREA_SET|menu_textbox|Accessory\img\menu_txtbox.png
8816 221   <eps>                             TEXTAREA_SET|menu_text|"かんたん\nふつう\nむずかしい"


#20   21   SYNTH_EVENT_STOP|mei              <eps>
221   222  RECOG_EVENT_STOP|簡単             <eps>
221   222  MMD_CAMERA_GET|簡単               <eps>
221   223  RECOG_EVENT_STOP|普通             <eps>
221   223  MMD_CAMERA_GET|普通               <eps>
221   224  RECOG_EVENT_STOP|難しい           <eps>
221   224  MMD_CAMERA_GET|難しい           <eps>
222   231  <eps>                             SYNTH_START|mei|mei_voice_normal|簡単を選択しました。
231   225  <eps>                             TEXTAREA_SET|msg_text|"かんたん をせんたくしました。"
223   232  <eps>                             SYNTH_START|mei|mei_voice_normal|普通を選択しました。
232   225  <eps>                             TEXTAREA_SET|msg_text|"ふつう をせんたくしました。"   
224   233  <eps>                             SYNTH_START|mei|mei_voice_normal|難しいを選択しました。
233   225  <eps>                             TEXTAREA_SET|msg_text|"むずかしい をせんたくしました。"
225   226  SYNTH_EVENT_STOP|mei              TEXTAREA_SET|msg_textbox|Accessory\img\clean.png
226   227  <eps>                             TEXTAREA_SET|msg_text|Accessory\img\clean.png
227   228  <eps>                             TEXTAREA_SET|menu_textbox|Accessory\img\clean.png
228   100  <eps>                             TEXTAREA_SET|menu_text|Accessory\img\clean.png                            


# バトル
100  101  <eps>                             SYNTH_START|mei|mei_voice_normal|それではバトル開始。
101  102  <eps>                             MOTION_ADD|mei|toridasi|Motion\mei_adv\kado_toridasi.vmd|PART|ONCE
102  103  SYNTH_EVENT_STOP|mei              TEXTAREA_SET|msg_textbox|Accessory\img\sentence_txtbox.png
103  104  <eps>                             <eps>
104  105  <eps>                             <eps>
105  106  <eps>                             <eps>
106  1000 <eps>                             <eps>
1000 1010 <eps>                             SYNTH_START|mei|mei_voice_normal|あなたのターンです。
1010 1012 <eps>                             TEXTAREA_SET|msg_text|"あなたのターンです。"
1012 1002 SYNTH_EVENT_STOP|mei              <eps>

1020 1021 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|あなたのターンです。カードを1まいひいてください。
1021 1022 <eps>                             TEXTAREA_SET|msg_text|"あなたのターンです。\nカードを 1まい 引いてください。"
1022 1002 SYNTH_EVENT_STOP|mei              <eps>

1002 1000 MMD_CAMERA_GET|ERROR              <eps>
1002 1102 <eps>                             SYNTH_START|mei|mei_voice_normal|カメラを起動します。使用するカードをかざしてください。
1102 1103 <eps>                             TEXTAREA_SET|msg_text|"カメラを きどうします。\nしようする カードを かざしてください。"

1103 1104 MMD_CAMERA_GET|marker             SYNTH_START|mei|mei_voice_normal|カードを読み込みました。
1104 1300 <eps>                             TEXTAREA_SET|msg_text|"カードを よみこみました。"
1103 1105 MMD_CAMERA_GET|used               SYNTH_START|mei|mei_voice_normal|使用済みのカードです。別のカードをかざしてください。
1105 1331 <eps>                             TEXTAREA_SET|msg_text|"しようずみの カードです。\nべつのカードを かざしてください。"
1331 1103 SYNTH_EVENT_STOP|mei              <eps>
# ここでお題の表示する （攻撃カードならなし？）
1300 1301 SYNTH_EVENT_STOP|mei              <eps>
1301 1007 MMD_CAMERA_GET|atk                <eps>
1301 1400 MMD_CAMERA_GET|def                <eps>
1301 1400 MMD_CAMERA_GET|heal               <eps>
1301 1400 MMD_CAMERA_GET|buff               <eps>
1301 1400 MMD_CAMERA_GET|adv_atk            <eps>
1301 1400 MMD_CAMERA_GET|draw               <eps>
1400 1401 <eps>                             SYNTH_START|mei|mei_voice_normal|おだい付きカードをよみこみました。それではお題を抽選します。
1401 1402 <eps>                             TEXTAREA_SET|msg_text|"おだい付きカードを よみこみました。\nそれでは おだいを ちゅうせんします。"
1402 1403 SYNTH_EVENT_STOP|mei              <eps>

1403 1400 MMD_CAMERA_GET|ERROR              <eps>
1403 1404 MMD_CAMERA_GET|push_ups           SYNTH_START|mei|mei_voice_normal|腕立て伏せ。が選択されました。
1404 1003 <eps>                             TEXTAREA_SET|msg_text|"”うでたてふせ” がせんたくされました。"
1403 1405 MMD_CAMERA_GET|squats             SYNTH_START|mei|mei_voice_normal|スクワット。が選択されました。
1405 1003 <eps>                             TEXTAREA_SET|msg_text|"”スクワット” がせんたくされました。"
1403 1406 MMD_CAMERA_GET|crunches           SYNTH_START|mei|mei_voice_normal|腹筋。が選択されました。
1406 1003 <eps>                             TEXTAREA_SET|msg_text|"”ふっきん” がせんたくされました。"
1403 1407 MMD_CAMERA_GET|red                SYNTH_START|mei|mei_voice_normal|赤色を探せ。が選択されました。
1407 1003 <eps>                             TEXTAREA_SET|msg_text|"”あかいろ をさがせ” がせんたくされました。"
1403 1408 MMD_CAMERA_GET|blue               SYNTH_START|mei|mei_voice_normal|青色を探せ。が選択されました。
1408 1003 <eps>                             TEXTAREA_SET|msg_text|"”あおいろ をさがせ” がせんたくされました。"
1403 1409 MMD_CAMERA_GET|green              SYNTH_START|mei|mei_voice_normal|みどりいろを探せ。が選択されました。
1409 1003 <eps>                             TEXTAREA_SET|msg_text|"”みどりいろ をさがせ” がせんたくされました。"   
1403 1410 MMD_CAMERA_GET|quiz               SYNTH_START|mei|mei_voice_normal|クイズ。が選択されました。
1410 1003 <eps>                             TEXTAREA_SET|msg_text|"”クイズ” がせんたくされました。"

1003 1004 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|お題にチャレンジしますか？
1004 1005 <eps>                             TEXTAREA_SET|msg_text|"おだいに チャレンジしますか？"
1005 1006 RECOG_EVENT_STOP|はい             SYNTH_START|mei|mei_voice_normal|お題にチャレンジします。それではがんばってください。むずかしいときは、「ギブアップ」ということでしっぱいあつかいでしゅうりょうできます。
1005 1006 RECOG_EVENT_STOP|し,ます          SYNTH_START|mei|mei_voice_normal|お題にチャレンジします。それではがんばってください。むずかしいときは、「ギブアップ」ということでしっぱいあつかいでしゅうりょうできます。
1006 1100 <eps>                             TEXTAREA_SET|msg_text|"おだいに チャレンジします。それでは がんばってください。\nむずかしいときは、「ギブアップ」ということで \nしっぱい あつかいで しゅうりょうできます。"

1005 1001 RECOG_EVENT_STOP|いいえ           SYNTH_START|mei|mei_voice_normal|お題にチャレンジしません。こんかいは,追加効果なしでとくしゅこうかをはつどうします。
1005 1001 RECOG_EVENT_STOP|し,ませ,ん       SYNTH_START|mei|mei_voice_normal|お題にチャレンジしません。こんかいは,追加効果なしでとくしゅこうかをはつどうします。
1001 1507 <eps>                             TEXTAREA_SET|msg_text|"おだいに チャレンジしません。\nこんかいは、ついかこうか なしで\nとくしゅこうか を はつどうします。"

1507 1007 SYNTH_EVENT_STOP|mei              <eps>
1007 1008 <eps>                             SYNTH_START|mei|mei_voice_normal|カードを発動します。
1008 1009 <eps>                             TEXTAREA_SET|msg_text|"カードを はつどうします"

1009 200  MMD_CAMERA_GET|atk                <eps>
1009 200  MMD_CAMERA_GET|adv_atk            <eps>
1009 300  MMD_CAMERA_GET|def                <eps>
1009 400  MMD_CAMERA_GET|heal               <eps>
1009 500  MMD_CAMERA_GET|buff               <eps>
1009 700  MMD_CAMERA_GET|draw                <eps>
#1011 7000 <eps>                             <eps>

1005 1006 MMD_CAMERA_GET|はい               SYNTH_START|mei|mei_voice_normal|お題にチャレンジします。それではがんばってください、むずかしいときは、「ギブアップ」ということでしっぱいあつかいでしゅうりょうできます
1005 1001 MMD_CAMERA_GET|いいえ             SYNTH_START|mei|mei_voice_normal|お題にチャレンジしません。こんかいは,追加効果なしでとくしゅこうかをはつどうします。


# ダメ計
7000 7001 <eps>                             SYNTH_START|mei|mei_voice_normal|ダメージ計算
7001 7002 SYNTH_EVENT_STOP|mei              <eps>
# mei<player
7002 4000 MMD_CAMERA_GET|勝ち               <eps>
# mei>player
7002 3000 MMD_CAMERA_GET|負け               <eps>

7002 7003 MMD_CAMERA_GET|続行               SYNTH_START|mei|mei_voice_normal|次のターンです。
7003 1020 <eps>                             TEXTAREA_SET|msg_text|"つぎのターン です。"

# mei Win
3000 3101 <eps>                             SYNTH_START|mei|mei_voice_normal|わたしのかちです。まだまだですね。
3101 3001 <eps>                             TEXTAREA_SET|msg_text|"わたしのかちです。\nまだまだですね。"
3001 3102 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|まだあなたはここからでることはできません。
3102 3002 <eps>                             TEXTAREA_SET|msg_text|"まだ あなたは ここからでることは できません。"
3002 3003 SYNTH_EVENT_STOP|mei              <eps>
3003 7701 <eps>                             MOTION_ADD|mei|action|Motion\mei_adv\lose.vmd|PART|ONCE

# mei Lose
4000 4101 <eps>                             SYNTH_START|mei|mei_voice_normal|わたしをたおすなんてなかなかやりますね…
4101 4001 <eps>                             TEXTAREA_SET|msg_text|"わたしを たおす なんて\nなかなか
4001 4102 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|たのしいバトルでした。またバトルできることをたのしみにしています。
4102 4002 <eps>                             TEXTAREA_SET|msg_text|"たのしい バトルでした。\nまた バトルできることを\nたのしみにしています。"
4002 4003 SYNTH_EVENT_STOP|mei              <eps>
4003 7700 <eps>                             MOTION_ADD|mei|action|Motion\mei_adv\win.vmd|PART|ONCE

# 終わり（仮）
7700 9900 <eps>                                SYNTH_START|mei|mei_voice_normal|ゲーム終了
9900 9901 SYNTH_EVENT_STOP                     <eps>   
7701 2    <eps>                                <eps>

# プレイヤー攻撃
200 201 <eps>                               SYNTH_START|mei|mei_voice_normal|攻撃カードですね。
201 202 <eps>                               TEXTAREA_SET|msg_text|"こうげきカード ですね。"
202 203 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|あなたの力をわたしに見せてください。
203 204 <eps>                               TEXTAREA_SET|msg_text|"あなたの力を わたしに 見せてください。"

204 205 SYNTH_EVENT_STOP|mei                <eps>
205 206 <eps>                               SYNTH_START|mei|mei_voice_normal|なかなかやりますね。
206 207 <eps>                               TEXTAREA_SET|msg_text|"なかなか やりますね。"
207 208 SYNTH_EVENT_STOP|mei                <eps>
208 600 <eps>                               <eps>

# mei攻撃
600 601  <eps>                               SYNTH_START|mei|mei_voice_normal|さて、わたしのターンですね！くらえ！
601 602  <eps>                               TEXTAREA_SET|msg_text|"さて、わたしのターン ですね！\nくらえ！"
602 603  <eps>                               MOTION_ADD|mei|action|Motion\mei_adv\syoukan.vmd|PART|ONCE
603 7000 SYNTH_EVENT_STOP|mei                <eps>
#603 7000 <eps>                               <eps>

# プレイヤー防御
300 301 <eps>                               SYNTH_START|mei|mei_voice_normal|防御します。
301 502 <eps>                               TEXTAREA_SET|msg_text|"ぼうぎょ します。"
#301 302 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|攻撃以外なのでもう一度あなたのターンです。
#302 1002 SYNTH_EVENT_STOP|mei               <eps>

# プレイヤー回復
400 401 <eps>                               SYNTH_START|mei|mei_voice_normal|回復します。
401 502 <eps>                               TEXTAREA_SET|msg_text|"かいふく します。"
#401 402 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|攻撃以外なのでもう一度あなたのターンです。
#402 1002 SYNTH_EVENT_STOP|mei               <eps>

# プレイヤーバフ
500 501 <eps>                               SYNTH_START|mei|mei_voice_normal|バフをかけます。
501 502 <eps>                               TEXTAREA_SET|msg_text|"バフを かけます。"

502 503  SYNTH_EVENT_STOP|mei               SYNTH_START|mei|mei_voice_normal|攻撃以外なのでもう一度あなたのターンです。
503 504  <eps>                              TEXTAREA_SET|msg_text|"こうげき いがいなので\nもういちど あなたのターン です。"    
504 1002 SYNTH_EVENT_STOP|mei               <eps>

# ドロー
700 701 <eps>                               SYNTH_START|mei|mei_voice_normal|いまから言う枚数ドローしてください。
701 702 <eps>                               TEXTAREA_SET|msg_text|"いまから いう まいすう ドローしてください。"
702 703 SYNTH_EVENT_STOP|mei                <eps>
703 704 MMD_CAMERA_GET|draw2                 SYNTH_START|mei|mei_voice_normal|2まいドローしてください
704 709 <eps>                               TEXTAREA_SET|msg_text|"2まい ドローしてください。"
703 705 MMD_CAMERA_GET|draw3                 SYNTH_START|mei|mei_voice_normal|3まいドローしてください
705 709 <eps>                               TEXTAREA_SET|msg_text|"3まい ドローしてください。"
709 1002 SYNTH_EVENT_STOP|mei                 <eps>


# お題待機
1100 1101 SYNTH_EVENT_STOP|mei              SYNTH_START|mei|mei_voice_normal|お題を表示します。
1101 1110 SYNTH_EVENT_STOP|mei              <eps>
#1102 1110 MMD_CAMERA_GET|push_ups          SYNTH_START|mei|mei_voice_normal|腕立て伏せ
#1102 1110 MMD_CAMERA_GET|squats            SYNTH_START|mei|mei_voice_normal|スクワット
#1102 1110 MMD_CAMERA_GET|crunches          SYNTH_START|mei|mei_voice_normal|腹筋
#1102 1110 MMD_CAMERA_GET|red               SYNTH_START|mei|mei_voice_normal|赤色
#1102 1110 MMD_CAMERA_GET|blue              SYNTH_START|mei|mei_voice_normal|青色
#1102 1110 MMD_CAMERA_GET|green             SYNTH_START|mei|mei_voice_normal|緑色

1110 1111 MMD_CAMERA_GET|成功               SYNTH_START|mei|mei_voice_normal|チャレンジせいこうです！おめでとうございます。カードのこうかがアップしました
1111 1115 <eps>                             TEXTAREA_SET|msg_text|"チャレンジせいこうです！\nおめでとうございます。\nカードのこうかがアップしました。"
1110 1112 MMD_CAMERA_GET|失敗               SYNTH_START|mei|mei_voice_normal|チャレンジしっぱいです…おつかれさまでした。
1112 1115 <eps>                             TEXTAREA_SET|msg_text|"チャレンジしっぱいです・・・\nおつかれさまでした。"

# quiz
1110 2500 MMD_CAMERA_GET|quiz               SYNTH_START|mei|mei_voice_normal|クイズ表示
2500 2501 SYNTH_EVENT_STOP|mei              <eps>
2502 2503 <eps>                             SYNTH_START|mei|mei_voice_normal|正解です

2501 2601 MMD_CAMERA_GET|トラック           <eps>
2601 2502 RECOG_EVENT_STOP|トラック         <eps>

# ギブアップロジックは多すぎて無理
#2601 2661 RECOG_EVENT_START|ギブアップ     SYNTH_START|mei|mei_voice_normal|ギブアップしますか？
#2661 2601 RECOG_EVENT_STOP|はい             SYNTH_START|mei|mei_voice_normal|チャレンジしっぱいです…おつかれさまでした。
#2661 2614 RECOG_EVENT_STOP|いいえ           SYNTH_START|mei|mei_voice_normal|では、引き続きがんばってください！

2501 2602 MMD_CAMERA_GET|森              <eps>
2602 2502 RECOG_EVENT_STOP|森              <eps>
2501 2603 MMD_CAMERA_GET|サイ              <eps>
2603 2502 RECOG_EVENT_STOP|サイ              <eps>
2501 2604 MMD_CAMERA_GET|焼肉              <eps>
2604 2502 RECOG_EVENT_STOP|焼肉              <eps>
2501 2605 MMD_CAMERA_GET|洗濯              <eps>
2605 2502 RECOG_EVENT_STOP|洗濯              <eps>
2501 2606 MMD_CAMERA_GET|ポスト              <eps>
2606 2502 RECOG_EVENT_STOP|ポスト              <eps>
2501 2607 MMD_CAMERA_GET|８              <eps>
2607 2502 RECOG_EVENT_STOP|８              <eps>
2501 2608 MMD_CAMERA_GET|目玉焼き              <eps>
2608 2502 RECOG_EVENT_STOP|目玉焼き              <eps>
2501 2609 MMD_CAMERA_GET|梨             <eps>
2609 2502 RECOG_EVENT_STOP|梨             <eps>
2501 2610 MMD_CAMERA_GET|花火            <eps>
2610 2502 RECOG_EVENT_STOP|花火              <eps>
2501 2611 MMD_CAMERA_GET|カブトムシ              <eps>
2611 2502 RECOG_EVENT_STOP|カブトムシ              <eps>
2501 2612 MMD_CAMERA_GET|三字              <eps>
2612 2502 RECOG_EVENT_STOP|三字             <eps>
2501 2613 MMD_CAMERA_GET|カワウソ              <eps>
2613 2502 RECOG_EVENT_STOP|カワウソ              <eps>
2501 2614 MMD_CAMERA_GET|しりとり              <eps>
2614 2502 RECOG_EVENT_STOP|しりとり              <eps>


1110 1113 RECOG_EVENT_STOP|ギブアップ       SYNTH_START|mei|mei_voice_normal|ギブアップしますか？
1110 1113 MMD_CAMERA_GET|ギブアップ         SYNTH_START|mei|mei_voice_normal|ギブアップしますか？
1110 1113 RECOG_EVENT_STOP|諦める           SYNTH_START|mei|mei_voice_normal|ギブアップしますか？
1113 1116 <eps>                             TEXTAREA_SET|msg_text|"ギブアップしますか？"

1116 1114 RECOG_EVENT_STOP|はい             SYNTH_START|mei|mei_voice_normal|チャレンジしっぱいです…おつかれさまでした。
1116 1114 MMD_CAMERA_GET|はい               SYNTH_START|mei|mei_voice_normal|チャレンジしっぱいです…おつかれさまでした。
1114 1115 <eps>                             TEXTAREA_SET|msg_text|"チャレンジしっぱいです・・・\nおつかれさまでした。"
1116 1117 RECOG_EVENT_STOP|いいえ           SYNTH_START|mei|mei_voice_normal|では、引き続きがんばってください！
1116 1117 MMD_CAMERA_GET|いいえ             SYNTH_START|mei|mei_voice_normal|では、引き続きがんばってください！
1117 1110 <eps>                             TEXTAREA_SET|msg_text|"では、ひきつづき がんばってください！"

1115 1118 SYNTH_EVENT_STOP|mei              <eps>
1118 1007 <eps>                             <eps>

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



#1    140  MMD_CAMERA_GET|user_attack          MOTION_ADD|mei|idle|Motion\mei_idle\damage.vmd|PART|ONCE
#140  141  <eps>                               SYNTH_START|mei|mei_voice_normal|攻撃を受けました。 
#141  2    SYNTH_EVENT_STOP|mei                <eps>

#1    142  MMD_CAMERA_GET|user_lose            SYNTH_START|mei|mei_voice_normal|わたしの勝ちです。
#142  2    SYNTH_EVENT_STOP|mei                <eps>

#1    144  MMD_CAMERA_GET|user_win             SYNTH_START|mei|mei_voice_normalあなたの勝ちです。
#144  2    SYNTH_EVENT_STOP|mei                <eps>
