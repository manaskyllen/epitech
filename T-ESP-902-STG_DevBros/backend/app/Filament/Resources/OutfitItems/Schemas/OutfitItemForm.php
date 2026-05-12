<?php

namespace App\Filament\Resources\OutfitItems\Schemas;

use Filament\Forms\Components\Select;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class OutfitItemForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Item outfit')
                    ->schema([
                        Select::make('outfit_id')
                            ->label('Outfit')
                            ->relationship('outfit', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),
                        Select::make('clothing_id')
                            ->label('Vetement')
                            ->relationship('clothing', 'itemSubtype')
                            ->searchable()
                            ->preload()
                            ->required(),
                    ])
                    ->columns(2),
            ]);
    }
}
