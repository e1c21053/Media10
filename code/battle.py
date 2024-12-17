import struct
import mmap
import numpy as np
import os
os.environ["OPENCV_VIDEOIO_MSMF_ENABLE_HW_TRANSFORMS"] = "0"
import cv2
import pandas as pd
from cv2 import aruco

from recognizer import color
from recognizer import exercise
from recognizer import hand

WIDTH = 640
HEIGHT = 480

EASY = '簡単'
NORMAL = '普通'
HARD = '難しい'
LEVEL = '難易度'
START ='ゲーム開始'

#カードデータ(csvファイル)を読み込む
card_data = pd.read_csv('card.csv')
card_data['used'] = 0
card_data.insert(0, 'id', range(len(card_data)))

base_img = cv2.imread("data/background.jpg")

#ステータス
class status:
    def __init__(self, hp, ap):
        self.hp = hp
        self.ap = ap
mei_status = status(100, 0)
user_status = status(100, 0)

#メイの攻撃力
mei_dmg_list = [(10, 0.3), (20, 0.5), (30, 0.2)]

def get_random_dmg(dmg_list: list[tuple[int, float]]) -> int:
    """
    list[tuple[int,float] int はダメージ量, float は確率を引数に取り，確率に応じてダメージ量を返す関数
    例: get_random_dmg([(10, 0.5), (20, 0.3), (30, 0.2)]) は, 10の確率0.5, 20の確率0.3, 30の確率0.2でダメージ量を返す
    """
    return np.random.choice([dmg[0] for dmg in dmg_list], p=[dmg[1] for dmg in dmg_list])

###この部分はMMDAgentとの通信部分です．触らないでください###
def recv_message():
    len = mm.find(b'\x00',0x00,0xff)
    str = ''
    if len !=0 :	
        mm.seek(0x0)
        line = mm.read(len)
        try:
            str = line.decode()
        except UnicodeDecodeError:
            print("Decode Error")
        mm.seek(0x0)
        mm.write(b'\x00')
    return str

def send_message(send):
    mm.seek(0x200)
    mm.write(struct.pack('512s', send))
###ここまではMMDAgentとの通信部分です．触らないでください###

#マーカー読み取り
def get_marker(cap):
    #ARマーカーの設定
    dict_aruco = aruco.Dictionary_get(aruco.DICT_6X6_100)
    parameters = aruco.DetectorParameters_create()
    marker_id = None

    #有効なマーカーを読み込めるまで
    while marker_id == None:
        key = cv2.waitKey(10)

        #'q'またはエスケープキーが入力されたらwhileの外へ出る
        if ( key==ord('q') ) or ( key==27 ) : #Unicodeに変換
            marker_id = -2
            break
        
        mmd_str = recv_message()
            
        if 'マーカー' in mmd_str:
        #if key == ord('0'):
            while True:
                key = cv2.waitKey(10)
                mmd_str = recv_message()

                #'q'またはエスケープキーが入力されたらwhileの外へ出る
                if ( key==ord('q') ) or ( key==27 ) : #Unicodeに変換
                    marker_id = -2
                    break
                
                #if 'パス' in mmd_str:
                if key==ord('p'):
                    marker_id = -1
                    break

                ret, frame = cap.read()

                gray = cv2.cvtColor(frame, cv2.COLOR_RGB2GRAY)  #ARマーカーを読み込むためグレースケールにする
                corners, ids, rejectedImgPoints = aruco.detectMarkers(gray, dict_aruco, parameters=parameters)  #ARマーカーの検出
                result = aruco.drawDetectedMarkers(frame, corners, ids) #検出したマーカーにidと枠を描画

                #マーカー描画結果を表示
                cv2.imshow("marker",result)

                #検出されたマーカーの番号を1次元リストに格納する
                list_ids = np.ravel(ids)

                if list_ids[0] != None:
                    marker_id = list_ids[0]
                    #send_id = 'marker_id' + str(marker_id)
                    key = cv2.waitKey(600)
                    
                    exists = (card_data['id'] == marker_id).any()    #読み込んだカードがcard_dataにあるか
                    if exists:
                        if card_data.loc[marker_id, 'used'] == 1:
                            print("使用済みのカードです")
                        else:
                            #send_message(send_id.encode())
                            break
                    else:
                        print("未登録のカードです！")
            cv2.destroyWindow('marker')
    return marker_id
                    
#バトル処理
def battle(cap):
    cnt = 0     #ターン数
    end_game = False

    while not end_game:
        if user_status.hp <= 0:
            print("user lose...")
            send_message(b'user_lose')
            break
        if mei_status.hp <= 0:
            print("user win!")
            send_message(b'user_win')
            break

        #MMDAgentの発話内容を表示する
        mmd_str = recv_message()
        if len(mmd_str) != 0:
            print(mmd_str)
        
        #ユーザのターン
        if cnt % 2 == 0:
            while True:
                #マーカー読込
                marker_id = get_marker(cap) 
                
                #中断処理
                if marker_id < -1:
                    end_game = True
                    print("ゲームを中断しました")
                    break
                #パス
                elif marker_id < 0:
                    print("パスしました")
                    break
                
                card_data.loc[marker_id, 'used'] = 1    #カードを使用済みに
                card = card_data.iloc[marker_id]
                
                print_card(card)

                if card['type'] == 'atk':   #攻撃カード
                    send_message(b'attack_card')

                    user_status.ap += card['value']
                    mei_status.hp -= user_status.ap
                    print("ユーザが " + str(user_status.ap) + " のアタック！")
                    user_status.ap = 0
                    send_message(b'user_attack')
                    break
                else:                       #特殊カード
                    send_message(b'special_card')
                    print("お題に挑戦しますか？")

                    if card['type'] == 'def' or card['type'] == 'heal':
                        mode = np.random.choice(['squats', 'push_ups', 'crunches'])
                        send_message(mode.encode())
                        print(mode)

                    #お題にチャレンジするか
                    will_challenge = get_bool('', '')

                    if card['type'] == 'buff':  #バフカード
                        if will_challenge:
                            is_cleared = buff_color(cap)
                            if is_cleared:
                                print("成功！")
                                send_message(b'success')
                                user_status.ap += card['bonusValue']
                            else:
                                print("失敗...")
                                user_status.ap += card['value']
                        else:
                            user_status.ap += card['value']
                    elif card['type'] == 'def':                 #防御カード
                        #運動
                        if will_challenge:
                            is_cleared = exercise_challenge(cap, mode)
                            if is_cleared:
                                print("成功！")
                                mei_status.ap -= card['bonusValue']
                            else:
                                print("失敗...")
                                mei_status.ap -= card['value']
                        else:
                            mei_status.ap -= card['value']
                    elif card['type'] == 'heal':                #回復カード
                        #運動
                        user_status.hp += card['value']
                        if user_status.hp > 100:
                            user_status.hp = 100
                        print_status()
                        print("HPを" + str(card['value']) + " 回復！")
                    else:                                       #ドローカード
                        #クイズ
                        if will_challenge:
                            isCleared = get_bool('正解', '不正解')
                            if isCleared:
                                num = card['bonusValue']
                            else:
                                num = card['value']
                        else:
                            num = card['value']
                        print("カードを " + str(num) + " 枚引いてください")

        #メイちゃんのターン
        else:
            mei_status.ap += get_random_dmg(mei_dmg_list)
            if mei_status.ap < 0:
                mei_status.ap = 0
            user_status.hp -= mei_status.ap
            print("メイが " + str(mei_status.ap) + " のアタック！")

            mei_status.ap = 0

        cnt += 1
        print_status()

#バフカードのお題
def buff_color(cap):
    color_recognizer = color.ColorRecognizer()
    is_cleared = False
    color_list = ['red', 'green', 'blue']

    correct_color = np.random.choice(color_list)   #正解の色
    print(correct_color + 'を探してください')

    while cap.isOpened():
        ret, frame = cap.read()
        frame=cv2.flip(frame, 1)    #左右反転

        key = cv2.waitKey(10)

        #'q'またはエスケープキーが入力されたらwhileの外へ出る
        if ( key==ord('q') ) or ( key==27 ) : #Unicodeに変換
            break
        
        recognized_color = color_recognizer.recognize_color(frame)

        cv2.putText(frame, recognized_color, (50, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 2, (0, 0, 255), 2, cv2.LINE_AA)
        cv2.imshow('color', frame)

        if recognized_color == correct_color:
            is_cleared = True
            break
    
    cv2.destroyWindow('color')
    return is_cleared

def exercise_challenge(cap, mode):
    recognizer = exercise.ExerciseRecognizer()
    is_cleared = False
    while True:
        ret, frame = cap.read()

        frame = recognizer.recognize_exercise(frame, mode)
        cv2.imshow('exercise', frame)

        if cv2.waitKey(10) & 0xFF == ord('q'):
            break

        if mode == 'push_ups' and recognizer.push_up_count == 10:
            is_cleared = True
            break
        elif mode == 'squats' and recognizer.squat_count == 10:
            is_cleared = True
            break
        elif mode == 'crunches' and recognizer.crunch_count == 10:
            is_cleared = True
            break

    cv2.destroyWindow('exercise')
    return is_cleared

#ステータスを表示
def print_status():
    status_img = base_img.copy()
    user_HP = user_status.hp
    mei_HP = mei_status.hp

    cv2.putText(status_img, text='user:'+'{:>3}'.format(user_HP), org=(0,100), fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=3.0, color=(0,0,0), thickness=3)
    cv2.putText(status_img, text='mei:'+'{:>3}'.format(mei_HP), org=(0,200), fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=3.0, color=(0,0,0), thickness=3)
    cv2.imshow('status', status_img)

#カードを表示
def print_card(card):
    card_img = base_img.copy()
    cv2.putText(card_img, text='name:'+card['name'], org=(0,100), fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=2.0, color=(0,0,0), thickness=2)
    cv2.putText(card_img, text='type:'+card['type'], org=(0,150), fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=2.0, color=(0,0,0), thickness=2)
    cv2.putText(card_img, text='value:'+str(card['value']), org=(0,200), fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=2.0, color=(0,0,0), thickness=2)
    cv2.imshow('card', card_img)

#返り値がTrueのメッセージとFalseのメッセージを指定
def get_bool(true_msg, false_msg):
    while True:
        key = cv2.waitKey(10)
        mmd_str = recv_message()

        #if false_msg in mmd_str:
        if key==ord('n'):
            return False

        #if true_msg in mmd_str:
        if key==ord('y'):
            return True

#難易度設定
def set_level():
    print("難易度選択")

    while True:
        key = cv2.waitKey(10)
        mmd_str = recv_message()
        if len(mmd_str) > 0:
            print(mmd_str)

        if EASY in mmd_str:
            return 100, [(10, 0.3), (20, 0.5), (30, 0.2)]
        if NORMAL in mmd_str:
            return 150, [(10, 0.15), (20, 0.4), (30, 0.35), (50, 0.1)]
        if HARD in mmd_str:
            return 200, [(10, 0.1), (30, 0.4), (50, 0.4), (70, 0.1)]
        

if __name__ == '__main__':
    #カメラを取得
    #カメラが1つしかなければ0を引数として設定
    cap = cv2.VideoCapture(0)
    #カメラ画像の解像度を指定
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, WIDTH)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, HEIGHT)
    #共有メモリのオープン
    mm = mmap.mmap(-1, 0x400, "Share_MMD_Camera")


    #ゲーム開始待ち処理
    while True:
        key = cv2.waitKey(10)
        mmd_str = recv_message()
        if len(mmd_str) > 0:
            print(mmd_str)

        if key==ord('q'):
            break

        if LEVEL in mmd_str:
            mei_status.hp, mei_dmg_list = set_level()

        if START in mmd_str:
            break


    if(cap.isOpened()==True):
        print(type(card_data))
        print(card_data)
        print_status()
        battle(cap)
    else:
        print('カメラを取得できませんでした')
