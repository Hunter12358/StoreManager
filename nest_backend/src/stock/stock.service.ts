import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateStockDto } from './dto/update-stock.dto';

@Injectable()
export class StockService {
  constructor(private prisma: PrismaService) {}

  async update(productId: number, dto: UpdateStockDto) {
    return this.prisma.$transaction(async (transaction) => {
      const product = await transaction.product.findUnique({
        where: { id: productId },
      });

      if (!product) {
        throw new NotFoundException('Product not found');
      }

      const stock = await transaction.stock.upsert({
        where: { productId },
        create: { productId, quantity: product.quantity },
        update: {},
      });
      const quantity = stock.quantity + dto.quantityChange;

      if (quantity < 0) {
        throw new BadRequestException('Stock cannot be negative');
      }

      await transaction.stock.update({
        where: { productId },
        data: { quantity, reason: dto.reason },
      });

      return transaction.product.update({
        where: { id: productId },
        data: { quantity },
        include: { category: true },
      });
    });
  }
}