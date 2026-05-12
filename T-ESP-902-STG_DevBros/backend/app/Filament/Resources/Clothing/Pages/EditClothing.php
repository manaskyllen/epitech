<?php

namespace App\Filament\Resources\Clothing\Pages;

use App\Filament\Resources\Clothing\ClothingResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditClothing extends EditRecord
{
    protected static string $resource = ClothingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
