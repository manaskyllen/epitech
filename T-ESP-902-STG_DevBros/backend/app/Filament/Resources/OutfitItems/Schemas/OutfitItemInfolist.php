<?php

namespace App\Filament\Resources\OutfitItems\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class OutfitItemInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Item outfit')
                    ->schema([
                        TextEntry::make('outfit.name')
                            ->label('Outfit')
                            ->default('-'),
                        TextEntry::make('clothing.itemSubtype')
                            ->label('Vetement')
                            ->default('-'),
                        TextEntry::make('clothing.color')
                            ->label('Couleur')
                            ->default('-'),
                        TextEntry::make('created_at')
                            ->label('Cree le')
                            ->dateTime(),
                    ])
                    ->columns(2),
            ]);
    }
}
