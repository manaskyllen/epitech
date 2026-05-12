<?php

namespace App\Filament\Resources\Outfits\Pages;

use App\Filament\Resources\Outfits\OutfitResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewOutfit extends ViewRecord
{
    protected static string $resource = OutfitResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
