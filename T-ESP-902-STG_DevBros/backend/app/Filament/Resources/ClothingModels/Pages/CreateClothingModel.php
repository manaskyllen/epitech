<?php

namespace App\Filament\Resources\ClothingModels\Pages;

use App\Filament\Resources\ClothingModels\ClothingModelResource;
use Filament\Resources\Pages\CreateRecord;

class CreateClothingModel extends CreateRecord
{
    protected static string $resource = ClothingModelResource::class;
}
