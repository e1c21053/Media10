from recognizer import color
from recognizer import exercise
from cv2 import aruco
from packaging import version
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
MEI_TURN = 'わたしのターン'
MARKER = 'marker'

INVOKE = "カードを発動します"

ATTACK_CARD = 'atk'

ERROR = 'ERROR'

USED = 'used'
GUARD_CARD = 'def'
HEAL_CARD = 'heal'
BUFF_CARD = 'buff'

CHALLENGE = 'お題を表示します。'
PICK_CHALLENGE = 'それではお題を抽選します。'

RED = 'red'
GREEN = 'green'
BLUE = 'blue'

PUSH_UPS = "push_ups"
SQUATS = "squats"
CRUNCHES = "crunches"

SUCCESS = "成功"
FAILURE = "失敗"

ACTION_ATTACK = "あなたの力をわたしに見せてください。"

CHECK_WIN = "ダメージ計算"

WIN = "勝ち"
LOSE = "負け"
CONTINUE = "続行"

mei_damage_table = {
    EASY: [(10, 0.5), (20, 0.3), (30, 0.2)],
    NORMAL: [(20, 0.5), (30, 0.3), (40, 0.2)],
    HARD: [(30, 0.5), (40, 0.3), (50, 0.2)]
}


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
                self.send_message(ERROR.encode())
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
        self.gp = 0

    def __str__(self):
        return f"HP: {self.hp}, AP: {self.ap}"


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

    def get_image(self):
        # pathはname_type_id.png
        path = f"code\\imgs\\{self.name}_{self.type}_{self.id}.png"
        return cv2.imread(path)

class GameDebug():
    def __init__(self):
        self.count = 0
        self.difficulty = EASY
        self._mei = status(100, 0)
        self._player = status(100, 0)
        self.mode = None
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
        elif PICK_CHALLENGE in message:
            self.pick_challenge()
        elif CHALLENGE in message:
            self.challenge()
        elif "カードを読み込みました。" in message:
            print("card loaded")
            print(self.active_card.type)
        elif INVOKE in message:
            self.invoke_card()
        elif CHECK_WIN in message:
            self.check_win()

    def end_game(self):
        if self.mei.hp <= 0:
            print("You win")
            return True
        elif self.player.hp <= 0:
            print("You lose")
            return True
        return False

    def player_turn(self):
        print("player turn")
        print(f"player : {self.player.__str__()}, mei : {self.mei.__str__()}")
        self.select_card()
        self.wait(2)
        mmd().send_message(MARKER.encode())
        self.wait(4)
        mmd().send_message(self.active_card.type.encode())

    def player_attack(self):
        print("player attack")
        self.wait(1)
        pass

    def select_card(self):
        print("select card")
        self.wait(3)
        dict = None
        parameters = None
        if version.parse(cv2.__version__) < version.parse('4.7.0'):
            # cv2のバージョンが古いとこっちを使う
            dict = aruco.Dictionary_get(aruco.DICT_6X6_100)
            parameters = aruco.DetectorParameters_create()
        else:
            dict = aruco.getPredefinedDictionary(aruco.DICT_6X6_100)
            parameters = aruco.DetectorParameters()
        while not self.active_card:
            ret, frame = self.cap.read()
            corners, ids, rejectedImgPoints = aruco.detectMarkers(
                frame, dict, parameters=parameters)
            frame = aruco.drawDetectedMarkers(frame, corners, ids)
            if ids is not None:
                print(ids)
                for i in range(len(ids)):
                    card_id = int(ids[i][0])
                    if card_id < len(self.cards):
                        if not self.cards[card_id].used:
                            self.active_card = self.cards[card_id]
                            break
                        else:
                            print("card already used")
                            mmd().send_message(USED.encode())
                    else:
                        print("invalid card")
            cv2.imshow('QR', frame)
            if cv2.waitKey(10) & 0xFF == ord('q'):
                break
        try:
            cv2.destroyWindow('QR')
        except:
            pass
        self.active_card.set_used(True)
        print(f"selected card: {self.active_card.name}")

    def invoke_card(self):
        print("invoke card")
        # ここでcv2を使ってカードの画像を表示する
        card_img = self.active_card.get_image()
        if card_img:
            cv2.imshow('card', card_img)
        self.wait(3)
        print(
            f"active card: {self.active_card.name}, type: {self.active_card.type}, value: {self.active_card.value}, bonus: {self.active_card.bonusValue}")

        if self.active_card.type == ATTACK_CARD:
            self.mei.hp -= self.player.ap + self.active_card.value
            print(f"attack: {self.player.ap + self.active_card.value}")
            mmd().send_message(ATTACK_CARD.encode())
        elif self.active_card.type == GUARD_CARD:
            self.player.gp += self.active_card.value if self.is_cleared else self.active_card.bonusValue
            print(f"guard: {self.active_card.value if self.is_cleared else self.active_card.bonusValue}")
            mmd().send_message(GUARD_CARD.encode())
        elif self.active_card.type == HEAL_CARD:
            self.player.hp += self.active_card.value if self.is_cleared else self.active_card.bonusValue
            print(f"heal: {self.active_card.value if self.is_cleared else self.active_card.bonusValue}")
            mmd().send_message(HEAL_CARD.encode())
        elif self.active_card.type == BUFF_CARD:
            self.player.ap += self.active_card.value if self.is_cleared else self.active_card.bonusValue
            print(f"buff: {self.active_card.value if self.is_cleared else self.active_card.bonusValue}")
            mmd().send_message(BUFF_CARD.encode())
        else:
            print("Invalid card type")
        self.active_card = None
        try:
            cv2.destroyWindow('card')
        except:
            pass

    def check_win(self):
        print("check win")
        print(f"player : {self.player.__str__()}, mei : {self.mei.__str__()}")
        self.wait(3)
        if self.mei.hp <= 0:
            print("プレイヤーの勝利")
            mmd().send_message(WIN.encode())
        elif self.player.hp <= 0:
            print("メイの勝利")
            mmd().send_message(LOSE.encode())
        else:
            print("続行")
            mmd().send_message(CONTINUE.encode())
        self.mode = None

    def mei_turn(self):
        def get_random_dmg(dmg_list: list[tuple[int, float]]) -> int:
            """
            list[tuple[int,float] int はダメージ量, float は確率を引数に取り，確率に応じてダメージ量を返す関数
            例: get_random_dmg([(10, 0.5), (20, 0.3), (30, 0.2)]) は, 10の確率0.5, 20の確率0.3, 30の確率0.2でダメージ量を返す
            """
            return np.random.choice([dmg[0] for dmg in dmg_list], p=[dmg[1] for dmg in dmg_list])
        self.wait(1)
        dmg = get_random_dmg(mei_damage_table[self.difficulty])
        self.player.hp -= dmg + self.player.gp
        print(f"メイの攻撃: {dmg}のダメージ")

    def exercise_challenge(self):
        recognizer = exercise.ExerciseRecognizer()
        while True:
            ret, frame = self.cap.read()
            frame = recognizer.recognize_exercise(frame, self.mode)
            cv2.imshow('exercise', frame)

            if cv2.waitKey(10) & 0xFF == ord('q'):
                break

            if self.give_up_challenge:
                break

            if self.mode == 'push_ups' and recognizer.push_up_count == 10:
                self.is_cleared = True
                break
            elif self.mode == 'squats' and recognizer.squat_count == 10:
                self.is_cleared = True
                break
            elif self.mode == 'crunches' and recognizer.crunch_count == 10:
                self.is_cleared = True
                break
        cv2.destroyWindow('exercise')

    def color_challenge(self):
        recognizer = color.ColorRecognizer()
        init_frame_color = None
        previous_detected = None
        while True:
            ret, frame = self.cap.read()
            if not ret:
                break
            if init_frame_color is None:
                init_frame_color = recognizer.recognize_color(frame)
                col = np.random.choice(
                    [color for color in [RED, GREEN, BLUE] if color != init_frame_color])
            is_detected = recognizer.recognize_specific_color(frame, col)
            if is_detected == previous_detected:
                if start_time is None:
                    start_time = time.time()
                elif time.time() - start_time > 5:
                    print(f"{col} recognized for more than 5 seconds.")
                    break
            else:
                start_time = None
                previous_detected = is_detected

            cv2.imshow('frame', frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        try:
            cv2.destroyWindow('color')
        except:
            pass

    def pick_challenge(self):
        print("pick challenge")
        self.wait(1)
        mode = np.random.choice([PUSH_UPS, SQUATS, CRUNCHES, RED, GREEN, BLUE])
        self.wait(1)
        mmd().send_message(mode.encode())
        print(f"challenge: {mode}")
        self.mode = mode

    def challenge(self):
        print("challenge")
        if self.mode in [RED, GREEN, BLUE]:
            self.color_challenge()
        else:
            self.exercise_challenge()
        if self.is_cleared:
            print("成功！")
            mmd().send_message(SUCCESS.encode())
        else:
            print("失敗！")
            mmd().send_message(FAILURE.encode())

        ac = self.active_card
        if ac.type == ATTACK_CARD:
            calc = self.mei.hp - ac.value
            self.mei.hp = calc if calc > 0 else 0
        elif ac.type == GUARD_CARD:
            calc = self.player.gp + ac.value
            self.player.gp = calc if calc > 0 else 0
        elif ac.type == HEAL_CARD:
            calc = self.player.hp + ac.value
            self.player.hp = calc if calc > 100 else 100
        elif ac.type == BUFF_CARD:
            self.player.ap += ac.bonusValue
        else:
            print("Invalid card type")

        self.wait(1)

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
        while not self.end_game():
            ret, frame = self.cap.read()
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

    def wait(self, wait):
        print(f"waiting for {wait} seconds")
        time.sleep(wait)
        return


if __name__ == "__main__":
    game = GameDebug()
    game.run()
