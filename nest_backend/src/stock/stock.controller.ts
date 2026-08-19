import {
  Body,
  Controller,
  Param,
  ParseIntPipe,
  Patch,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../auth/admin.guard';
import { UpdateStockDto } from './dto/update-stock.dto';
import { StockService } from './stock.service';

@Controller(['stock', 'api/stock'])
export class StockController {
  constructor(private readonly stockService: StockService) {}

  @UseGuards(JwtAuthGuard, AdminGuard)
  @Patch([':productId', ':productId/stock'])
  update(
    @Param('productId', ParseIntPipe) productId: number,
    @Body() dto: UpdateStockDto,
  ) {
    return this.stockService.update(productId, dto);
  }
}