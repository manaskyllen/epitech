<?php

namespace App\Filament\Resources\Outfits\Schemas;

use App\Models\Outfit;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class OutfitInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Outfit')
                    ->schema([
                        TextEntry::make('name')
                            ->label('Nom'),
                        TextEntry::make('user.full_name')
                            ->label('Utilisateur')
                            ->default('-'),
                        TextEntry::make('user.email')
                            ->label('Email')
                            ->default('-'),
                        TextEntry::make('items_total')
                            ->label('Items')
                            ->state(fn (Outfit $record): int => $record->outfitItems()->count()),
                        TextEntry::make('favorites_total')
                            ->label('Favoris')
                            ->state(fn (Outfit $record): int => $record->favorites()->count()),
                        TextEntry::make('created_at')
                            ->label('Cree le')
                            ->dateTime(),
                    ])
                    ->columns(3),
            ]);
    }
}
