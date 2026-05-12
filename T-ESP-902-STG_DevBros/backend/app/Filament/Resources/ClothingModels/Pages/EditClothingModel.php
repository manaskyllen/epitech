<?php

namespace App\Filament\Resources\ClothingModels\Pages;

use App\Filament\Resources\ClothingModels\ClothingModelResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditClothingModel extends EditRecord
{
    protected static string $resource = ClothingModelResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
