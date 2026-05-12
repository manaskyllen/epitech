<?php

namespace App\Filament\Resources\OutfitItems\Pages;

use App\Filament\Resources\OutfitItems\OutfitItemResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListOutfitItems extends ListRecords
{
    protected static string $resource = OutfitItemResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
