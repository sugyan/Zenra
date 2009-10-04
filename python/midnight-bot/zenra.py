#!/usr/bin/env python
# -*- coding: utf-8 -*-

RESULT       = '{urn:yahoo:jp:jlp:DAService}Result'
CHUNK_LIST   = '{urn:yahoo:jp:jlp:DAService}ChunkList'
CHUNK        = '{urn:yahoo:jp:jlp:DAService}Chunk'
MORPHEM_LIST = '{urn:yahoo:jp:jlp:DAService}MorphemList'
SURFACE      = '{urn:yahoo:jp:jlp:DAService}Surface'
FEATURE      = '{urn:yahoo:jp:jlp:DAService}Feature'
NOUN = u'名詞'
NIGHT = u'夜の'.encode('utf-8')
MIDNIGHT = u'真夜中の'.encode('utf-8')

from xml.etree import ElementTree
import random
import urllib
import yaml


class Zenra:
    def __init__(self, appid = None):
        # config.yamlから設定情報を取得
        #     ---
        #     appid: ********
        self.appid = appid
        if not appid:
            config_data = yaml.load(open('../config.yaml'))
            self.appid = config_data['appid']
        self.url   = 'http://jlp.yahooapis.jp/DAService/V1/parse'
        
    def zenrize(self, sentence):
        postdata = {
            'appid'    : self.appid,
            'sentence' : sentence.encode('utf-8'),
            }
        params = urllib.urlencode(postdata)
        result = urllib.urlopen(self.url, params)
        tree = ElementTree.XML(result.read())

        # 係り受け解析の結果を利用し、適切な箇所に"全裸で"を挿入
        text = ''
        chunk_list = []
        for chunk in tree.find(RESULT).find(CHUNK_LIST).findall(CHUNK):
            morphem_list = []
            for morphem in chunk.find(MORPHEM_LIST):
                morphem_list.append({
                        'surface' : morphem.find(SURFACE).text.encode('utf-8'),
                        'feature' : morphem.find(FEATURE).text.split(',')[:2],
                        })
            # 先頭が名詞で始まる文節を見つける
            if morphem_list[0]['feature'][0] == NOUN:
                # 50%の確率で「夜の」を挿入
                if random.randint(0, 1) == 0:
                    insert = NIGHT
                    # 10%の確率で「真夜中の」に
                    if random.randint(0, 10) == 0:
                        insert = MIDNIGHT
                    text += insert
            for morphem in morphem_list:
                text += morphem['surface']

            chunk_list.append(morphem_list)

        return text
