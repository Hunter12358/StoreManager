CREATE TABLE `Stock` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `productId` INTEGER NOT NULL,
    `quantity` INTEGER NOT NULL DEFAULT 0,
    `updatedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `Stock_productId_key`(`productId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO `Stock` (`productId`, `quantity`)
SELECT `id`, `quantity` FROM `Product`;

ALTER TABLE `Stock`
ADD CONSTRAINT `Stock_productId_fkey`
FOREIGN KEY (`productId`) REFERENCES `Product`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE;