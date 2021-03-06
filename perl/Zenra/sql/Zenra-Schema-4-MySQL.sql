-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Mon Jul 19 13:24:29 2010
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `status`;

--
-- Table: `status`
--
CREATE TABLE `status` (
  `id` BIGINT NOT NULL,
  `text` text NOT NULL,
  `screen_name` VARCHAR(20) NOT NULL,
  `profile_image` VARCHAR(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `protected` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8;

DROP TABLE IF EXISTS `user`;

--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` INTEGER unsigned NOT NULL,
  `screen_name` VARCHAR(20) NOT NULL,
  `access_token` VARCHAR(64) NOT NULL,
  `access_token_secret` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8;

SET foreign_key_checks=1;

