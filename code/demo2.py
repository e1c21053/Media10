from recognizer import color
from recognizer import exercise
from cv2 import aruco
import pandas as pd
import numpy as np
import mmap
import struct
import cv2
import os
import threading
import time
os.environ["OPENCV_VIDEOIO_MSMF_ENABLE_HW_TRANSFORMS"] = "0"

WIDTH = 640
HEIGHT = 480

EASY = '簡単'
NORMAL = '普通'
HARD = '難しい'
LEVEL = '難易度'
START = '開始'
YOUR_TURN = 'あなたのターン'
MEI_TURN = 'メイのターン'
MARKER = 'マーカー'

INVOKE = "カード発動"

ATTACK_CARD = '攻撃'
GUARD_CARD = '防御'
HEAL_CARD = '回復'
CHALLENGE = 'お題を表示します'

PUSH_UPS = "push_ups"
SQUATS = "squats"
CRUNCHES = "crunches"

SUCCESS = "成功"
FAILURE = "失敗"

CHECK_WIN = "ダメージ計算"

WIN = "勝ち"
LOSE = "負け"
CONTINUE = "続行"


class mmd():
    def __init__(self):
        self.mm: mmap.mmap = mmap.mmap(-1, 0x400, "Share_MMD_Camera")
    ### この部分はMMDAgentとの通信部分です．触らないでください###

    def recv_message(self):
        len = self.mm.find(b'\x00', 0x00, 0xff)
        str = ''
        if len != 0:
            self.mm.seek(0x0)
            line = self.mm.read(len)
            try:
                str = line.decode()
            except UnicodeDecodeError:
                print("Decode Error")
            self.mm.seek(0x0)
            self.mm.write(b'\x00')
        return str

    def send_message(self, send):
        self.mm.seek(0x200)
        self.mm.write(struct.pack('512s', send))
    ### ここまではMMDAgentとの通信部分です．触らないでください###


class status:
    def __init__(self, hp, ap):
        self.hp = hp
        self.ap = ap


class Card:
    def __init__(self, name, ctype, value, bonusValue=0):
        self.id = 0
        self.name = name
        self.type = ctype
        self.value = value
        self.bonusValue = bonusValue
        self.used = False

    def set_used(self, used: bool):
        self.used = used


class GameDebug():
    def __init__(self):
        self.count = 0
        self.difficulty = EASY
        self._mei = status(100, 0)
        self._player = status(100, 0)
        self.is_cleared = False
        self.cap: cv2.VideoCapture = cv2.VideoCapture(0)
        self.cards: list[Card] = []
        self.active_card: Card = None
        self._lock = threading.Lock()
        self.give_up_challenge = False
        self.load_cards()

    def load_cards(self):
        df = pd.read_csv('code\\card.csv')
        for idx, row in df.iterrows():
            bval = row['bonusValue'] if 'bonusValue' in row else 0
            self.cards.append(
                Card(row['name'], row['type'], row['value'], bval))
            self.cards[idx].id = idx

    @property
    def mei(self):
        with self._lock:
            return self._mei

    @mei.setter
    def mei(self, value):
        with self._lock:
            self._mei = value

    @property
    def player(self):
        with self._lock:
            return self._player

    @player.setter
    def player(self, value):
        with self._lock:
            self._player = value

    def handle_message(self, message):
        if EASY in message:
            self.difficulty = EASY
        elif NORMAL in message:
            self.difficulty = NORMAL
        elif HARD in message:
            self.difficulty = HARD
        elif YOUR_TURN in message:
            self.player_turn()
        elif MEI_TURN in message:
            self.mei_turn()
        elif CHALLENGE in message:
            self.challenge()
        elif START in message:
            self.battle()
        elif MARKER in message:
            self.select_card()
        elif INVOKE in message:
            self.invoke_card()
        # ...additional message handling...

    def player_turn(self):
        print("player turn")
        self.wait(1)
        mmd().send_message(MARKER.encode())

    def select_card(self):
        # あとでarucoを使ってカードを選択するようにする
        self.wait(3)
        self.active_card = np.random.choice(self.cards)
        self.active_card.set_used(True)
        print(f"selected card: {self.active_card.name}")

    def invoke_card(self):
        print("invoke card")
        if self.active_card.type == ATTACK_CARD:
            self.mei.hp -= self.active_card.value
            mmd().send_message(ATTACK_CARD.encode())
        elif self.active_card.type == GUARD_CARD:
            self.mei.ap += self.active_card.value
            mmd().send_message(GUARD_CARD.encode())
        elif self.active_card.type == HEAL_CARD:
            self.player.hp += self.active_card.value
            mmd().send_message(HEAL_CARD.encode())

    def check_win(self):
        print("check win")
        if self.mei.hp <= 0:
            print("プレイヤーの勝利")
            mmd().send_message(WIN.encode())
        elif self.player.hp <= 0:
            print("メイの勝利")
            mmd().send_message(LOSE.encode())
        else:
            print("続行")
            mmd().send_message(CONTINUE.encode())

    def mei_turn(self):
        # Logic for Mei's turn
        pass

    def exercise_challenge(self, mode):
        recognizer = exercise.ExerciseRecognizer()
        while True:
            ret, frame = self.cap.read()
            # 何故か認識部分だけ重い 謎
            frame = recognizer.recognize_exercise(frame, mode)
            cv2.imshow('exercise', frame)

            if cv2.waitKey(10) & 0xFF == ord('q'):
                break

            if self.give_up_challenge:
                break

            if mode == 'push_ups' and recognizer.push_up_count == 10:
                self.is_cleared = True
                break
            elif mode == 'squats' and recognizer.squat_count == 10:
                self.is_cleared = True
                break
            elif mode == 'crunches' and recognizer.crunch_count == 10:
                self.is_cleared = True
                break

        cv2.destroyWindow('exercise')
        return self.is_cleared

    def challenge(self):
        print("challenge")
        mode = np.random.choice([PUSH_UPS, SQUATS, CRUNCHES])
        self.wait(3)
        mmd().send_message(mode.encode())
        self.exercise_challenge(mode)
        if self.is_cleared:
            print("成功！")
            mmd().send_message(SUCCESS.encode())
        else:
            print("失敗！")
            mmd().send_message(FAILURE.encode())

        # ここでバフとかデバフとか処理する

    def battle(self):
        # Logic for battle
        pass

    def message_listener(self):
        mmd_agent = mmd()
        while True:
            message = mmd_agent.recv_message()
            if message:
                print(message)
                self.handle_message(message)

    def run(self):
        listener_thread = threading.Thread(target=self.message_listener)
        listener_thread.daemon = True
        listener_thread.start()
        # Main game loop
        while True:
            pass

    def wait(self, wait):
        print(f"waiting for {wait} seconds")
        time.sleep(wait)
        return


if __name__ == "__main__":
    game = GameDebug()
    game.run()
