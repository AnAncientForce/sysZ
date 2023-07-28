import tkinter as tk
from tkinter import ttk
import sys
import subprocess
import os
import json
from subprocess import call

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

    setup()

    root.after(100, lambda: progress_bar.start(10))
    root.after(3000, stop_loading)


def docs(par):
    clear_tk_elements(root)
    root.attributes('-fullscreen', True) 
    root.configure(bg="#6495ED")
    root.title(par)

    label = ttk.Label(root, text=par, font=("Arial", 36), background=root['bg'])
    label.pack(pady=20)
    
    with open("docs.txt", "r") as file:
        text_content = file.read()

    text_box = tk.Text(root, font=("Arial", 16), bg=root["bg"])
    text_box.insert("1.0", text_content)
    text_box.pack(pady=5)

    close_button = ttk.Button(root, text="Close", command=stop_loading)
    close_button.pack(pady=10)

def update():
    clear_tk_elements(root)
    # subprocess.run(["sh", "shell/non_sudo_update.sh"])
    subprocess.run(["sh", os.path.expanduser("~/sysZ/shell/non_sudo_update.sh")])

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
    root.after(3000, stop_loading)



def setup():
    if check_value_from_json('use_animations'):
        print("Animations are enabled.")
        # subprocess.run("i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'", shell=True)
    else:
        print("Animations are disabled.")
        run_shell_script_function(os.path.expanduser("~/sysZ/main.sh"), "picom_without_animations")
        # call("picom -b --blur-background --corner-radius 4 --vsync", shell=True)
        # subprocess.run(["i3-msg", "exec", "picom", "-b", "--blur-background", "--corner-radius", "4", "--vsync"])
    
    subprocess.Popen(["sh", os.path.expanduser("~/sysZ/shell/setup.sh")])


def run_shell_script_function(shell_script_path, function_name):
    subprocess.run(["sh", "-c", f"{shell_script_path} {function_name}"])

def check_value_from_json(key):
    with open('config.json', 'r') as file:
        data = json.load(file)
        if key in data:
            return data[key]
        else:
            return False

def control():
    clear_tk_elements(root)
    # root.attributes('-fullscreen', True) 
    root.configure(bg="#6495ED")
    root.title("sysZ | control")

    label = ttk.Label(root, text="sysZ | Control Panel", font=("Arial", 36), background=root['bg'])
    label.pack(pady=100)

    # --- SETTINGS

    # Function to update the config file
    def update_config():
        with open('config.json', 'w') as configfile:
            config['use_animations'] = use_animations.get()
            config['splashEnabled'] = splash_enabled.get()
            json.dump(config, configfile)

    # Function to execute specific code based on the config value
    def execute_code():
        if config['use_animations']:
            print("Animations enabled")
            
        else:
            print("Animations disabled")
            

    # Create the tkinter window
    # root = tk.Tk()

    # Read the configuration file
    with open('config.json', 'r') as configfile:
        config = json.load(configfile)

    # Create a checkbox button for using animations
    use_animations = tk.BooleanVar(value=config.get('use_animations', False))
    checkbox = tk.Checkbutton(root, text="Use animations", variable=use_animations, command=update_config)
    checkbox.pack(pady=10)

    # Create a checkbox button for enabling splash
    splash_enabled = tk.BooleanVar(value=config.get('splashEnabled', False))
    checkbox_splash = tk.Checkbutton(root, text="Enable Splash", variable=splash_enabled, command=update_config)
    checkbox_splash.pack(pady=10)

    # Create a button to execute code based on the config value
    execute_button = tk.Button(root, text="Execute Code", command=execute_code)
    execute_button.pack(pady=10)

    # Run the tkinter event loop
    # root.mainloop()

    # --- SETTING END

    terminal_button = ttk.Button(root, text="Open Terminal", command=lambda: subprocess.Popen(["alacritty", "&"], shell=True))
    terminal_button.pack(pady=10)

    appearance_button = ttk.Button(root, text="Change Appearance", command=lambda: os.system("qt5ct & lxappearance &"))
    appearance_button.pack(pady=10)

    cw_button = ttk.Button(root, text="Change Wallpaper", command=lambda: subprocess.Popen(["sh", os.path.expanduser("~/sysZ/shell/cw.sh")]))
    cw_button.pack(pady=10)

    update_button = ttk.Button(root, text="Update [sysZ]", command=update)
    update_button.pack(pady=10)

    #automatic_setup_button = ttk.Button(root, text="Run Setup Wizard [sysZ]", command=lambda: subprocess.Popen(["sudo", "sh", "/sysZ/shell/setup_wizard.sh"]))
    #automatic_setup_button.pack(pady=10)

    logout_button = ttk.Button(root, text="Logout", command=lambda: subprocess.Popen(["i3-msg", "exit"]))
    logout_button.pack(pady=10)

    restart_button = ttk.Button(root, text="Restart", command=lambda: subprocess.Popen(["systemctl", "reboot"]))
    restart_button.pack(pady=10)

    shutdown_button = ttk.Button(root, text="Shutdown", command=lambda: subprocess.Popen(["systemctl", "poweroff"]))
    shutdown_button.pack(pady=10)

    close_button = ttk.Button(root, text="Close", command=stop_loading)
    close_button.pack(pady=10)


def home():
    root.configure(bg="#6495ED")
    root.title("sysZ | home")

    label = ttk.Label(root, text="sysZ | Home", font=("Arial", 36), background=root['bg'])
    label.pack(pady=100)

    control_button = ttk.Button(root, text="Control Panel", command=control)
    control_button.pack(pady=10)

    close_button = ttk.Button(root, text="Close", command=stop_loading)
    close_button.pack(pady=10)




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

def execute_shell_script(script_path):
    try:
        expanded_path = os.path.expanduser(script_path)  # Expand the ~ in the path
        subprocess.run(["sh", expanded_path], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing shell script: {e}")
        error()


if len(sys.argv) > 1 and sys.argv[1] == 'load':
    root = tk.Tk()
    load()

    #try:
    #   execute_shell_script("~/sysZ/shell/setup.sh")
    #except Exception as e:
    #    print(f"An error occurred: {e}")
    #    error("setup script has failed")
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'docs':
    root = tk.Tk()
    docs("sysZ | docs")
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'update':
    root = tk.Tk()
    update()
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'control':
    root = tk.Tk()
    control()
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'home':
    root = tk.Tk()
    home()
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'help':
    print("docs, control")