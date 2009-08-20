#!/usr/bin/env python
# -*- coding: utf-8 -*-

from xml.etree import ElementTree
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

        # 係り受け解析の結果を利用し、適切な挿入箇所を判定する
        text = ''
        chunk_list = tree.find('{urn:yahoo:jp:jlp:DAService}Result').find('{urn:yahoo:jp:jlp:DAService}ChunkList')
        for chunk in chunk_list.findall('{urn:yahoo:jp:jlp:DAService}Chunk'):
            morphem_list = chunk.find('{urn:yahoo:jp:jlp:DAService}MorphemList')
            # 動詞が含まれている文節の前に「全裸で」を挿入する
            if u'動詞' in [morphem.find('{urn:yahoo:jp:jlp:DAService}POS').text for morphem in morphem_list]:
                # 動詞→接続助詞 文節切れて 動詞 と繋がる場合をどうにかしたい
                # 例：帰ってくる
                text += u'全裸で'.encode('utf-8')
            else:
                # 動詞がなくても「名詞+助動詞する」を捕捉する
                for i in range(len(morphem_list) - 1):
                    if u'名詞' == morphem_list[i].find('{urn:yahoo:jp:jlp:DAService}POS').text and u'助動詞する' == morphem_list[i + 1].find('{urn:yahoo:jp:jlp:DAService}Feature').text.split(',')[1]:
                        text += u'全裸で'.encode('utf-8')
                        break

            # 形態素を繋げ直す
            for morphem in morphem_list:
                text += morphem.find('{urn:yahoo:jp:jlp:DAService}Surface').text.encode('utf-8')

        return text
