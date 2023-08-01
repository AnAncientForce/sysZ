import threading
import tkinter as tk
from tkinter import ttk, scrolledtext
import sys
import subprocess
import os
import json
from subprocess import call
from PIL import Image, ImageTk

previous_page = "home"
current_page = "home"
setup_pending = False
debug_lbl_created = False
debug = None
progress_bar = None


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

    global script_complete
    prepare_image_rotation(root)
    '''
    if previous_page == "control":
        root.after(3000, control)
    else:
        root.after(3000, stop_loading)
    '''
    #root.after(100, lambda: progress_bar.start(10))
    setup()


def docs(title, file):
    clear_tk_elements(root)
    root.configure(bg="#6495ED")
    main_frame = render_title(title)

    buttons_frame = ttk.LabelFrame(main_frame, borderwidth=0, relief="groove")
    buttons_frame.grid(row=1, column=1, padx=5, pady=5)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, file)
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

    ''''
    global progress_bar
    style = ttk.Style()
    style.configure("TProgressbar", thickness=80)
    progress_bar = ttk.Progressbar(root, style="TProgressbar", mode="determinate", length=600)
    progress_bar.pack(pady=50)
    #progress_bar["value"] = 20
    '''

    try:
        prepare_image_rotation(root)
        debugTxt("Checking github repository for updates")
        subprocess_thread = threading.Thread(target=lambda: execute_shell_script("~/sysZ/shell/non_sudo_update.sh"))
        subprocess_thread.start()
        global setup_pending
        setup_pending = True
        #subprocess.run(["sh", os.path.expanduser("~/sysZ/shell/non_sudo_update.sh")])
        '''
        if previous_page == "control":
            root.after(3000, control)
        else:
            root.after(3000, stop_loading)
        '''
        #root.after(100, lambda: progress_bar.start(10))
        #setup()
    except Exception as e:
        print(f"An error occurred: {e}")


def update_progress(amount):
    global progress_bar
    progress_bar["value"] = amount


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
    rotate_image(0, labelC)

def rotate_image(angle, labelC):
    global image, photo, script_complete
    rotated_image = image.rotate(angle, resample=Image.BICUBIC, expand=False)
    rotated_photo = ImageTk.PhotoImage(rotated_image)
    labelC.config(image=rotated_photo)
    labelC.image = rotated_photo
    if script_complete:
        # Clean up resources
        image.close()
        photo = None
        labelC = None
        #clear_tk_elements(root)
        return
    root.after(5, rotate_image, (angle + 10) % 360, labelC)
    #root.after(50, lambda: rotate_image, (angle + 10) % 360, labelC)

def no_grid_test():
    clear_tk_elements(root)
    root.attributes('-fullscreen', True) 
    root.configure(bg="#6495ED")
    label = ttk.Label(root, text="No grid test", font=("Arial", 36), background=root['bg'])
    label.pack(pady=100)

    global script_complete
    prepare_image_rotation(root)
    root.after(3000, lambda: globals().update({'script_complete': True}))
    
def execute_shell_script(script_path):
    try:
        expanded_path = os.path.expanduser(script_path)  # Expand the ~ in the path
        print("Script on new thread has started")
        debugTxt("Started new thread, updater has started")
        subprocess.run(["sh", expanded_path], check=True)
        global script_complete, previous_page, setup_pending
        script_complete = True
        print("script_complete = True")
        debugTxt("script_complete = True")
        if setup_pending:
            setup_pending = False
            setup()
            debugTxt("Shell setup has finished")

        if previous_page == "control":
            control()
            #root.after(3000, control)
        else:
            debugTxt("Closing python interface")
            stop_loading()
            #root.after(3000, stop_loading)

    except subprocess.CalledProcessError as e:
        print(f"Error executing shell script: {e}")
        error()

def debugTxt(txt):
    global debug, debug_lbl_created
    if not debug_lbl_created:
        debug_lbl_created = True
        debug = ttk.Label(root, font=("Arial", 26), background=root['bg'], foreground="red")
        debug.pack(pady=100)
    debug.config(text=txt)


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
    debugTxt("Running shell setup")
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
    subprocess_thread = threading.Thread(target=lambda: execute_shell_script("~/sysZ/shell/setup.sh"))
    subprocess_thread.start()


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
    root.after(2500, lambda: center_frame(frame, window))


def adjust_button_width_to_text(parent_frame):
    for child in parent_frame.winfo_children():
        if isinstance(child, ttk.Button):
            # Get the text from the existing button
            text = child["text"]

            # Adjust the width of the existing button based on the text length
            child.configure(width=len(text))



def hint(title, desc):
    style = ttk.Style()

    frame_color = "#808080"
    button_color = "#4C554F"
    font_size = 12
    button_width = 17.5
    title_font_size = 16

    # Modify the existing theme instead of creating a new one
    style.configure("TLabelframe", background=frame_color, borderwidth=5, relief="flat", bordercolor="silver")
    style.configure("TButton",
                    background=button_color,
                    foreground="white",
                    font=("Arial", font_size, "bold"),
                    width=button_width,
                    padding=5)
    style.configure("TLabel", font=("Arial", font_size))
    style.configure("TLabelframe.Label", font=("Arial", title_font_size, "bold"), foreground="white")

    main_frame = ttk.LabelFrame(root, style="TLabelframe")
    main_frame.grid(row=0, column=0, padx=10, pady=10)

    # Add label to display title
    title_label = ttk.Label(main_frame, text=title, style="TLabelframe.Label")
    title_label.grid(row=0, column=0, padx=10, pady=10, sticky="w")

    # Add label to display description
    desc_label = ttk.Label(main_frame, text=desc, style="TLabel")
    desc_label.grid(row=1, column=0, padx=10, pady=10, sticky="w")

    # Add "Continue" button to close the popup
    ok_button = ttk.Button(main_frame, text="CONTINUE", command=main_frame.destroy, style="TButton")
    ok_button.grid(row=2, column=0, padx=10, pady=10)

    center_frame(main_frame, root)

    






def render_title(txt):
    root.title(txt)
    #style = ttk.Style()
    #style.configure("Title.TLabelframe", background=root["bg"], relief="flat")
    #main_frame = ttk.LabelFrame(root,borderwidth=0, relief="groove") # style="Title.TLabelframe"
    #main_frame.grid(row=1, column=0, padx=3, pady=3)
    
    style = ttk.Style()
    frame_color = "#333333"
    button_color = "#4C554F"
    font_size = 10
    button_width = 17.5

    # Configure the style for the frame
    style.configure("Custom.TLabelframe", background=frame_color, borderwidth=5, relief="flat", bordercolor="silver")
    #style.map("Custom.TLabelframe", background=[("active", frame_color)])

    # Configure the style for the buttons
    style.configure("Custom.TButton",
                    background=button_color,
                    foreground="white",
                    font=("Arial", font_size, "bold"),
                    width=button_width,
                    padding=5)

    style.configure("Custom.TLabelframe.Label", font=("Arial", font_size, "bold"), background=frame_color, borderwidth=5, relief="flat", bordercolor="silver", foreground="white")
    

    main_frame = ttk.LabelFrame(root, style="Custom.TLabelframe")
    main_frame.grid(row=0, column=0, padx=0, pady=0)

    def colouring(frame):
        for child in frame.winfo_children():
            if isinstance(child, ttk.Button):
                child.configure(style="Custom.TButton")  # Apply custom style to buttons
            elif isinstance(child, ttk.LabelFrame):
                child.configure(style="Custom.TLabelframe")  # Apply custom style to child frames
                child_style = ttk.Style()
                child_style.configure("Child.TButton",
                                    background=button_color,
                                    foreground="white",
                                    font=("Arial", font_size, "bold"),
                                    width=button_width,
                                    padding=5)
                #adjust_button_width_to_text(child)
                for grandchild in child.winfo_children():
                    if isinstance(grandchild, ttk.Button):
                        grandchild.configure(style="Child.TButton")  # Apply custom style to buttons within child frames
                    elif isinstance(grandchild, ttk.Frame):
                        colouring(grandchild)  # Recursively process frames within child frames


    #colouring(main_frame)
    #root.grid_rowconfigure(0, weight=1)
    #root.grid_rowconfigure(2, weight=1)
    #root.grid_columnconfigure(0, weight=1)
    #root.grid_columnconfigure(2, weight=1)

    title_frame = ttk.LabelFrame(main_frame, borderwidth=0, relief="groove")
    title_frame.grid(row=0, column=1, padx=10, pady=10)

    label = None
    if not (previous_page == "control" or previous_page == "home" or previous_page == "docs"):
        label = ttk.Label(title_frame, text=txt, font=("Arial", 36), background=root["bg"])
    else:
        label = ttk.Label(title_frame, text=txt, font=("Arial", 36), background=frame_color, foreground="white")
    label.grid(row=0, column=1, pady=10)

    render_back_btn(main_frame)
    root.after(100, lambda: center_frame(main_frame, root))
    root.after(100, lambda: colouring(main_frame))
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

    updates_frame = ttk.LabelFrame(main_frame, text="Updates",borderwidth=0, relief="groove")
    updates_frame.grid(row=1, column=3, padx=gPady, pady=gPady)

    power_frame = ttk.LabelFrame(main_frame, text="System",borderwidth=0, relief="groove")
    power_frame.grid(row=2, column=0, padx=gPady, pady=gPady)

    

    
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
        hint("Use Terminal", "The terminal should be the window next to this. Please proceed in the terminal.")
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

    arch_pkg = ttk.Button(updates_frame, text="Arch PKG", command=lambda: subprocess.Popen("sh " + os.path.expanduser("~/sysZ/shell/pacman.sh"), shell=True))
    arch_pkg.pack(pady=gPady)
    yay_pkg = ttk.Button(updates_frame, text="AUR PKG", command=lambda: subprocess.Popen("sh " + os.path.expanduser("~/sysZ/shell/yay.sh"), shell=True))
    yay_pkg.pack(pady=gPady)
    def sysUpd():
        root.after(10, lambda: hint("Use Terminal", "Please proceed in the terminal. The terminal should be the window next to this."))
        root.after(100, lambda: call("echo 'PROCEED WITH THE UPDATE FROM HERE' ; sudo pacman -Syu", shell=True))

    sys_update = ttk.Button(updates_frame, text="System Update", command=sysUpd)
    sys_update.pack(pady=gPady)


    update_button = ttk.Button(options_frame, text="Update [sysZ]", command=update)
    update_button.pack(pady=gPady)
    
    restartSys = ttk.Button(options_frame, text="Restart [sysZ]", command=load)
    restartSys.pack(pady=gPady)

    lock_button = ttk.Button(power_frame, text="Lock", command=lambda: call("i3-msg 'exec betterlockscreen -l;'", shell=True))
    lock_button.pack(pady=gPady)

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

    docs_button = ttk.Button(buttons_frame, text="View Documentation", command=lambda: docs("sysZ | Docs", "docs.rtf"))
    docs_button.pack(pady=10)

    control_button = ttk.Button(buttons_frame, text="Control Panel", command=control)
    control_button.pack(pady=10)

    logs_button = ttk.Button(buttons_frame, text="Change Logs", command=lambda: docs("sysZ | Changes Logs", "todo.rtf"))
    logs_button.pack(pady=10)

    

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
    global debug_lbl_created
    debug_lbl_created = False
    root.attributes('-fullscreen', False) 
    for child in root.winfo_children():
        child.destroy()








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
    docs("sysZ | Docs", "docs.rtf")
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