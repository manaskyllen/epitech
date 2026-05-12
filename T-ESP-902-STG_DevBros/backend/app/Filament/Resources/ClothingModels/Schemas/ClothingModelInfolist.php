<?php

namespace App\Filament\Resources\ClothingModels\Schemas;

use App\Models\ClothingModel;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class ClothingModelInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Modele 3D')
                    ->schema([
                        TextEntry::make('name')
                            ->label('Nom'),
                        TextEntry::make('slots')
                            ->label('Slot')
                            ->default('-'),
                        TextEntry::make('model')
                            ->label('Chemin GLB'),
                        TextEntry::make('texture')
                            ->label('Texture')
                            ->default('-'),
                        TextEntry::make('clothings_total')
                            ->label('Vetements relies')
                            ->state(fn (ClothingModel $record): int => $record->clothings()->count()),
                        TextEntry::make('created_at')
                            ->label('Cree le')
                            ->dateTime(),
                    ])
                    ->columns(2),
            ]);
    }
}
