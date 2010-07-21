-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Wed Jul 21 11:12:42 2010
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
  `name` VARCHAR(64) NOT NULL,
  `profile_image` VARCHAR(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `protected` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

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
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

DROP TABLE IF EXISTS `spread`;

--
-- Table: `spread`
--
CREATE TABLE `spread` (
  `id` BIGINT NOT NULL,
  `user` INTEGER unsigned NOT NULL,
  `status` BIGINT NOT NULL,
  `created_at` datetime NOT NULL,
  INDEX `spread_idx_status` (`status`),
  INDEX `spread_idx_user` (`user`),
  UNIQUE `user_status` (`user`, `status`),
  CONSTRAINT `spread_fk_status` FOREIGN KEY (`status`) REFERENCES `status` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `spread_fk_user` FOREIGN KEY (`user`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

SET foreign_key_checks=1;

