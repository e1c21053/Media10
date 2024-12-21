from src.Game.card import Card


class PlayerBase:
    def __init__(self):
        self.name = None
        self.cards: list[Card] = []
        self.active_card: Card = None
        self.is_win = False


class Player(PlayerBase):
    def __init__(self):
        super().__init__()


class Agent(PlayerBase):
    def __init__(self):
        super().__init__()
