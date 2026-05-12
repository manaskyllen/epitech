<?php

namespace App\Filament\Resources\OutfitItems\Pages;

use App\Filament\Resources\OutfitItems\OutfitItemResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditOutfitItem extends EditRecord
{
    protected static string $resource = OutfitItemResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
