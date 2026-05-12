<?php

namespace App\Filament\Resources\OutfitItems\Pages;

use App\Filament\Resources\OutfitItems\OutfitItemResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewOutfitItem extends ViewRecord
{
    protected static string $resource = OutfitItemResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
