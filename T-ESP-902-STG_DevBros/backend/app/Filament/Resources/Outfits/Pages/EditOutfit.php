<?php

namespace App\Filament\Resources\Outfits\Pages;

use App\Filament\Resources\Outfits\OutfitResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditOutfit extends EditRecord
{
    protected static string $resource = OutfitResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
