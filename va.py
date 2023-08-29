from subprocess import call
import speech_recognition as sr

def process_command(command):
    switch = {
        "search": open_rofi,
        "close window": close_window,
        "power": power_menu,
        "control": control_panel
    }
    
    action = switch.get(command, None)
    if action:
        action()
    else:
        print("Command not recognized.")

def open_rofi():
    call("i3-msg 'exec betterlockscreen -l;'", shell=True)

def close_window():
    call("i3-msg 'exec xdotool key Super+q;'", shell=True)

def power_menu():
    call("i3-msg 'exec xdotool key Super+p;'", shell=True)

def control_panel():
    call("i3-msg 'exec xdotool key Super+shift+z;'", shell=True)

def main():
    recognizer = sr.Recognizer()
    microphone = sr.Microphone()

    print("Listening for commands...")

    with microphone as source:
        while True:
            try:
                audio = recognizer.listen(source)
                command = recognizer.recognize_sphinx(audio).lower()
                print("You said:", command)
                process_command(command)
            except sr.UnknownValueError:
                print("Sorry, could not understand audio.")

if __name__ == "__main__":
    main()