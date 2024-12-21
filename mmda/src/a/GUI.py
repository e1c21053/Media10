import tkinter as tk
from tkinter import messagebox
from tool import FSTGenerator

# Define lists of fst commands
CONDITION_COMMANDS = [
    "<eps>",
    
    # ...other event commands...
]

EXECUSE_COMMANDS = [
    "MODEL_ADD|"
]

class FSTGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("FST Generator GUI")
        self.fst = FSTGenerator()

        # ノード追加セクション
        tk.Label(root, text="状態").grid(row=0, column=0)
        self.state_entry = tk.Entry(root)
        self.state_entry.grid(row=0, column=1)

        tk.Label(root, text="イベント").grid(row=1, column=0)
        self.event_var = tk.StringVar()
        self.event_var.set(CONDITION_COMMANDS[0])
        self.event_menu = tk.OptionMenu(root, self.event_var, *CONDITION_COMMANDS)
        self.event_menu.grid(row=1, column=1)

        tk.Label(root, text="アクション").grid(row=2, column=0)
        self.action_var = tk.StringVar()
        self.action_var.set(EXECUSE_COMMANDS[0])
        self.action_menu = tk.OptionMenu(root, self.action_var, *EXECUSE_COMMANDS)
        self.action_menu.grid(row=2, column=1)

        tk.Button(root, text="ノード追加", command=self.add_node).grid(row=3, column=0, columnspan=2)

        # トランジション追加セクション
        tk.Label(root, text="開始状態").grid(row=4, column=0)
        self.from_state_entry = tk.Entry(root)
        self.from_state_entry.grid(row=4, column=1)

        tk.Label(root, text="終了状態").grid(row=5, column=0)
        self.to_state_entry = tk.Entry(root)
        self.to_state_entry.grid(row=5, column=1)

        tk.Button(root, text="トランジション追加", command=self.add_transition).grid(row=6, column=0, columnspan=2)

        # ノード表示
        tk.Label(root, text="ノード一覧").grid(row=0, column=2)
        self.node_list = tk.Listbox(root, height=10, width=50)
        self.node_list.grid(row=1, column=2, rowspan=3)

        # トランジション表示
        tk.Label(root, text="トランジション一覧").grid(row=4, column=2)
        self.transition_list = tk.Listbox(root, height=10, width=50)
        self.transition_list.grid(row=5, column=2, rowspan=2)

        # 保存ボタン
        tk.Button(root, text=".fstファイル保存", command=self.save_fst).grid(row=7, column=0, columnspan=3)

    def add_node(self):
        state = self.state_entry.get()
        event = self.event_var.get()
        action = self.action_var.get()
        if state and event and action:
            self.fst.add_node(state, event, action)
            self.node_list.insert(tk.END, f"状態: {state}, イベント: {event}, アクション: {action}")
            self.state_entry.delete(0, tk.END)
        else:
            messagebox.showwarning("入力エラー", "すべてのフィールドを入力してください。")

    def add_transition(self):
        from_state = self.from_state_entry.get()
        to_state = self.to_state_entry.get()
        if from_state and to_state:
            self.fst.add_transition(from_state, to_state)
            self.transition_list.insert(tk.END, f"{from_state} -> {to_state}")
            self.from_state_entry.delete(0, tk.END)
            self.to_state_entry.delete(0, tk.END)
        else:
            messagebox.showwarning("入力エラー", "開始状態と終了状態を入力してください。")

    def save_fst(self):
        fst_content = self.fst.generate_fst()
        try:
            with open("output.fst", "w", encoding="utf-8") as file:
                file.write(fst_content)
            messagebox.showinfo("成功", ".fstファイルが保存されました。")
        except Exception as e:
            messagebox.showerror("保存エラー", f"ファイルの保存に失敗しました。\n{e}")

if __name__ == "__main__":
    root = tk.Tk()
    app = FSTGUI(root)
    root.mainloop()