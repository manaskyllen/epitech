<?php

namespace App\Filament\Resources\Suitcases\Pages;

use App\Filament\Resources\Suitcases\SuitcaseResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewSuitcase extends ViewRecord
{
    protected static string $resource = SuitcaseResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
