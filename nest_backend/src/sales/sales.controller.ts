import {
  Body,
  Controller,
  Post,
  UseGuards,
} from '@nestjs/common';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { CreateSaleDto } from './dto/create-sale.dto';
import { SalesService } from './sales.service';

@Controller(['sales', 'api/sales'])
export class SalesController {
  constructor(private readonly salesService: SalesService) {}

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.CASHIER)
  @Post()
  create(@Body() dto: CreateSaleDto) {
    return this.salesService.completeSale(dto);
  }
}
