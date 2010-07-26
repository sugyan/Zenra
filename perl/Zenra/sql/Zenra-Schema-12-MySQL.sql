-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Tue Jul 27 02:09:43 2010
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
  `short_url` VARCHAR(32),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

DROP TABLE IF EXISTS `user`;

--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` INTEGER unsigned NOT NULL,
  `screen_name` VARCHAR(20) NOT NULL,
  `token` VARCHAR(40) NOT NULL,
  `access_token` VARCHAR(64) NOT NULL,
  `access_token_secret` VARCHAR(64) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

DROP TABLE IF EXISTS `favorite`;

--
-- Table: `favorite`
--
CREATE TABLE `favorite` (
  `id` INTEGER unsigned NOT NULL,
  `user` INTEGER unsigned NOT NULL,
  `status` BIGINT NOT NULL,
  `created_at` datetime NOT NULL,
  INDEX `favorite_idx_status` (`status`),
  INDEX `favorite_idx_user` (`user`),
  PRIMARY KEY (`id`),
  UNIQUE `user_status` (`user`, `status`),
  CONSTRAINT `favorite_fk_status` FOREIGN KEY (`status`) REFERENCES `status` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `favorite_fk_user` FOREIGN KEY (`user`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

SET foreign_key_checks=1;

