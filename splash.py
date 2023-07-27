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

def update():
    root.attributes('-fullscreen', True) 
    root.configure(bg="#6495ED")
    root.title("sysZ | updates")

    label = ttk.Label(root, text="Updates are underway", font=("Arial", 36), background=root['bg'])
    label.pack(pady=100)

    style = ttk.Style()
    style.configure("TProgressbar", thickness=80)
    progress_bar = ttk.Progressbar(root, style="TProgressbar", mode="indeterminate", length=600)
    progress_bar.pack(pady=50)

    root.after(100, lambda: progress_bar.start(10))

    try:
        root.after(100, execute_shell_script("~/sysZ/pull.sh", "automatic_update"))
        root.after(100, stop_loading)
    except Exception as e:
        print(f"An error occurred: {e}")
        error("pull script has failed")
        root.after(3000, stop_loading)




def error(issue):
    clear_tk_elements(root)
    label = ttk.Label(root, text="An error has occurred.", font=("Arial", 36), background=root['bg'], foreground="red")
    problem = ttk.Label(root, text="Check console for details", font=("Arial", 26), background=root['bg'], foreground="red")
    if issue:
        problem = ttk.Label(root, text=issue, font=("Arial", 26), background=root['bg'], foreground="red")
    else:
        problem = ttk.Label(root, text="Check console for details", font=("Arial", 26), background=root['bg'], foreground="red")
    label.pack(pady=100)
    problem.pack(pady=25)

def clear_tk_elements(root):
    for child in root.winfo_children():
        child.destroy()

def execute_shell_script(script_path, function_name=None):
    try:
        expanded_path = os.path.expanduser(script_path)
        command = ["sh", expanded_path]

        if function_name:
            command.extend(["--function", function_name])

        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing shell script: {e}")
        error()


if len(sys.argv) > 1 and sys.argv[1] == 'load':
    root = tk.Tk()
    load()
    try:
        execute_shell_script("~/sysZ/shell/setup.sh")
    except Exception as e:
        print(f"An error occurred: {e}")
        error("setup script has failed")
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'docs':
    root = tk.Tk()
    docs("sysZ | docs")
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'update':
    root = tk.Tk()
    update()
    root.mainloop()