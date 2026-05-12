<?php

namespace App\Filament\Resources\Clothing\Pages;

use App\Filament\Resources\Clothing\ClothingResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewClothing extends ViewRecord
{
    protected static string $resource = ClothingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
