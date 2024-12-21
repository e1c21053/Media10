from .player import Player, Agent
import cv2
import mmap
import os
import struct
os.environ["OPENCV_VIDEOIO_MSMF_ENABLE_HW_TRANSFORMS"] = "0"

WIDTH = 640
HEIGHT = 480

class Game:
    def __init__(self, player: Player, agent: Agent):
        self.player = player
        self.agent = agent
        self.turn = 0
        self.mm : mmap.mmap = mmap.mmap(-1, 0x400, "Share_MMD_Camera")

    def init(self):
        pass

    def run(self):
        pass

    def winner(self):
        # active_cardを比較して勝者を返す
        pass

    ###この部分はMMDAgentとの通信部分です．触らないでください###
    def recv_message(self):
        len = self.mm.find(b'\x00',0x00,0xff)
        str = ''
        if len !=0 :	
            self.mm.seek(0x0)
            line = self.mm.read(len)
            try:
                str = line.decode()
            except UnicodeDecodeError:
                print("Decode Error")
            self.mm.seek(0x0)
            self.mm.write(b'\x00')
        return str

    def send_message(self,send):
        self.mm.seek(0x200)
        self.mm.write(struct.pack('512s', send))
    ###ここまではMMDAgentとの通信部分です．触らないでください###

class GameMain:
    def __init__(self):
        self.game = Game(Player(), Agent())
        self.game.init()
        self.cap = cv2.VideoCapture(0)

    def run(self):
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, WIDTH)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, HEIGHT)

        while (self.cap.isOpened()):
            if self.game.recv_message() == "START_GAME":
                self.game.run()
