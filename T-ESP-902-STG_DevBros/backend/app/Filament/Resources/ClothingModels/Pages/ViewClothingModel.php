<?php

namespace App\Filament\Resources\ClothingModels\Pages;

use App\Filament\Resources\ClothingModels\ClothingModelResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewClothingModel extends ViewRecord
{
    protected static string $resource = ClothingModelResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
