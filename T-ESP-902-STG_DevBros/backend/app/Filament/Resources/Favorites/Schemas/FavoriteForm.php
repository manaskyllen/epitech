<?php

namespace App\Filament\Resources\Favorites\Schemas;

use Filament\Forms\Components\Select;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class FavoriteForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Favori')
                    ->schema([
                        Select::make('user_id')
                            ->label('Utilisateur')
                            ->relationship('user', 'email')
                            ->searchable()
                            ->preload()
                            ->required(),
                        Select::make('clothing_id')
                            ->label('Vetement')
                            ->relationship('clothing', 'itemSubtype')
                            ->searchable()
                            ->preload(),
                        Select::make('outfit_id')
                            ->label('Outfit')
                            ->relationship('outfit', 'name')
                            ->searchable()
                            ->preload(),
                    ])
                    ->columns(2),
            ]);
    }
}
