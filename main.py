import threading
import tkinter as tk
from tkinter import ttk, scrolledtext
import sys
import subprocess
import os
import json
from subprocess import call
import time
from PIL import Image, ImageTk

previous_page = "home"
current_page = "home"

def stop_loading():
    root.destroy()

def load():
    clear_tk_elements(root)
    root.attributes('-fullscreen', True) 
    root.configure(bg="#6495ED")
    root.title("sysZ | splash")

    label = ttk.Label(root, text="sysZ", font=("Arial", 36), background=root['bg'])
    label.pack(pady=100)

    #style = ttk.Style()
    #style.configure("TProgressbar", thickness=80)
    #progress_bar = ttk.Progressbar(root, style="TProgressbar", mode="indeterminate", length=600)
    #progress_bar.pack(pady=50)

    # Load
    global image, photo, script_complete
    x = prepare_image_rotation(root)
    rotate_image(0, x)
    # Load Continue

    if previous_page == "control":
        root.after(3000, control)
    else:
        root.after(3000, stop_loading)

    #root.after(100, lambda: progress_bar.start(10))
    setup()


def docs():
    clear_tk_elements(root)
    root.configure(bg="#6495ED")
    main_frame = render_title("sysZ | docs")

    buttons_frame = ttk.LabelFrame(main_frame, borderwidth=0, relief="groove")
    buttons_frame.grid(row=1, column=1, padx=5, pady=5)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, 'docs.rtf')
    with open(config_path, "r") as file:
        text_content = file.read()

    text_box = scrolledtext.ScrolledText(buttons_frame, font=("Arial", 14), bg=root["bg"], width=60, height=20)
    text_box.insert("1.0", text_content)
    text_box.pack(pady=5)

    

def update():
    clear_tk_elements(root)
    root.attributes('-fullscreen', True) 
    root.configure(bg="#6495ED")
    label = ttk.Label(root, text="Updates are underway", font=("Arial", 36), background=root['bg'])
    label.pack(pady=100)
    #subprocess.run(["sh", "shell/non_sudo_update.sh"])
    #root.title("sysZ | updates")
    #render_title("Updates are underway")
    #call("i3-msg 'exec killall -9 picom;'", shell=True)

    #main_frame = ttk.LabelFrame(root, borderwidth=0, relief="groove")
    #main_frame.grid(row=1, column=1, padx=10, pady=10, sticky="nsew")

    #style = ttk.Style()
    #style.configure("TProgressbar", thickness=80)
    #progress_bar = ttk.Progressbar(root, style="TProgressbar", mode="indeterminate", length=600)
    #progress_bar.pack(pady=50)


    try:
        # Load
        global image, photo, script_complete
        x = prepare_image_rotation(root)
        subprocess_thread = threading.Thread(target=execute_shell_script("sysZ/shell/non_sudo_update.sh"))
        subprocess_thread.start()
        rotate_image(0, x)
        # Load End
        #subprocess.run(["sh", os.path.expanduser("~/sysZ/shell/non_sudo_update.sh")])
        if previous_page == "control":
            root.after(3000, control)
        else:
            root.after(3000, stop_loading)
        #root.after(100, lambda: progress_bar.start(10))
        setup()
    except Exception as e:
        print(f"An error occurred: {e}")



def prepare_image_rotation(root):
    global image, photo, script_complete
    #label.grid(row=3, column=1)
    script_complete = False
    script_directory = os.path.dirname(os.path.abspath(__file__))
    image_path = os.path.join(script_directory, "load.png")
    image = Image.open(image_path)
    image = image.resize((50, 50), resample=Image.BICUBIC)
    image = image.convert("RGBA")
    photo = ImageTk.PhotoImage(image)
    labelC = tk.Label(root)
    labelC.pack(pady=25)
    labelC.config(image=photo, background=root["bg"])
    return labelC

def rotate_image(angle, label):
    global image, photo, script_complete
    rotated_image = image.rotate(angle, resample=Image.BICUBIC, expand=False)
    rotated_photo = ImageTk.PhotoImage(rotated_image)
    label.config(image=rotated_photo)
    label.image = rotated_photo
    if script_complete:
        return
    root.after(50, rotate_image, (angle + 10) % 360, label)

def no_grid_test():
    clear_tk_elements(root)
    root.attributes('-fullscreen', True) 
    root.configure(bg="#6495ED")
    label = ttk.Label(root, text="No grid test", font=("Arial", 36), background=root['bg'])
    label.pack(pady=100)
    
    global image, photo, script_complete
    x = prepare_image_rotation(root)
    root.after(3000, lambda: globals().update({'script_complete': True}))
    rotate_image(0, x)
    





def update_confirmation():
    #subprocess.run(["sh", os.path.expanduser("~/sysZ/shell/background_update_check.sh")])
    #render_title("A new update is now available")
    #render_back_btn()
    clear_tk_elements(root)
    root.configure(bg="#6495ED")
    root.title("Update")

    label = ttk.Label(root, text="A new update is now available!", font=("Arial", 36), background=root['bg'])
    label.pack(pady=50)

    update_button = ttk.Button(root, text="Update [sysZ]", command=update)
    update_button.pack(pady=10)

    skip_button = ttk.Button(root, text="Skip", command=stop_loading)
    skip_button.pack(pady=10)





def setup():
    call("i3-msg 'exec killall -9 picom;'", shell=True)
    if check_value_from_json('use_background_blur'):
        call("i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'", shell=True)
        # print("use_background_blur are enabled.")
        # subprocess.run("i3-msg 'exec picom -b --blur-background --backend glx --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'", shell=True)
    else:
        call("i3-msg 'exec picom -b --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'", shell=True)
        # print("use_background_blur are disabled.")
        # subprocess.Popen(["sh", os.path.expanduser("~/sysZ/main.sh")])
        # run_shell_script_function(os.path.expanduser("~/sysZ/opt.sh"), "picom_without_animations")
        # subprocess.run(["i3-msg", "exec", "picom", "-b", "--blur-background", "--backend", "glx", "--animations", "--animation-for-open-window", "zoom", "--corner-radius", "4", "--vsync"])
        # subprocess.run(["i3-msg", "exec", "picom", "-b", "--blur-background", "--corner-radius", "4", "--vsync"])
    
    if check_value_from_json('use_auto_tiling'):
       call("i3-msg 'exec killall -9 autotiling; workspace 9; exec alacritty -e autotiling;'", shell=True)
       root.after(500, lambda: call("i3-msg 'workspace 1'", shell=True))
    #subprocess.Popen(["sh", os.path.expanduser("~/sysZ/shell/setup.sh")])
    global image, photo, script_complete
    subprocess_thread = threading.Thread(target=execute_shell_script("sysZ/shell/setup.sh"))
    subprocess_thread.start()
    print("force script_complete because setup has finished")


def run_shell_script_function(shell_script_path, function_name):
    os.system(f"bash -c 'source {shell_script_path}; {function_name}'")





def create_config_file():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.expanduser("~/.config/sysZ/config.json")

    if not os.path.isfile(config_path):
        with open(config_path, 'w') as file:
            json.dump({}, file)  # Create an empty JSON object

def check_value_from_json(key):
    create_config_file()

    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.expanduser("~/.config/sysZ/config.json")

    with open(config_path, 'r') as file:
        data = json.load(file)
        if key in data:
            return data[key]
        else:
            return False


def set_value_in_json(key, value):
    create_config_file()

    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.expanduser("~/.config/sysZ/config.json")

    with open(config_path, 'r') as file:
        data = json.load(file)

    data[key] = value

    with open(config_path, 'w') as file:
        json.dump(data, file)

    return True


def center_frame(frame, window):
    frame.update_idletasks()
    width = frame.winfo_reqwidth()
    height = frame.winfo_reqheight()

    window_width = window.winfo_width()
    window_height = window.winfo_height()

    x_offset = (window_width - width) // 2
    y_offset = (window_height - height) // 2

    frame.place(x=x_offset, y=y_offset)


def render_title(txt):
    root.title(txt)
    #style = ttk.Style()
    #style.configure("Title.TLabelframe", background=root["bg"], relief="flat")
    #main_frame = ttk.LabelFrame(root,borderwidth=0, relief="groove") # style="Title.TLabelframe"
    #main_frame.grid(row=1, column=0, padx=3, pady=3)
   
    main_frame = ttk.LabelFrame(root, borderwidth=0, relief="groove")
    main_frame.grid(row=0, column=0, padx=0, pady=0) #1

    root.grid_rowconfigure(0, weight=1)
    root.grid_rowconfigure(2, weight=1)
    root.grid_columnconfigure(0, weight=1)
    root.grid_columnconfigure(2, weight=1)

    root.after(250, lambda: center_frame(main_frame, root))

    title_frame = ttk.LabelFrame(main_frame, borderwidth=0, relief="groove")
    title_frame.grid(row=0, column=1, padx=10, pady=10)

    label = ttk.Label(title_frame, text=txt, font=("Arial", 36), background=root["bg"])
    label.grid(row=0, column=1, pady=10)

    render_back_btn(main_frame)
    return main_frame



def render_back_btn(frame):
    def goBack():
        global previous_page
        global current_page
        if current_page == "control":
            control()
        elif current_page == "home":
            home()
        previous_page = current_page
    
    def resPy():
        global previous_page
        global current_page
        previous_page=""
        current_page=""
        # eh this function is not working properly
         # update, then restart python
        root.after(2500, lambda: subprocess.Popen(["python", os.path.expanduser("~/sysZ/main.py control")]))
        update()

    page_controls = ttk.LabelFrame(frame,borderwidth=0, relief="groove")
    page_controls.grid(row=2, column=1, padx=10, pady=10)

    #page_controls.grid(row=0, column=0, padx=10, pady=10)
    #back_button = ttk.Button(page_controls, text="Back", command=goBack)
    #back_button.pack(pady=1)
    home_button = ttk.Button(page_controls, text="Home", command=home)
    home_button.pack(pady=1)
    close_button = ttk.Button(page_controls, text="Close", command=stop_loading)
    close_button.pack(pady=1)
    #res = ttk.Button(page_controls, text="<dev>", command=resPy)
    #res.pack(pady=1)


def control():
    global previous_page
    previous_page = "control"
    clear_tk_elements(root)
    # previous_page = globals().setdefault('previous_page', 'control')
    # root.attributes('-fullscreen', True) 
    # root.title("sysZ | control")
    root.configure(bg="#6495ED")
    main_frame = render_title("sysZ | control")
    gPady = 7

    style = ttk.Style()
    style.configure("Title.TLabelframe", background=root["bg"])
   
    options_frame = ttk.LabelFrame(main_frame, text="sysZ",borderwidth=0, relief="groove")
    options_frame.grid(row=1, column=0, padx=gPady, pady=gPady)

    buttons_frame = ttk.LabelFrame(main_frame, text="Operations",borderwidth=0, relief="groove")
    buttons_frame.grid(row=1, column=1, padx=gPady, pady=gPady)

    power_frame = ttk.LabelFrame(main_frame, text="System",borderwidth=0, relief="groove")
    power_frame.grid(row=1, column=2, padx=gPady, pady=gPady)

    
    # --- SETTINGS

    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.expanduser("~/.config/sysZ/config.json")
    
    def update_config():
        use_background_blur_value = use_background_blur.get()
        ignore_updates_value = ignore_updates.get()
        use_auto_tiling_value = use_auto_tiling.get()
        set_value_in_json('use_background_blur', use_background_blur_value)
        set_value_in_json('ignore_updates', ignore_updates_value)
        set_value_in_json('use_auto_tiling', use_auto_tiling_value)
        #splash_enabled_value = splash_enabled.get()
        #set_value_in_json('splashEnabled', splash_enabled_value)

    
   
    def execute_code():
        if check_value_from_json('use_background_blur'):
            print("Animations enabled")
            
        else:
            print("Animations disabled")
    
    # Temp New Change Test
    # Read the configuration file
    try:
        create_config_file()
        with open(config_path, 'r') as file:
            config = json.load(file)
    except Exception as e:
        print(f"An error occurred: {e}")
    
        
    use_background_blur = tk.BooleanVar(value=config.get('use_background_blur', False))
    checkbox_background_blur = tk.Checkbutton(options_frame, text="Use background blur", variable=use_background_blur, command=update_config)
    checkbox_background_blur.pack(pady=gPady)

    ignore_updates = tk.BooleanVar(value=config.get('ignore_updates', False))
    checkbox_ignore_updates = tk.Checkbutton(options_frame, text="Ignore updates", variable=ignore_updates, command=update_config)
    checkbox_ignore_updates.pack(pady=gPady)

    use_auto_tiling = tk.BooleanVar(value=config.get('use_auto_tiling', False))
    checkbox_use_auto_tiling = tk.Checkbutton(options_frame, text="Use auto tiling", variable=use_auto_tiling, command=update_config)
    checkbox_use_auto_tiling.pack(pady=gPady)

    execute_button = tk.Button(options_frame, text="Execute (Dev)", command=execute_code)
    execute_button.pack(pady=gPady)
    
    

    
    

    #splash_enabled = tk.BooleanVar(value=config.get('splashEnabled', False))
    #checkbox_splash = tk.Checkbutton(options_frame, text="Enable Splash", variable=splash_enabled, command=update_config)
    #checkbox_splash.pack(pady=gPady)

    
    # --- SETTING END

    terminal_button = ttk.Button(buttons_frame, text="Open Terminal", command=lambda: subprocess.Popen(["alacritty", "&"], shell=True))
    terminal_button.pack(pady=gPady)

    appearance_button = ttk.Button(buttons_frame, text="Change Appearance", command=lambda: os.system("qt5ct & lxappearance &"))
    appearance_button.pack(pady=gPady)

    cw_button = ttk.Button(buttons_frame, text="Change Wallpaper", command=lambda: subprocess.Popen(["sh", os.path.expanduser("~/sysZ/shell/cw.sh")]))
    cw_button.pack(pady=gPady)

    update_button = ttk.Button(options_frame, text="Update [sysZ]", command=update)
    update_button.pack(pady=gPady)
    
    restartSys = ttk.Button(options_frame, text="Restart [sysZ]", command=load)
    restartSys.pack(pady=gPady)

    logout_button = ttk.Button(power_frame, text="Logout", command=lambda: subprocess.Popen(["i3-msg", "exit"]))
    logout_button.pack(pady=gPady)

    restart_button = ttk.Button(power_frame, text="Restart", command=lambda: subprocess.Popen(["systemctl", "reboot"]))
    restart_button.pack(pady=gPady)

    shutdown_button = ttk.Button(power_frame, text="Shutdown", command=lambda: subprocess.Popen(["systemctl", "poweroff"]))
    shutdown_button.pack(pady=gPady)

    

def ui_test():
    gPady = 10

    main_frame = render_title("UI_TEST")

    style = ttk.Style()
    style.configure("Title.TLabelframe", background=root["bg"])

    options_frame = ttk.LabelFrame(main_frame, text="Options",borderwidth=0, relief="groove")
    options_frame.grid(row=1, column=0, padx=10, pady=10)

    buttons_frame = ttk.LabelFrame(main_frame, text="Operations",borderwidth=0, relief="groove")
    buttons_frame.grid(row=1, column=1, padx=10, pady=10)

    power_frame = ttk.LabelFrame(main_frame, text="System",borderwidth=0, relief="groove")
    power_frame.grid(row=1, column=2, padx=10, pady=10)

    terminal_button = ttk.Button(buttons_frame, text="Open Terminal", command=lambda: subprocess.Popen(["alacritty", "&"], shell=True))
    terminal_button.pack(pady=gPady)

    appearance_button = ttk.Button(buttons_frame, text="Change Appearance", command=lambda: os.system("qt5ct & lxappearance &"))
    appearance_button.pack(pady=gPady)

    cw_button = ttk.Button(buttons_frame, text="Change Wallpaper", command=lambda: subprocess.Popen(["sh", os.path.expanduser("~/sysZ/shell/cw.sh")]))
    cw_button.pack(pady=gPady)

    update_button = ttk.Button(options_frame, text="Update [sysZ]", command=update)
    update_button.pack(pady=gPady)
    
    restartSys = ttk.Button(options_frame, text="Restart [sysZ]", command=load)
    restartSys.pack(pady=gPady)

    logout_button = ttk.Button(power_frame, text="Logout", command=lambda: subprocess.Popen(["i3-msg", "exit"]))
    logout_button.pack(pady=gPady)

    restart_button = ttk.Button(power_frame, text="Restart", command=lambda: subprocess.Popen(["systemctl", "reboot"]))
    restart_button.pack(pady=gPady)

    shutdown_button = ttk.Button(power_frame, text="Shutdown", command=lambda: subprocess.Popen(["systemctl", "poweroff"]))
    shutdown_button.pack(pady=gPady)

    for widget in main_frame.winfo_children():
        widget.grid_configure(padx=10, pady=5)


def home():
    global previous_page
    previous_page = "home"
    clear_tk_elements(root)
    root.configure(bg="#6495ED")

    main_frame = render_title("sysZ | home")

    buttons_frame = ttk.LabelFrame(main_frame,borderwidth=0, relief="groove")
    buttons_frame.grid(row=1, column=1, padx=0, pady=0)

    docs_button = ttk.Button(buttons_frame, text="View Documentation", command=docs)
    docs_button.pack(pady=10)

    control_button = ttk.Button(buttons_frame, text="Control Panel", command=control)
    control_button.pack(pady=10)

    

    # _tkinter.TclError: cannot use geometry manager pack inside
    # Basically means U cannot use .pack(pad=) in same frame as one using .grid(row=)







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
    root.attributes('-fullscreen', False) 
    for child in root.winfo_children():
        child.destroy()





def execute_shell_script(script_path):
    try:
        expanded_path = os.path.expanduser(script_path)  # Expand the ~ in the path
        subprocess.run(["sh", expanded_path], check=True)
        global script_complete
        script_complete = True
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
    docs()
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

if len(sys.argv) > 1 and sys.argv[1] == 'update_confirmation':
    if not check_value_from_json('ignore_updates'):
        root = tk.Tk()
        update_confirmation()
        root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'ui_test':
    root = tk.Tk()
    ui_test()
    root.mainloop()
    
if len(sys.argv) > 1 and sys.argv[1] == 'no_grid':
    root = tk.Tk()
    no_grid_test()
    root.mainloop()