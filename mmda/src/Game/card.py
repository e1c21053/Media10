class Card:
    """
    カードの基底クラス
    """

    def __init__(self):
        self.name = None
        self.power = 0
        self.hp = 0
        self.qr_tag = None
        self.is_valid = False
        self.buffs: list[Buff] = []

    def add_buff(self, buff):
        self.buffs.append(buff)

    def remove_buff(self, buff):
        if buff in self.buffs:
            self.buffs.remove(buff)

    def clear_buffs(self):
        self.buffs.clear()

    def get_apply_buffs(self):
        hp = (self.hp + sum([buff.hp_recovery for buff in self.buffs])) * \
            (1 + sum([buff.hp_recovery_percent for buff in self.buffs]))
        power = (self.power + sum([buff.power_up for buff in self.buffs])
                 ) * (1 + sum([buff.power_up_percent for buff in self.buffs]))
        return hp, power

class Buff:
    def __init__(self):
        self.power_up = 0
        self.power_up_percent = 0
        self.hp_recovery = 0
        self.hp_recovery_percent = 0
        self.duration = 0


class Card001(Card):
    # テスト用の仮カード
    def __init__(self):
        super().__init__()
