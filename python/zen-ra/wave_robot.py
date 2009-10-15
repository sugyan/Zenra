#/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import yaml
from zenra import Zenra
from waveapi import events
from waveapi import model
from waveapi import robot


def OnBlipSubmitted(properties, context):
    blip = context.GetBlipById(properties['blipId'])
    text = blip.GetDocument().GetText()
    # config.yamlから設定情報を取得
    #     ---
    #     robot:
    #       appid: **************
    config_data = yaml.load(open('config.yaml'))
    zenra = Zenra(appid = config_data['robot']['appid'])
    zenra_text = zenra.zenrize(text).decode('utf-8')
    logging.debug(text)
    logging.debug(zenra_text)
    # 全裸になってなければ何もしない
    if text == zenra_text:
        return
    blip.GetDocument().SetText(zenra_text)

if __name__ == '__main__':
    logging.getLogger().setLevel(logging.DEBUG)
    zenra_robot = robot.Robot(
        'zen-ra',
        image_url   = 'http://zen-ra.appspot.com/icon.png',
        version     = '1',
        profile_url = 'http://zen-ra.appspot.com/'
    )
    zenra_robot.RegisterHandler(events.BLIP_SUBMITTED, OnBlipSubmitted)
    zenra_robot.Run()
