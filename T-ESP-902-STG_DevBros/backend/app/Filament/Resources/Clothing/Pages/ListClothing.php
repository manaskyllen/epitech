<?php

namespace App\Filament\Resources\Clothing\Pages;

use App\Filament\Resources\Clothing\ClothingResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListClothing extends ListRecords
{
    protected static string $resource = ClothingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
