import { IsInt, IsString, MinLength, NotEquals } from 'class-validator';

export class UpdateStockDto {
  @IsInt()
  @NotEquals(0)
  quantityChange!: number;

  @IsString()
  @MinLength(1)
  reason!: string;
}