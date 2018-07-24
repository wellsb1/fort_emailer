drop table if exists ListAddress;
drop table if exists ListSequence;
drop table if exists List;
drop table if exists SequenceMessage;
drop table if exists Sender;
drop table if exists Sequence;
drop table if exists Message;


CREATE TABLE Sender
(
    `id` BIGINT         unsigned NOT NULL auto_increment,
    `fromAddress`       VARCHAR(512),
    `fromPersonal`      VARCHAR(512),
    `smtpProps`         text,
    `lastModified`      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
    PRIMARY KEY(`id`) 
)
ENGINE = InnoDB;

CREATE TABLE Sequence
(
    `id` BIGINT unsigned NOT NULL auto_increment,
    `name`     VARCHAR(512),
    `lastModified` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
    PRIMARY KEY(`id`) 
)
ENGINE = InnoDB;


CREATE TABLE Message
(
    `id` BIGINT unsigned NOT NULL auto_increment,
    `subject`    VARCHAR(1025),
    `body`      LONGTEXT,
    `lastModified` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(`id`) 
)
ENGINE = InnoDB;


CREATE TABLE SequenceMessage
(
    `id` BIGINT     unsigned NOT NULL auto_increment,
    `sequenceId`    BIGINT unsigned,
    `messageId`     BIGINT unsigned,
    `order`         INT,
    `lastModified`  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_SequenceMessage_Sequence_id` FOREIGN KEY (`sequenceId`) REFERENCES `Sequence` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_SequenceMessage_Message_id` FOREIGN KEY (`messageId`) REFERENCES `Message` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY(`id`) 
)
ENGINE = InnoDB;



CREATE TABLE List
(
    `id`            BIGINT unsigned NOT NULL auto_increment,
    `name`          VARCHAR(512),
    `senderId`      BIGINT unsigned,
    `lastModified`  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
    PRIMARY KEY(`id`) 
)
ENGINE = InnoDB;



CREATE TABLE ListAddress
(
    `id`            BIGINT unsigned NOT NULL auto_increment,
    `listId`        BIGINT unsigned,
    `address`       VARCHAR(512),
    `type`          VARCHAR(10),
    `lastModified`  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_ListAddress_List_id` FOREIGN KEY (`listId`) REFERENCES `List` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY(`id`) 
)
ENGINE = InnoDB;



CREATE TABLE ListSequence
(
    `id`           BIGINT unsigned NOT NULL auto_increment,
    `listId`       BIGINT unsigned,
    `sequenceId`   BIGINT unsigned,
    `next`         INT,
    `lastModified` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
    CONSTRAINT `fk_ListSequence_List_id` FOREIGN KEY (`listId`) REFERENCES `List` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_ListSequence_Sequence_id` FOREIGN KEY (`sequenceId`) REFERENCES `Sequence` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY(`id`) 
)
ENGINE = InnoDB;









