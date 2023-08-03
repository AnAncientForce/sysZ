import threading
import tkinter as tk
from tkinter import ttk, scrolledtext
import sys
import subprocess
import os
import json
from subprocess import call
from PIL import Image, ImageTk

root = None
previous_page = "home"
current_page = "home"
setup_pending = False
debug_lbl_created = False
debug = None
progress_bar = None

def createRoot():
    global root
    #root = ThemedTk(theme="Adapta")
    root = tk.Tk()

def stop_loading():
    root.destroy()

createRoot()


def select_wallpaper():
    clear_tk_elements(root)
    root.title("Select wallpaper")
    
    label = ttk.Label(root, text="Change Wallpaper", font=("Arial", 26), background=root['bg'], foreground="white")
    label.pack(pady=50)

    # Create a frame to hold the canvas and scrollbar
    canvas_frame = tk.Frame(root, background=root['bg'])
    canvas_frame.pack(side=tk.TOP, fill=tk.BOTH, expand=True)

    # Create a canvas widget
    canvas = tk.Canvas(canvas_frame, background=root['bg'])
    canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

    # Add a scrollbar to the canvas
    scrollbar = tk.Scrollbar(canvas_frame, command=canvas.yview, orient=tk.VERTICAL)
    scrollbar.pack(side=tk.RIGHT, fill='y')

    # Configure the canvas to use the scrollbar
    canvas.configure(yscrollcommand=scrollbar.set)

    # Create a frame inside the canvas for the grid
    grid_frame = tk.Frame(canvas, background=root['bg'])
    canvas.create_window((0, 0), window=grid_frame, anchor=tk.NW)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    wallpaper_dir = os.path.join(script_dir, "wallpapers")
    wallpapers = os.listdir(wallpaper_dir)
    target_size = (200, 200)

    def wallpaper_selected(wallpaper):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        wallpaper_path = os.path.join(script_dir, "wallpapers", wallpaper)
        dest_path = os.path.join(script_dir, "bg")
        call(f"cp -v {wallpaper_path} {dest_path}", shell=True)
        call(f"feh --bg-fill {wallpaper_path}", shell=True)

    def update_grid_layout(event=None):
        # Calculate the number of columns based on the available width
        num_columns = max(1, canvas.winfo_width() // (target_size[0] + 20))
        # Clear the existing grid
        for widget in grid_frame.winfo_children():
            widget.destroy()
        # Repopulate the grid with updated images and buttons
        for i, wallpaper in enumerate(wallpapers):
            img = Image.open(os.path.join(wallpaper_dir, wallpaper))
            img.thumbnail(target_size, Image.BICUBIC)
            bordered_img = Image.new("RGB", target_size, "black")
            bordered_img.paste(img, ((target_size[0] - img.size[0]) // 2, (target_size[1] - img.size[1]) // 2))
            img_tk = ImageTk.PhotoImage(bordered_img)
            button = tk.Button(grid_frame, image=img_tk, command=lambda wallpaper=wallpaper: wallpaper_selected(wallpaper))
            button.grid(row=i // num_columns, column=i % num_columns, padx=10, pady=10)
            button.image = img_tk

        # Update the canvas scroll region
        canvas.update_idletasks()
        canvas.config(scrollregion=canvas.bbox(tk.ALL))

    # Update the grid layout initially
    update_grid_layout()

    # Bind the canvas to the canvas resize event
    canvas.bind("<Configure>", update_grid_layout)

    # Bind the mouse wheel event to the canvas for scrolling
    canvas.bind_all("<MouseWheel>", lambda event: canvas.yview_scroll(-1*(event.delta//120), "units"))

    skip_button = ttk.Button(root, text="Home", command=home)
    skip_button.pack(side=tk.BOTTOM, pady=10)

# Rest of your code...




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
    #root.configure(bg="#6495ED")
    main_frame = render_title(title)

    buttons_frame = ttk.LabelFrame(main_frame, borderwidth=0, relief="groove")
    buttons_frame.grid(row=1, column=1, padx=5, pady=5)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, file)
    with open(config_path, "r") as file:
        text_content = file.read()

    text_box = scrolledtext.ScrolledText(buttons_frame, font=("Arial", 14), bg=root["bg"], fg="white", width=60, height=20)
    text_box.insert("1.0", text_content)
    text_box.pack(pady=5)

    if title == "Printer Setup":
        hint("Shortcut", "Open localhost?", openBrowser)
        

def openBrowser():
    call("i3-msg 'exec xdg-open https://localhost:631;'", shell=True)

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
        subprocess_thread = threading.Thread(target=lambda: execute_shell_script("~/sysZ/shell/pull.sh", automatic_flag=True))
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
    

def execute_shell_script(script_path, automatic_flag=False):
    try:
        expanded_path = os.path.expanduser(script_path)  # Expand the ~ in the path
        print("Script on new thread has started")
        debugTxt("Started new thread, updater has started")

        # Build the subprocess command based on the automatic_flag value
        command = ["sh", expanded_path]
        if automatic_flag:
            command.extend(["--automatic"])

        subprocess.run(command, check=True)
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
            # root.after(3000, control)
        else:
            debugTxt("Closing python interface")
            stop_loading()
            # root.after(3000, stop_loading)

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
    else:
        call("i3-msg 'exec picom -b --animations --animation-for-open-window zoom --corner-radius 4 --vsync;'", shell=True)
        
    
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
    try:
        frame.update_idletasks()
        width = frame.winfo_reqwidth()
        height = frame.winfo_reqheight()

        window_width = window.winfo_width()
        window_height = window.winfo_height()

        x_offset = (window_width - width) // 2
        y_offset = (window_height - height) // 2

        frame.place(x=x_offset, y=y_offset)
        root.after(100, lambda: center_frame(frame, window))
    except Exception as e:
        print(f"This cannot be fixed (p.1) An error occurred: {e}")
    


def adjust_button_width_to_text(parent_frame):
    for child in parent_frame.winfo_children():
        if isinstance(child, ttk.Button):
            # Get the text from the existing button
            text = child["text"]

            # Adjust the width of the existing button based on the text length
            child.configure(width=len(text))



def hint(title, desc, shortcut_func=None):
    style = ttk.Style()

    frame_color = "#808080"
    button_color = "#4C554F"
    font_size = 14
    button_width = 17.5
    title_font_size = 16
    button_padding = 5
    
    style.configure("TLabelframe", background=frame_color)
    style.configure("TButton", background=button_color, foreground="white", font=("Arial", font_size, "bold"), width=button_width, padding=button_padding)
    style.configure("TLabel", font=("Arial", font_size), background=frame_color, foreground="white")
    style.configure("TLabelframe.Label", font=("Arial", title_font_size, "bold"), foreground="white", background=frame_color)

    main_frame = ttk.LabelFrame(root, style="TLabelframe", borderwidth=0)
    main_frame.grid(row=1, column=1, padx=0, pady=0)

    root.grid_columnconfigure(1, weight=1)
    root.grid_rowconfigure(1, weight=1)
    main_frame.grid_columnconfigure(0, weight=1)
    main_frame.grid_rowconfigure(0, weight=1)

    title_label = ttk.Label(main_frame, text=title, style="TLabelframe.Label")
    title_label.grid(row=0, column=0, padx=5, pady=5)

    desc_label = ttk.Label(main_frame, text=desc, style="TLabel")
    desc_label.grid(row=1, column=0, padx=5, pady=5)

    if shortcut_func:
        no_button = ttk.Button(main_frame, text="CANCEL", command=main_frame.destroy, style="TButton")
        no_button.grid(row=2, column=0, padx=5, pady=5)
        
        shortcut_button = ttk.Button(main_frame, text="PROCEED", command=lambda: [shortcut_func(), main_frame.destroy()], style="TButton")
        shortcut_button.grid(row=3, column=0, padx=5, pady=5)
    else:
        ok_button = ttk.Button(main_frame, text="DISMISS", command=main_frame.destroy, style="TButton")
        ok_button.grid(row=2, column=0, padx=5, pady=5)
    root.after(100, lambda: center_frame(main_frame, root))






def render_title(txt):
    root.title(txt)
    '''
    script_directory = os.path.dirname(os.path.abspath(__file__))
    image_path = os.path.join(script_directory, "line.png")
    image = Image.open(image_path)
    image = image.resize((400, 400), resample=Image.BICUBIC)
    image = image.convert("RGBA")
    photo = ImageTk.PhotoImage(image)
    c = tk.Label(root)
    c.pack(pady=25)
    c.config(image=photo, background=root["bg"])
    c.place(x=0, y=0, relwidth=1, relheight=1)
    '''
    style = ttk.Style()
    style.theme_use("clam")
    frame_color = "#333333"
    button_color = "#4C554F"
    font_size = 12
    button_width = 17.5
    button_padding = 5
    
    style.configure("Custom.TLabelframe", background=frame_color)
    style.configure("Custom.TButton", background=button_color, foreground="white", font=("Arial", font_size, "bold"), width=button_width, padding=button_padding, borderwidth=0)
    style.configure("Custom.TLabelframe.Label", font=("Arial", font_size, "bold"), background=frame_color, foreground="white")
    

    main_frame = ttk.LabelFrame(root, style="Custom.TLabelframe", borderwidth=0)
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
                                    padding=button_padding)
                #adjust_button_width_to_text(child)
                for grandchild in child.winfo_children():
                    if isinstance(grandchild, ttk.Button):
                        grandchild.configure(style="Child.TButton")  # Apply custom style to buttons within child frames
                    elif isinstance(grandchild, ttk.Frame):
                        colouring(grandchild)  # Recursively process frames within child frames


    title_frame = ttk.LabelFrame(main_frame, borderwidth=0, relief="groove")
    title_frame.grid(row=0, column=1, padx=10, pady=10)

    label = None
    if not (previous_page == "control" or previous_page == "home" or previous_page == "docs" or previous_page == "docsOverview"):
        label = ttk.Label(title_frame, text=txt, font=("Arial", 36), background=root["bg"])
    else:
        label = ttk.Label(title_frame, text=txt, font=("Arial", 36), background=frame_color, foreground="white")
        root.configure(bg=frame_color)
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

    page_controls = ttk.LabelFrame(frame, text="<>")
    page_controls.grid(row=2, column=1, padx=10, pady=10)

    def checkHomeLoc():
        if previous_page == "docsOverview":
            docsOverview()
        else:
            home()
    
    home_button = ttk.Button(page_controls, text="Home", command=home)
    home_button.pack(pady=1)
    close_button = ttk.Button(page_controls, text="Close", command=stop_loading)
    close_button.pack(pady=1)
    


def control():
    global previous_page
    previous_page = "control"
    clear_tk_elements(root)
    
    root.configure(bg="#6495ED")
    main_frame = render_title("sysZ | control")
    gPady = 7

    style = ttk.Style()
    style.configure("Title.TLabelframe", background=root["bg"])
    style.configure("TLabelframe", padding=5)
   
    options_frame = ttk.LabelFrame(main_frame, text="sysZ")
    options_frame.grid(row=1, column=0, padx=gPady, pady=gPady)

    buttons_frame = ttk.LabelFrame(main_frame, text="Operations")
    buttons_frame.grid(row=1, column=1, padx=gPady, pady=gPady)

    updates_frame = ttk.LabelFrame(main_frame, text="Updates")
    updates_frame.grid(row=1, column=3, padx=gPady, pady=gPady)

    power_frame = ttk.LabelFrame(main_frame, text="System")
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
        hint("Hint", "Test Test Test Test Test Test Test Test Test Test Test Test\nTest Test Test Test Test Test Test Test Test Test \nTest Test Test Test Test Test Test Test")
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

    
    # --- SETTING END

    

    execute_button = tk.Button(options_frame, text="Execute (Dev)", command=execute_code)
    execute_button.pack(pady=gPady)

    terminal_button = ttk.Button(buttons_frame, text="Open Terminal", command=lambda: subprocess.Popen(["alacritty", "&"], shell=True))
    terminal_button.pack(pady=gPady)

    appearance_button = ttk.Button(buttons_frame, text="Change Appearance", command=lambda: os.system("qt5ct & lxappearance &"))
    appearance_button.pack(pady=gPady)

    cw_button = ttk.Button(buttons_frame, text="Change Wallpaper", command=select_wallpaper)
    cw_button.pack(pady=gPady)

    arch_pkg = ttk.Button(updates_frame, text="Arch PKG", command=lambda: subprocess.Popen("sh " + os.path.expanduser("~/sysZ/shell/pacman.sh"), shell=True))
    arch_pkg.pack(pady=gPady)
    yay_pkg = ttk.Button(updates_frame, text="AUR PKG", command=lambda: subprocess.Popen("sh " + os.path.expanduser("~/sysZ/shell/yay.sh"), shell=True))
    yay_pkg.pack(pady=gPady)
    def sysUpd():
        root.after(10, lambda: hint("Use Terminal", "Please proceed in the terminal. The terminal should be the window next to this.\nPress CTRL+C to cancel"))
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

    #cw_button = ttk.Button(buttons_frame, text="Change Wallpaper", command=lambda: subprocess.Popen(["sh", os.path.expanduser("~/sysZ/shell/cw.sh")]))
    cw_button = ttk.Button(buttons_frame, text="Change Wallpaper", command=select_wallpaper)
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

    docs_button = ttk.Button(buttons_frame, text="View Documentation", command=docsOverview)
    docs_button.pack(pady=10)

    control_button = ttk.Button(buttons_frame, text="Control Panel", command=control)
    control_button.pack(pady=10)

    logs_button = ttk.Button(buttons_frame, text="Change Logs", command=lambda: docs("sysZ | Changes Logs", "todo.rtf"))
    logs_button.pack(pady=10)

    about_button = ttk.Button(buttons_frame, text="About", command=lambda: hint("About", "sysZ\n\nA preconfigured customization of the i3 window manager\n\nSee more on the repository: https://github.com/AnAncientForce/sysZ"))
    about_button.pack(pady=10)

    

    # _tkinter.TclError: cannot use geometry manager pack inside
    # Basically means U cannot use .pack(pad=) in same frame as one using .grid(row=)



def docsOverview():
    global previous_page
    previous_page = "docsOverview"
    clear_tk_elements(root)
    main_frame = render_title("Guide")

    buttons_frame = ttk.LabelFrame(main_frame, padding=5)
    buttons_frame.grid(row=1, column=1, padx=5, pady=5)

    bluetooth_btn = ttk.Button(buttons_frame, text="Bluetooth", command=lambda: docs("How to use bluetooth", "docs/bluetooth.txt"))
    bluetooth_btn.pack(pady=10)

    pkg_btn = ttk.Button(buttons_frame, text="Packages & Updates", command=lambda: docs("How to install packages", "docs/pkgs.txt"))
    pkg_btn.pack(pady=10)

    print_btn = ttk.Button(buttons_frame, text="Printing", command=lambda: docs("Printer Setup", "docs/print.txt"))
    print_btn.pack(pady=10)

    i3_btn = ttk.Button(buttons_frame, text="i3-wm Shortcuts", command=lambda: docs("i3-wm keybinds", "docs/i3.txt"))
    i3_btn.pack(pady=10)




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
    load()
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'docs':
    docsOverview()
    # docs("sysZ | Docs", "docs.rtf")
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'update':
    update()
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'control':
    control()
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'home':
    home()
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'help':
    print("docs, control")

if len(sys.argv) > 1 and sys.argv[1] == 'update_confirmation':
    if not check_value_from_json('ignore_updates'):
        update_confirmation()
        root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'ui_test':
    ui_test()
    root.mainloop()
    
if len(sys.argv) > 1 and sys.argv[1] == 'no_grid':
    no_grid_test()
    root.mainloop()

if len(sys.argv) > 1 and sys.argv[1] == 'wall':
    select_wallpaper()
    root.mainloop()