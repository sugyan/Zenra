#!/usr/bin/env python
# -*- coding: utf-8 -*-

RESULT       = '{urn:yahoo:jp:jlp:DAService}Result'
CHUNK_LIST   = '{urn:yahoo:jp:jlp:DAService}ChunkList'
CHUNK        = '{urn:yahoo:jp:jlp:DAService}Chunk'
MORPHEM_LIST = '{urn:yahoo:jp:jlp:DAService}MorphemList'
SURFACE      = '{urn:yahoo:jp:jlp:DAService}Surface'
FEATURE      = '{urn:yahoo:jp:jlp:DAService}Feature'
VERB = u'動詞'
NOUN = u'名詞'
AUXI = u'助動詞'
CONJ = u'接続助詞'
SURU = u'助動詞する'
ZENRA = u'全裸で'.encode('utf-8')

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

            # 動詞が含まれている文節の前に挿入する
            if VERB in [morphem['feature'][0] for morphem in morphem_list]:
                should_insert = True
                try:
                    if (morphem_list[0]['feature'][0] == VERB and
                        # 動詞で終わる文節に動詞で始まる文節が続いた場合は除外
                        ((chunk_list[-1][-1]['feature'][0] == VERB) or
                         # 動詞→接続助詞で終わる文節に動詞で始まる文節が続いた場合は除外
                         (chunk_list[-1][-1]['feature'][1] == CONJ and
                          chunk_list[-1][-2]['feature'][0] == VERB) or
                         # 動詞→助動詞で終わる文節に動詞で始まる文節が続いた場合は除外
                         (chunk_list[-1][-1]['feature'][0] == AUXI and
                          chunk_list[-1][-2]['feature'][0] == VERB))
                        ):
                        should_insert = False
                except IndexError:
                    pass
                if should_insert:
                        text += ZENRA
            # 動詞が含まれていなくても、名詞→助動詞する の組み合わせがあれば挿入する
            else:
                for i in range(len(morphem_list) - 1):
                    if (morphem_list[i]['feature'][0] == NOUN and
                        morphem_list[i + 1]['feature'][1] == SURU):
                        text += ZENRA

            for morphem in morphem_list:
                text += morphem['surface']

            chunk_list.append(morphem_list)

        return text
