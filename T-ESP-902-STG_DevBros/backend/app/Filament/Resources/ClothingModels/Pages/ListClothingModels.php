<?php

namespace App\Filament\Resources\ClothingModels\Pages;

use App\Filament\Resources\ClothingModels\ClothingModelResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListClothingModels extends ListRecords
{
    protected static string $resource = ClothingModelResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
