/*
  Warnings:

  - You are about to drop the column `order` on the `PostMedia` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "PostMedia_postId_order_idx";

-- AlterTable
ALTER TABLE "PostMedia" DROP COLUMN "order",
ADD COLUMN     "order_index" INTEGER NOT NULL DEFAULT 0;

-- CreateIndex
CREATE INDEX "PostMedia_postId_order_index_idx" ON "PostMedia"("postId", "order_index");
