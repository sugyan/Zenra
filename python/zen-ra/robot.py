#/usr/bin/env python
# -*- coding: utf-8 -*-

from waveapi import events 
from waveapi import robot
from zenra import Zenra


def blipSubmitted(properties, context):
    blip = context.GetBlipById(properties['blipId'])
    text = blip.GetDocument().GetText()
    blip.GetDocument().SetText(Zenra().zenrize(text).decode('utf-8'))

if __name__ == '__main__':
    zenra_robot = robot.Robot(
        'zenra_robot', 1.0,
        image_url = 'http://zen-ra.appspot.com/icon.png')
    zenra_robot.RegisterHandler(events.BLIP_SUBMITTED, blipSubmitted)
    zenra_robot.Run()
