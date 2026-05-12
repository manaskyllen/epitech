<?php

namespace App\Filament\Resources\Outfits\Pages;

use App\Filament\Resources\Outfits\OutfitResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListOutfits extends ListRecords
{
    protected static string $resource = OutfitResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
