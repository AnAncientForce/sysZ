import tkinter as tk
from tkinter import ttk
import sys
import subprocess
import os

def stop_loading():
    root.destroy()

def load():
    root.attributes('-fullscreen', True) 
    root.configure(bg="#6495ED")
    root.title("sysZ | splash")

    label = ttk.Label(root, text="sysZ", font=("Arial", 36), background=root['bg'])
    label.pack(pady=100)

    style = ttk.Style()
    style.configure("TProgressbar", thickness=80)
    progress_bar = ttk.Progressbar(root, style="TProgressbar", mode="indeterminate", length=600)
    progress_bar.pack(pady=50)

    root.after(100, lambda: progress_bar.start(10))
    root.after(3000, stop_loading)

def docs(par):
    root.attributes('-fullscreen', True) 
    root.configure(bg="#6495ED")
    root.title(par)

    label = ttk.Label(root, text=par, font=("Arial", 36), background=root['bg'])
    label.pack(pady=20)
    
    with open("docs.txt", "r") as file:
        text_content = file.read()

    text_box = tk.Text(root, font=("Arial", 16), bg=root["bg"])
    text_box.insert("1.0", text_content)
    text_box.pack(pady=20)

    close_button = ttk.Button(root, text="Close", command=stop_loading)
    close_button.pack(pady=10)



def execute_shell_script(script_path):
    try:
        expanded_path = os.path.expanduser(script_path)  # Expand the ~ in the path
        subprocess.run(["sh", expanded_path], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing shell script: {e}")


if len(sys.argv) > 1 and sys.argv[1] == 'load':
    root = tk.Tk()
    load()
    execute_shell_script("~/shell/setup.sh")
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'docs':
    root = tk.Tk()
    docs("sysZ | docs")
    root.mainloop()