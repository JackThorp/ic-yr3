#! /usr/bin/python

from TOSSIM import *
import sys

t = Tossim([]);
t.addChannel("MyBlinkC", sys.stdout);
t.addChannel("LedsC", sys.stdout);

m = t.getNode(1);
m.bootAtTime(10);

x = 100;
while (x > 0):
    t.runNextEvent();
    x=x-1;

