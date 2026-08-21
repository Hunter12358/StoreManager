import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSaleDto } from './dto/create-sale.dto';

@Injectable()
export class SalesService {
  constructor(private readonly prisma: PrismaService) {}

  async completeSale(dto: CreateSaleDto) {
    return this.prisma.$transaction(async (tx) => {
      const cashier = await tx.user.findUnique({
        where: { id: dto.cashierId },
      });

      if (!cashier) {
        throw new NotFoundException('Cashier not found');
      }

      const saleItems: Array<{
        productId: number;
        quantity: number;
        unitPrice: number;
      }> = [];
      let total = 0;

      for (const item of dto.items) {
        if (item.quantity <= 0) {
          throw new BadRequestException('Each item quantity must be greater than 0');
        }

        const product = await tx.product.findUnique({
          where: { id: item.productId },
          include: { stock: true },
        });

        if (!product) {
          throw new NotFoundException(`Product ${item.productId} not found`);
        }

        const availableStock = product.stock?.quantity ?? product.quantity ?? 0;

        if (availableStock < item.quantity) {
          throw new BadRequestException(
            `Insufficient stock for product ${item.productId}. Available: ${availableStock}`,
          );
        }

        total += item.unitPrice * item.quantity;

        saleItems.push({
          productId: item.productId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
        });
      }

      const createdSale = await tx.sale.create({
        data: {
          userId: dto.cashierId,
          total,
          items: {
            create: saleItems,
          },
        },
        include: {
          items: true,
          user: true,
        },
      });

      for (const item of dto.items) {
        const product = await tx.product.findUnique({
          where: { id: item.productId },
          include: { stock: true },
        });

        const currentStock = product?.stock?.quantity ?? product?.quantity ?? 0;
        const newStock = currentStock - item.quantity;

        await tx.stock.upsert({
          where: { productId: item.productId },
          create: {
            productId: item.productId,
            quantity: newStock,
            reason: 'Sale',
          },
          update: {
            quantity: newStock,
            reason: 'Sale',
          },
        });

        await tx.product.update({
          where: { id: item.productId },
          data: { quantity: newStock },
        });
      }

      return tx.sale.findUniqueOrThrow({
        where: { id: createdSale.id },
        include: {
          items: true,
          user: true,
        },
      });
    });
  }
}
