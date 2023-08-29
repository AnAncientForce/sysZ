from subprocess import call
import speech_recognition as sr

def lock():
    call("i3-msg 'exec betterlockscreen -l;'", shell=True)

def open_rofi():
    call("i3-msg 'exec xdotool key Super+d;'", shell=True)

def close_window():
    call("i3-msg 'exec xdotool key Super+q;'", shell=True)

def power_menu():
    call("i3-msg 'exec xdotool key Super+p;'", shell=True)

def control_panel():
    call("i3-msg 'exec xdotool key Super+shift+z;'", shell=True)

switch = {
    "search": open_rofi,
    "close window": close_window,
    "power": power_menu,
    "control": control_panel,
    "lock": lock
}

def process_command(command):
    action = switch.get(command, None)
    if action:
        action()
    else:
        print("Command not recognized.")

def main():
    recognizer = sr.Recognizer()
    microphone = sr.Microphone()

    print("Listening for commands...")

    with microphone as source:
        while True:
            try:
                print("Available commands:", ', '.join(switch.keys()))
                audio = recognizer.listen(source)
                command = recognizer.recognize_sphinx(audio).lower()
                print("You said:", command)
                process_command(command)
            except sr.UnknownValueError:
                print("Sorry, could not understand audio.")

if __name__ == "__main__":
    main()