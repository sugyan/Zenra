#!/usr/bin/env python
# -*- coding: utf-8 -*-

from xml.etree import ElementTree
import urllib


class Zenra:
    def __init__(self):
        self.appid = '****'
        self.url   = 'http://jlp.yahooapis.jp/DAService/V1/parse'
        
    def zenrize(self, sentence):
        postdata = {
            'appid'    : self.appid,
            'sentence' : sentence.encode('utf-8'),
            }
        params = urllib.urlencode(postdata)
        result = urllib.urlopen(self.url, params)

        morpheme_list = []
        # DOM解析 形態素と品詞だけを抽出
        tree = ElementTree.XML(result.read())
        chunk_list = tree.find('{urn:yahoo:jp:jlp:DAService}Result').find('{urn:yahoo:jp:jlp:DAService}ChunkList')
        for chunk in chunk_list.findall('{urn:yahoo:jp:jlp:DAService}Chunk'):
            for morphem in chunk.find('{urn:yahoo:jp:jlp:DAService}MorphemList'):
                morpheme_list.append({
                        'Surface' : morphem.find('{urn:yahoo:jp:jlp:DAService}Surface').text.encode('utf-8'),
                        'POS'     : morphem.find('{urn:yahoo:jp:jlp:DAService}POS').text.encode('utf-8'),
                        })

        # 末尾から見ていって、動詞を検出したら「全裸で」を挿入
        for morpheme in reversed(morpheme_list):
            if morpheme['POS'] == u'動詞'.encode('utf-8'):
                morpheme_list.insert(morpheme_list.index(morpheme), {
                        'Surface' : u'全裸で'.encode('utf-8'),
                        'POS'     : '',
                        })

        return ''.join(morpheme['Surface'] for morpheme in morpheme_list)
