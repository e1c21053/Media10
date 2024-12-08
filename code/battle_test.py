import struct
import mmap
import numpy as np
import os
os.environ["OPENCV_VIDEOIO_MSMF_ENABLE_HW_TRANSFORMS"] = "0"
import cv2
import mediapipe as mp
import pandas as pd
from cv2 import aruco

WIDTH = 640
HEIGHT = 480

#カードデータ(csvファイル)を読み込む
card_data = pd.read_csv('code/media3/card.csv')
card_data['used'] = 0
base_img = cv2.imread("code/media3/data/background.jpg")

#ステータス
class Status:
    def __init__(self, hp, ap):
        self.hp = hp
        self.ap = ap
mei_status = Status(100, 0)
user_status = Status(100, 0)


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
    did_get_id = False
    card = None

    #有効なマーカーを読み込めるまで
    while not did_get_id:
        key = cv2.waitKey(10)

        #'q'またはエスケープキーが入力されたらwhileの外へ出る
        if ( key==ord('q') ) or ( key==27 ) : #Unicodeに変換
            break
        
        #MMDAgentの発話内容を表示する
        str1 = recv_message()
        if len(str1) != 0:
            print(str1)
            
        #if 'マーカー' in str1:
        if(key == ord('0')):
            while(True):
                key = cv2.waitKey(10)

                #'q'またはエスケープキーが入力されたらwhileの外へ出る
                if ( key==ord('q') ) or ( key==27 ) : #Unicodeに変換
                    break

                #カメラから画像(フレーム)を取得しframeに代入
                ret, frame = cap.read()

                #ARマーカーを読み込むためグレースケールにする
                gray = cv2.cvtColor(frame, cv2.COLOR_RGB2GRAY)
                #ARマーカーの検出
                corners, ids, rejectedImgPoints = aruco.detectMarkers(gray, dict_aruco, parameters=parameters)
                #検出したマーカーにidと枠を描画
                result = aruco.drawDetectedMarkers(frame, corners, ids)

                #マーカー描画結果を表示
                cv2.imshow("marker",result)

                #検出されたマーカーの番号を1次元リストに格納する
                list_ids = np.ravel(ids)

                if list_ids[0] != None:
                    marker_id = list_ids[0]
                    send_id = 'marker_id' + str(marker_id)
                    key = cv2.waitKey(600)
                    
                    exists = (card_data['id'] == marker_id).any()    #読み込んだカードがcard_dataにあるか
                    if exists:
                        send_message(send_id.encode())
                        cv2.destroyWindow('marker')
                        card = card_data.iloc[marker_id]
                        print(card['name'])
                        did_get_id = True
                        break
                    else:
                        print("未登録のカードです！")
    return card
                    
#バトル処理
def battle(cap):
    cnt = 0     #ターン数
    end_game = False

    while not end_game:
        if user_status.hp <= 0:
            print("user lose...")
            break
        if mei_status.hp <= 0:
            print("user win!")
            break
        
        #ユーザのターン
        if cnt % 2 == 0:
            type = ''
            value = 0

            while type != 'atk':        #攻撃カードでない間
                card = get_marker(cap)  #マーカー読込
                
                #中断処理
                if not isinstance(card, pd.Series):
                    end_game = True
                    print("ゲームを中断しました")
                    break

                type = card['type']
                value = card['value']

                if type == 'buff':              #バフカード
                    user_status.ap += value
                elif type == 'def':             #防御カード
                    mei_status.ap -= value
                elif type == 'heal':            #回復カード
                    user_status.hp += value
                    print_status()
                    print("HPを" + str(value) + " 回復！")
            
            if not end_game:
                user_status.ap += value
                mei_status.hp -= user_status.ap
                print("ユーザが " + str(user_status.ap) + " のアタック！")

            user_status.ap = 0
        #メイちゃんのターン
        else:
            mei_status.ap += 20
            user_status.hp -= mei_status.ap
            print("メイが " + str(mei_status.ap) + " のアタック！")

            mei_status.ap = 0

        cnt += 1

        print_status()
    
#ステータスを表示する
def print_status():
    status_img = base_img.copy()
    user_HP = user_status.hp
    mei_HP = mei_status.hp

    cv2.putText(status_img, text='user:'+'{:>3}'.format(user_HP), org=(0,100), fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=3.0, color=(0,0,0), thickness=3)
    cv2.putText(status_img, text='mei:'+'{:>3}'.format(mei_HP), org=(0,200), fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=3.0, color=(0,0,0), thickness=3)
    cv2.imshow('status', status_img)

if __name__ == '__main__':
    #カメラを取得
    #カメラが1つしかなければ0を引数として設定
    cap = cv2.VideoCapture(0)
    #カメラ画像の解像度を指定
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, WIDTH)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, HEIGHT)
    #共有メモリのオープン
    mm = mmap.mmap(-1, 0x400, "Share_MMD_Camera")

    if(cap.isOpened()==True):
        print(type(card_data))
        print(card_data)
        print_status()
        battle(cap)
    else:
        print('カメラを取得できませんでした')
