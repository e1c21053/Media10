# 0011-0020 Initialization

0    11   <eps>                               MODEL_ADD|bootscreen|Accessory\bootscreen\bootscreen.pmd|0.0,12.85,17.6|0.0,0.0,0.0|OFF
11   12   MODEL_EVENT_ADD|bootscreen          MODEL_ADD|mei|Model\mei\mei.pmd|0.0,0.0,-14.0
12   13   <eps>                               MODEL_ADD|menu|Accessory\menu\menu.pmd|0.0,-4.5,0.0|0.0,0.0,0.0|ON|mei
13   14   <eps>                               MOTION_ADD|menu|rotate|Motion\menu_rotation\menu_rotation.vmd|FULL|LOOP|OFF|OFF
14   15   <eps>                               STAGE|Stage\building2\floor.bmp,Stage\building2\background.bmp
15   16   <eps>                               MOTION_ADD|mei|base|Motion\mei_wait\mei_wait.vmd|FULL|LOOP|ON|OFF
16   17   <eps>                               TIMER_START|bootscreen|1.5
17   2    TIMER_EVENT_STOP|bootscreen         MODEL_DELETE|bootscreen

# 0021-0030 Idle behavior

2    3   <eps>                               TIMER_START|idle1|5
#21   22   TIMER_EVENT_START|idle1             TIMER_START|idle2|10
#22   23   TIMER_EVENT_START|idle2             TIMER_START|idle3|20
#23   24   TIMER_EVENT_START|idle3             TIMER_START|idle4|25
#24   1    TIMER_EVENT_START|idle4             VALUE_SET|random|0|100
1    1    RECOG_EVENT_START                   MOTION_ADD|mei|listen|Expression\mei_listen\mei_listen.vmd|PART|ONCE
#1    1    TIMER_EVENT_STOP|idle1              MOTION_ADD|mei|idle|Motion\mei_idle\mei_idle_boredom.vmd|PART|ONCE
#1    1    TIMER_EVENT_STOP|idle2              MOTION_ADD|mei|idle|Motion\mei_idle\mei_idle_touch_clothes.vmd|PART|ONCE
#1    2    TIMER_EVENT_STOP|idle3              MOTION_ADD|mei|idle|Motion\mei_idle\mei_idle_think.vmd|PART|ONCE
#1    1    TIMER_EVENT_STOP|idle3              MOTION_ADD|mei|idle|Motion\mei_idle\mei_idle_think.vmd|PART|ONCE
#1    2    TIMER_EVENT_STOP|idle4                SYNTH_START|mei|mei_voice_normal|マーカー

# 起動 難易度選択
# メイはプレイヤーに対して「難易度を選択してください」と発話し、ユーザからの応答を待つ。
3    20   <eps>                               SYNTH_START|mei|mei_voice_normal|難易度を選択してください。
20   21   SYNTH_EVENT_STOP|mei                <eps>
#21   25   MMD_CAMERA_GET|簡単                 VALUE_EVAL|difficulty|EQ|easy
21   25   MMD_CAMERA_GET|簡単                 SYNTH_START|mei|mei_voice_normal|簡単モードを選択しました。
# 21   22   RECOG_EVENT_STOP|簡単                 VALUE_SET|difficulty|easy
21   25   RECOG_EVENT_STOP|普通                 SYNTH_START|mei|mei_voice_normal|普通モードを選択しました。
21   25   RECOG_EVENT_STOP|難しい               SYNTH_START|mei|mei_voice_normal|難しいモードを選択しました。
#25  22   <eps>                               SYNTH_START|mei|mei_voice_normal|難易度を選択しました。

#25 29 VALUE_EVENT_EVAL|difficulty|EQ|easy|TRUE      SYNTH_START|mei|mei_voice_normal|簡単モードを選択しました。
#22 29 VALUE_EVENT_EVAL|difficulty|EQ|normal|TRUE    SYNTH_START|mei|mei_voice_normal|普通モードを選択しました。
#22 29 VALUE_EVENT_EVAL|difficulty|EQ|hard|TRUE      SYNTH_START|mei|mei_voice_normal|難しいモードを選択しました。
25 9000 SYNTH_EVENT_STOP|mei                           <eps>

# ストーリー挿入(仮)
9000 8001 <eps>                                     SYNTH_START|mei|mei_voice_normal|ストーリー挿入

# meiモデル表示 (上で定義してるモデル表示を後で消しておく)
8001 31 <eps>                                     MODEL_ADD|mei|Model\mei\mei.pmd|0.0,0.0,-14.0

# ?
31 40 <eps>                                     <eps>

# ルール説明分岐
40 41 <eps>                                     SYNTH_START|mei|mei_voice_normal|ルール説明をききますか？
41 42 SYNTH_EVENT_STOP|mei                      <eps>
#42 50 MMD_CAMERA_GET|はい                     SYNTH_START|mei|mei_voice_normal|ルール説明を開始します。
42 50 RECOG_EVENT_STOP|はい                     SYNTH_START|mei|mei_voice_normal|ルール説明を開始します。
42 100 MMD_CAMERA_GET|いいえ                   SYNTH_START|mei|mei_voice_normal|ルール説明をスキップします。
#42 100 RECOG_EVENT_STOP|いいえ                   SYNTH_START|mei|mei_voice_normal|ルール説明をスキップします。

# ルール説明
50 51 SYNTH_EVENT_STOP|mei                      <eps>
51 60 <eps>                                     SYNTH_START|mei|mei_voice_normal|ルール説明1
60 100 MMD_CAMERA_GET|次                      SYNTH_START|mei|mei_voice_normal|ルール説明2
#60 61 RECOG_EVENT_STOP|次                      SYNTH_START|mei|mei_voice_normal|ルール説明2

# バトル
100 1001 SYNTH_EVENT_STOP|mei                   SYNTH_START|mei|mei_voice_normal|バトル開始
1001 1002 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|あなたのターンです。
1002 1003 MMD_CAMERA_GET|マーカー              SYNTH_START|mei|mei_voice_normal|マーカー認識。
1003 1004 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|お題に挑戦しますか？
1004 1100 MMD_CAMERA_GET|はい                  SYNTH_START|mei|mei_voice_normal|お題に挑戦します。
1004 1007 MMD_CAMERA_GET|いいえ                SYNTH_START|mei|mei_voice_normal|お題に挑戦しません。
1007 1008 SYNTH_EVENT_STOP|mei               SYNTH_START|mei|mei_voice_normal|カード発動。
1008 200 MMD_CAMERA_GET|攻撃                 SYNTH_START|mei|mei_voice_normal|攻撃します。
1008 300 MMD_CAMERA_GET|防御                 SYNTH_START|mei|mei_voice_normal|防御します。
1009 400 MMD_CAMERA_GET|回復                 SYNTH_START|mei|mei_voice_normal|回復します。
1010 7000 <eps>                                <eps>

# ダメ計
7000 7001 <eps>                                SYNTH_START|mei|mei_voice_normal|ダメージ計算
# mei<player
7001 4000 MMD_CAMERA_GET|勝ち                <eps>
# mei>player
7001 3000 MMD_CAMERA_GET|負け                <eps>

7001 1001 MMD_CAMERA_GET|続行                 SYNTH_START|mei|mei_voice_normal|次のターンです。

# mei Win
3000 3001 <eps>                                SYNTH_START|mei|mei_voice_normal|わたしの勝ちです。
3001 7000 SYNTH_EVENT_STOP|mei                                <eps>

# mei Lose
4000 4001 <eps>                                SYNTH_START|mei|mei_voice_normal|あなたの勝ちです。
4001 7000 SYNTH_EVENT_STOP|mei                                <eps>

# 終わり（仮）
7700 2 <eps>                                     SYNTH_START|mei|mei_voice_normal|ゲーム終了


# プレイヤー攻撃
200 201 <eps>                                <eps>
201 7000 <eps>                                <eps>

# mei攻撃
600 601 <eps>                                SYNTH_START|mei|mei_voice_normal|攻撃します。
601 7000 <eps>                                <eps>

# プレイヤー防御
300 301 <eps>                                SYNTH_START|mei|mei_voice_normal|防御します。
301 302 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|攻撃以外なのでもう一度あなたのターンです。
302 1001 SYNTH_EVENT_STOP|mei                <eps>

# プレイヤー回復
400 401 <eps>                                SYNTH_START|mei|mei_voice_normal|回復します。
401 402 SYNTH_EVENT_STOP|mei                SYNTH_START|mei|mei_voice_normal|攻撃以外なのでもう一度あなたのターンです。
402 1001 SYNTH_EVENT_STOP|mei                <eps>

# お題待機
1100 1101 <eps>                                SYNTH_START|mei|mei_voice_normal|お題を表示します。
1101 1104 MMD_CAMERA_GET|成功                 SYNTH_START|mei|mei_voice_normal|お題成功
1101 1104 MMD_CAMERA_GET|失敗                 SYNTH_START|mei|mei_voice_normal|お題失敗
1104 1007 <eps>                <eps>

## 0031-0040 Hello
#
#1    31   RECOG_EVENT_STOP|マーカー         SYNTH_START|mei|mei_voice_normal|マーカーをかざしてください。
#1    31   RECOG_EVENT_STOP|まーか         SYNTH_START|mei|mei_voice_normal|マーカーをかざしてください。
#1    31   RECOG_EVENT_STOP|マーカ         SYNTH_START|mei|mei_voice_normal|マーカーをかざしてください。
#31   32   <eps>                               MOTION_ADD|mei|action|Motion\mei_greeting\mei_greeting.vmd|PART|ONCE
#32   2    SYNTH_EVENT_STOP|mei                <eps>
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



1    140  MMD_CAMERA_GET|user_attack             MOTION_ADD|mei|idle|Motion\mei_idle\damage.vmd|PART|ONCE
140  141  <eps>                                    SYNTH_START|mei|mei_voice_normal|攻撃を受けました。 
141  2    SYNTH_EVENT_STOP|mei                <eps>

1    142  MMD_CAMERA_GET|user_lose                SYNTH_START|mei|mei_voice_normal|わたしの勝ちです。
142  2    SYNTH_EVENT_STOP|mei                <eps>

1    144  MMD_CAMERA_GET|user_win              SYNTH_START|mei|mei_voice_normalあなたの勝ちです。
144  2    SYNTH_EVENT_STOP|mei                <eps>
