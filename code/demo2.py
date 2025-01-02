from recognizer import color, exercise
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
import json
from PIL import Image, ImageDraw, ImageFont

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

ERROR = 'ERROR'
USED = 'used'


ATTACK_CARD = 'atk'
GUARD_CARD = 'def'
HEAL_CARD = 'heal'
BUFF_CARD = 'buff'
DRAW_CARD = 'draw'

card_types = [ATTACK_CARD,  GUARD_CARD, HEAL_CARD, BUFF_CARD]

CHALLENGE = 'お題を表示します。'
PICK_CHALLENGE = 'それではお題を抽選します。'
CLEA_CHALLENGE = '正解です。'

RED = 'red'
GREEN = 'green'
BLUE = 'blue'

PUSH_UPS = "push_ups"
SQUATS = "squats"
CRUNCHES = "crunches"

QUIZ = "quiz"

# quiz enum
quiz_enum = {
    "９匹のトラが乗ってそうな乗り物は？": "トラック",
    "お財布の中に隠れている動物は?": "サイ",
    "これenumに追加して林に木を一本追加したら何になる？": "森",
    "29回焼いて食べるものは？": "焼肉",
    "選ばないといけなそうな家事は？": "洗濯",
    "はがきを食べるのが好きな赤いものは？": "ポスト",
    "半分にすると０になる数字は？": "８(はち)",
    "目をフライパンで焼いた食べ物は？": "目玉焼き",
    "有るのに無い果物は？": "梨(ナシ)",
    "空に打ち上げられる花は？": "花火(はなび)",
    "野菜のカブを10個も食べそうな虫は？": "カブトムシ",
    "「とけい」は何時？": "三字(さんじ)",
    "川でウソをつく動物は？": "カワウソ",
    "「そうめん」と言うと負けるゲームは？": "しりとり"
}

SUCCESS = "成功"
FAILURE = "失敗"
GIVE_UP = "ギブアップします。"

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


class MMD:
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


class Status:
    def __init__(self, hp, ap):
        self.hp = hp
        self.ap = ap
        self.gp = 0
        self.is_invincible = False

    def __str__(self):
        return f"HP: {self.hp}, AP: {self.ap}"


BONUS_TYPE_MUTIPLY_COUNT = "mulcount"
BONUS_TYPE_VALUE = "value"
BONUS_TYPE_RANDOM = "random"
BONUS_TYPE_INCINCIBLE = "invincible"
BONUS_TYPE_FULLRECOVERY = "fullrecovery"
BONUS_TYPE_INVOKE = "invoke"


def _ramdom_card_type():
    return np.random.choice(card_types)


class Card:
    def __init__(
        self,
        id=0,
        name="",
        type="atk",
        value=0,
        value_range=None,
        bonus_value=0,
        bonus_value_range=None,
        bonus_type=None,
        debuff_type=None,
        debuff_value=0,
        debuff_value_range=None,
        fixed_challenge=None,
        path="",
        used=False
    ):
        self.id = id
        self.name = name
        self.type = type if type != "random" else _ramdom_card_type()
        self._value = value
        self._value_range = value_range
        self._bonus_value = bonus_value
        self._bonus_value_range = bonus_value_range
        self.bonus_type = bonus_type
        self.debuff_type = debuff_type
        self._debuff_value = debuff_value
        self._debuff_value_range = debuff_value_range
        self.fixed_challenge = fixed_challenge
        self.path = path
        self.used = used

    @property
    def value(self):
        return self._value if self._value_range is None else np.random.randint(*self._value_range)

    @property
    def bonus_value(self):
        return self._bonus_value if self._bonus_value_range is None else np.random.randint(*self._bonus_value_range)

    @property
    def debuff_value(self):
        return self._debuff_value if self._debuff_value_range is None else np.random.randint(*self._debuff_value_range)

    def set_used(self, used):
        self.used = used

    def get_image(self):
        path = self.path
        if os.path.exists(path):
            # Load image with alpha channel if present
            image = cv2.imread(path, cv2.IMREAD_UNCHANGED)
            if image is None:
                print(f"Failed to load image at {path}")
                return None
            if image.shape[2] == 4:
                # Convert BGRA to BGR
                image = cv2.cvtColor(image, cv2.COLOR_BGRA2BGR)
                print(f"Converted image with alpha channel to BGR for {path}")
            else:
                print(f"Loaded image in BGR format from {path}")
            return self.resize_image_preserve_aspect(image, 200, 200)
        print(f"Image not found at path: {path}")
        return None

    def resize_image_preserve_aspect(self, image, max_width, max_height):
        h, w = image.shape[:2]
        ratio = min(max_width / w, max_height / h)
        new_w = int(w * ratio)
        new_h = int(h * ratio)
        if image.shape[2] == 3:  # add alpha channel if needed
            image = cv2.cvtColor(image, cv2.COLOR_BGR2BGRA)
        resized = cv2.resize(image, (new_w, new_h),
                             interpolation=cv2.INTER_AREA)
        bg = np.zeros((max_height, max_width, 4), dtype=np.uint8)
        yoff = (max_height - new_h) // 2
        xoff = (max_width - new_w) // 2
        bg[yoff:yoff+new_h, xoff:xoff+new_w] = resized
        return bg


class GameDebug:
    def __init__(self):
        self.count = 0
        self.difficulty = EASY
        self._mei = Status(100, 0)
        self._player = Status(100, 0)
        self.mode = None
        self.is_cleared = False
        self.cap: cv2.VideoCapture = cv2.VideoCapture(0)
        self.cards: list[Card] = []
        self.active_card: Card = None
        self._lock = threading.Lock()
        self.give_up_challenge = False
        self.meg_cache = ""
        self.load_cards()

    def load_cards(self):
        with open('code/card.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        for card_data in data['cards']:
            print(card_data)
            card = Card(**card_data)
            card.id = card_data['id']
            self.cards.append(card)

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

    def update_window_area(self):
        # ウィンドウ自動調整
        try:
            import win32gui
            import win32con
            mmda_hwnd = win32gui.FindWindow(
                None, 'MMDAgent - Toolkit for building voice interaction systems')
            if mmda_hwnd:
                mmda_rect = win32gui.GetWindowRect(mmda_hwnd)
                mmda_x, mmda_y, mmda_right, mmda_bottom = mmda_rect
                mmda_width = mmda_right - mmda_x
                offset = 10
                window_width = 400
                window_height = 150
                windows = ['Status', 'quiz', 'color', 'exercise', 'card', 'QR']
                for i, window_name in enumerate(windows):
                    hwnd = win32gui.FindWindow(None, window_name)
                    if hwnd:
                        win32gui.SetWindowPos(
                            hwnd,
                            win32con.HWND_TOP,
                            mmda_x + mmda_width + offset +
                            (i * (window_width + offset)),
                            mmda_y,
                            window_width,
                            window_height,
                            0
                        )
            else:
                windows = ['Status', 'quiz', 'color', 'exercise', 'card', 'QR']
                for i, window_name in enumerate(windows):
                    hwnd = win32gui.FindWindow(None, window_name)
                    if hwnd:
                        win32gui.SetWindowPos(
                            hwnd,
                            win32con.HWND_TOP,
                            0 + (i * 410),
                            0,
                            400,
                            150,
                            0
                        )
        except ImportError:
            print("win32gui not available")

    def handle_message(self, message):
        self.meg_cache = message
        self.update_window_area()
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
        elif GIVE_UP in message:
            self.give_up_challenge = True
        elif "カードを読み込みました。" in message:
            print("card loaded")
            print(self.active_card.type)
        elif INVOKE in message:
            self.invoke_card()
        elif CHECK_WIN in message:
            self.check_win()

    def draw_text(self, img, text, pos=(10, 30), font_path=r"code\NotoSerifJP[wght].ttf", font_size=24):
        # Convert to PIL Image
        pil_img = Image.fromarray(img)
        draw = ImageDraw.Draw(pil_img)
        font = ImageFont.truetype(font_path, font_size)
        draw.text(pos, text, font=font, fill=(255, 255, 255))
        return np.array(pil_img)

    def draw_hp_bar(self, img, hp, max_hp=100, pos=(10, 40), size=(200, 10), color=(0, 255, 0)):
        pil_img = Image.fromarray(img)
        draw = ImageDraw.Draw(pil_img)
        bar_length = int(size[0] * (hp / max_hp))
        # background
        draw.rectangle(
            [pos, (pos[0] + size[0], pos[1] + size[1])], fill=(50, 50, 50))
        # HP portion
        draw.rectangle(
            [pos, (pos[0] + bar_length, pos[1] + size[1])], fill=color)
        return np.array(pil_img)

    def show_player_status(self):
        status_img = np.zeros((720, 500, 3), dtype=np.uint8)

        status_img = self.draw_text(status_img, "プレイヤー", (10, 10))

        status_img = self.draw_hp_bar(status_img, self.player.hp)

        status_img = self.draw_text(
            status_img, f"こうげき:{self.player.ap}", (10, 60))
        status_img = self.draw_text(
            status_img, f"ぼうぎょ:{self.player.gp}", (10, 90))

        status_img = self.draw_text(status_img, "メイ", (10, 110))

        status_img = self.draw_hp_bar(status_img, self.mei.hp, pos=(10, 140))

        status_img = self.draw_text(
            status_img, f"こうげき:{self.mei.ap}", (10, 160))
        status_img = self.draw_text(
            status_img, f"ぼうぎょ:{self.mei.gp}", (10, 190))
        cv2.imshow('Status', status_img)
        cv2.waitKey(1)

    def delete_status(self):
        try:
            cv2.destroyWindow('Status')
        except:
            pass

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
        self.show_player_status()
        self.select_card()
        self.wait(2)
        MMD().send_message(MARKER.encode())
        self.wait(4)
        MMD().send_message(self.active_card.type.encode())

    def player_attack(self):
        print("player attack")
        self.wait(1)

    def select_card(self):
        print("select card")
        self.wait(3)
        dict, parameters = self.get_aruco_dict_and_params()
        while not self.active_card:
            ret, frame = self.cap.read()
            corners, ids, _ = aruco.detectMarkers(
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
                            MMD().send_message(USED.encode())
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
        card_img = self.active_card.get_image()
        if card_img is not None:
            print(
                f"Displaying card image for {self.active_card.name} with shape {card_img.shape}")
            cv2.imshow('card', card_img)
            cv2.waitKey(1)
            self.update_window_area()
            if card_img.size == 0:
                print("Loaded card image is empty.")
        else:
            print("No image to display for the selected card.")
        print(f"selected card: {self.active_card.name}")

    def get_aruco_dict_and_params(self):
        if version.parse(cv2.__version__) < version.parse('4.7.0'):
            dict = aruco.Dictionary_get(aruco.DICT_6X6_100)
            parameters = aruco.DetectorParameters_create()
        else:
            dict = aruco.getPredefinedDictionary(aruco.DICT_6X6_100)
            parameters = aruco.DetectorParameters()
        return dict, parameters

    def invoke_card(self):
        print("invoke card")
        self.wait(3)
        print(
            f"active card: {self.active_card.name}, type: {self.active_card.type}, value: {self.active_card.value}, bonus: {self.active_card.bonus_value}")

        card_type = self.active_card.type
        base_val = 0
        if card_type == ATTACK_CARD:
            base_val = self.player.ap + self.active_card.value
            mmd_msg = ATTACK_CARD
        elif card_type == GUARD_CARD:
            base_val = self.player.gp + self.active_card.value
            mmd_msg = GUARD_CARD
        elif card_type == HEAL_CARD:
            base_val = self.player.hp + self.active_card.value
            mmd_msg = HEAL_CARD
        elif card_type == BUFF_CARD:
            base_val = self.player.ap + self.active_card.value
            mmd_msg = BUFF_CARD
        elif card_type == DRAW_CARD:
            print("draw card")
            self.active_card = None
            self.is_cleared = False
        else:
            print("Invalid card type")
            self.active_card = None
            self.is_cleared = False
            return

        # apply bonus if cleared
        if self.is_cleared and self.active_card.bonus_type:
            if self.active_card.bonus_type == BONUS_TYPE_MUTIPLY_COUNT:
                base_val += self.active_card.bonus_value * self.count
            elif self.active_card.bonus_type == BONUS_TYPE_VALUE:
                base_val = self.active_card.bonus_value
            elif self.active_card.bonus_type == BONUS_TYPE_RANDOM:
                base_val += np.random.randint(0,
                                              self.active_card.bonus_value + 1)
            elif self.active_card.bonus_type == BONUS_TYPE_FULLRECOVERY:
                self.player.hp = 100
                print("Full recovery bonus")
            elif self.active_card.bonus_type == BONUS_TYPE_INCINCIBLE:
                self.player.is_invincible = True
                print("Invincible guard")

        # apply effect
        if card_type == ATTACK_CARD:
            self.mei.hp = max(self.mei.hp - base_val, 0)
        elif card_type == GUARD_CARD:
            self.player.gp = max(base_val, 0)
        elif card_type == HEAL_CARD:
            self.player.hp = min(base_val, 100)
        elif card_type == BUFF_CARD:
            self.player.ap = base_val
        elif card_type == DRAW_CARD:
            # TODO ここでbase_val毎引くことをsend_messageで通知する
            pass

        # apply debuff
        if self.active_card.debuff_type == "harm":
            self.player.hp = max(
                self.player.hp - self.active_card.debuff_value, 0)
        elif self.active_card.debuff_type == "randomharm":
            # meiかplayerのどちらかにランダムでダメージを与える
            target = np.random.choice([self.mei, self.player])
            target.hp = max(target.hp - self.active_card.debuff_value, 0)
        MMD().send_message(mmd_msg.encode())
        self.show_player_status()
        self.active_card = None
        self.is_cleared = False
        try:
            cv2.destroyWindow('card')
        except:
            pass

    def check_win(self):
        print("check win")
        print(f"player : {self.player}, mei : {self.mei}")
        self.wait(3)
        if self.mei.hp <= 0:
            print("プレイヤーの勝利")
            MMD().send_message(WIN.encode())
            self.delete_status()
        elif self.player.hp <= 0:
            print("メイの勝利")
            MMD().send_message(LOSE.encode())
            self.delete_status()
        else:
            print("続行")
            MMD().send_message(CONTINUE.encode())
        self.mode = None
        self.player.is_invincible = False

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

    def is_exercise_cleared(self, recognizer: exercise.ExerciseRecognizer):
        return (self.mode == 'push_ups' and recognizer.push_up_count == 10) or \
               (self.mode == 'squats' and recognizer.squat_count == 10) or \
               (self.mode == 'crunches' and recognizer.crunch_count == 10)

    def exercise_challenge(self):
        recognizer = exercise.ExerciseRecognizer()
        while True:
            ret, frame = self.cap.read()
            frame = recognizer.recognize_exercise(frame, self.mode)
            cv2.imshow('exercise', frame)
            if cv2.waitKey(10) & 0xFF == ord('q') or self.give_up_challenge:
                break
            if self.is_exercise_cleared(recognizer):
                self.is_cleared = True
                break
        cv2.destroyWindow('exercise')
        self.count = recognizer.push_up_count if self.mode == 'push_ups' else recognizer.squat_count if self.mode == 'squats' else recognizer.crunch_count

    def color_challenge(self):
        recognizer = color.ColorRecognizer()
        init_frame_color = None
        previous_detected = None
        start_time = None
        while True:
            ret, frame = self.cap.read()
            if not ret:
                break
            if init_frame_color is None:
                init_frame_color = recognizer.recognize_color(frame)
                col = np.random.choice(
                    [c for c in [RED, GREEN, BLUE] if c != init_frame_color])
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
            cv2.imshow('color', frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        try:
            cv2.destroyWindow('color')
        except:
            pass

    def quiz_challenge(self):
        quiz = np.random.choice(list(quiz_enum.keys()))
        MMD().send_message(QUIZ.encode())
        print(quiz)
        while True:
            ret, frame = self.cap.read()
            frame = self.draw_text(frame, quiz, (10, 30))
            cv2.imshow('quiz', frame)
            if cv2.waitKey(10) & 0xFF == ord('q') or self.give_up_challenge:
                break
            if self.is_cleared:
                break
        try:
            cv2.destroyWindow('quiz')
        except:
            pass

    def determine_challenge_mode(self):
        mode = self.active_card.fixed_challenge
        if mode == "color":
            mode = np.random.choice([RED, GREEN, BLUE])
        elif mode == "exercise":
            mode = np.random.choice([PUSH_UPS, SQUATS, CRUNCHES])
        elif mode == "quiz":
            mode = QUIZ
        return mode

    def pick_challenge(self):
        print("pick challenge")
        self.wait(1)
        mode = self.determine_challenge_mode()
        self.wait(1)
        MMD().send_message(mode.encode())
        print(f"challenge: {mode}")
        self.mode = mode

    def challenge(self):
        print("challenge")
        if self.mode in [RED, GREEN, BLUE]:
            self.color_challenge()
        elif self.mode in [PUSH_UPS, SQUATS, CRUNCHES]:
            self.exercise_challenge()
        elif self.mode == QUIZ:
            self.quiz_challenge()
        if self.is_cleared:
            print("成功！")
            MMD().send_message(SUCCESS.encode())
        else:
            print("失敗！")
            MMD().send_message(FAILURE.encode())
        self.update_status_after_challenge()
        self.give_up_challenge = False
        self.wait(1)

    def update_status_after_challenge(self):
        ac = self.active_card
        if ac.type == ATTACK_CARD:
            self.mei.hp = max(self.mei.hp - ac.value, 0)
        elif ac.type == GUARD_CARD:
            self.player.gp = max(self.player.gp + ac.value, 0)
        elif ac.type == HEAL_CARD:
            self.player.hp = min(self.player.hp + ac.value, 100)
        elif ac.type == BUFF_CARD:
            self.player.ap += ac.bonus_value
        else:
            print("Invalid card type")

    def message_listener(self):
        mmd_agent = MMD()
        while True:
            message = mmd_agent.recv_message()
            if message:
                print(message)
                self.handle_message(message)

    def run(self):
        listener_thread = threading.Thread(target=self.message_listener)
        listener_thread.daemon = True
        listener_thread.start()
        while not self.end_game():
            ret, frame = self.cap.read()
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

    def wait(self, wait):
        print(f"waiting for {wait} seconds")
        time.sleep(wait)


if __name__ == "__main__":
    game = GameDebug()
    game.run()
