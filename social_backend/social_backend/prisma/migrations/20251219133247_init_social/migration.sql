/*
  Warnings:

  - You are about to drop the column `order_index` on the `PostMedia` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "PostMedia_postId_order_index_idx";

-- AlterTable
ALTER TABLE "PostMedia" DROP COLUMN "order_index",
ADD COLUMN     "order" INTEGER NOT NULL DEFAULT 0;

-- CreateIndex
CREATE INDEX "PostMedia_postId_order_idx" ON "PostMedia"("postId", "order");
