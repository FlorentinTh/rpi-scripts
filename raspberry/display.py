#!/usr/bin/python

from RPLCD import CharLCD
import socket
import fcntl
import struct
import time

lcd = CharLCD(cols=16, rows=2, pin_rs=37, pin_e=35, pins_data=[33, 31, 29, 23])


def get_ip_address(ifname):
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        return socket.inet_ntoa(fcntl.ioctl(
                s.fileno(),
                0x8915,
                struct.pack('256s', ifname[:15])
        )[20:24])

lcd.cursor_pos = (0, 4)
lcd.write_string(u"Hello :)")
time.sleep(2)
lcd.clear()
lcd.write_string(socket.gethostname())
lcd.cursor_pos = (1, 0)


def display_ip():
        lcd.clear()
        lcd.write_string(socket.gethostname())
        lcd.cursor_pos = (1, 0)

        try:
                lcd.write_string(get_ip_address('eth0'))
        except IOError:
                try:
                        lcd.write_string(get_ip_address('usb0'))
                except IOError:
                        lcd.write_string("Resolving IP...")
                        time.sleep(1)
                        display_ip()


display_ip()