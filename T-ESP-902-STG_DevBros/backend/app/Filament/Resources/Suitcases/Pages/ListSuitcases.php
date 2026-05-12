<?php

namespace App\Filament\Resources\Suitcases\Pages;

use App\Filament\Resources\Suitcases\SuitcaseResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListSuitcases extends ListRecords
{
    protected static string $resource = SuitcaseResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
