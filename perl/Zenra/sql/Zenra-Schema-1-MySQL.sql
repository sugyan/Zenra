-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Mon Jul 19 03:12:32 2010
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `user`;

--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` INTEGER unsigned NOT NULL,
  PRIMARY KEY (`id`)
);

SET foreign_key_checks=1;

