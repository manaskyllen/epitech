<?php

namespace App\Filament\Resources\Suitcases\Pages;

use App\Filament\Resources\Suitcases\SuitcaseResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditSuitcase extends EditRecord
{
    protected static string $resource = SuitcaseResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
