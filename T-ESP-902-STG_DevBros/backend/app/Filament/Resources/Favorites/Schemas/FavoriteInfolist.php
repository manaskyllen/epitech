<?php

namespace App\Filament\Resources\Favorites\Schemas;

use App\Models\Favorite;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class FavoriteInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Favori')
                    ->schema([
                        TextEntry::make('user.full_name')
                            ->label('Utilisateur')
                            ->default('-'),
                        TextEntry::make('user.email')
                            ->label('Email')
                            ->default('-'),
                        TextEntry::make('target_type')
                            ->label('Type')
                            ->state(fn (Favorite $record): string => $record->clothing_id ? 'Vetement' : ($record->outfit_id ? 'Outfit' : 'Incomplet')),
                        TextEntry::make('clothing.itemSubtype')
                            ->label('Vetement')
                            ->default('-'),
                        TextEntry::make('outfit.name')
                            ->label('Outfit')
                            ->default('-'),
                        TextEntry::make('created_at')
                            ->label('Cree le')
                            ->dateTime(),
                    ])
                    ->columns(2),
            ]);
    }
}
