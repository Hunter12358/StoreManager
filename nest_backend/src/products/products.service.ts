import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.product.findMany({
      include: {
        category: true,
      },
    });
  }

  async findOne(id: number) {
    return this.prisma.product.findUnique({
      where: { id },
      include: {
        category: true,
      },
    });
  }

  async create(dto: CreateProductDto) {
    return this.prisma.$transaction(async (transaction) => {
      const product = await transaction.product.create({
        data: dto,
      });

      await transaction.stock.create({
        data: {
          productId: product.id,
          quantity: product.quantity,
        },
      });

      return transaction.product.findUniqueOrThrow({
        where: { id: product.id },
        include: { category: true },
      });
    });
  }

  async update(id: number, dto: UpdateProductDto) {
    return this.prisma.$transaction(async (transaction) => {
      const product = await transaction.product.update({
        where: { id },
        data: dto,
      });

      if (dto.quantity !== undefined) {
        await transaction.stock.upsert({
          where: { productId: id },
          create: { productId: id, quantity: product.quantity },
          update: { quantity: product.quantity },
        });
      }

      return transaction.product.findUniqueOrThrow({
        where: { id },
        include: { category: true },
      });
    });
  }

  async remove(id: number) {
    return this.prisma.product.delete({
      where: { id },
    });
  }
}