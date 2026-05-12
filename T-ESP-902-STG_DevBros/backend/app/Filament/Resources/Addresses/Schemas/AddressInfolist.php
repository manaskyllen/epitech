<?php

namespace App\Filament\Resources\Addresses\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class AddressInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Adresse')
                    ->schema([
                        TextEntry::make('user.full_name')
                            ->label('Utilisateur')
                            ->default('-'),
                        TextEntry::make('user.email')
                            ->label('Email')
                            ->default('-'),
                        TextEntry::make('street1')
                            ->label('Adresse 1'),
                        TextEntry::make('street2')
                            ->label('Adresse 2')
                            ->default('-'),
                        TextEntry::make('city')
                            ->label('Ville'),
                        TextEntry::make('zipCode')
                            ->label('Code postal'),
                        TextEntry::make('country')
                            ->label('Pays'),
                        TextEntry::make('created_at')
                            ->label('Cree le')
                            ->dateTime(),
                    ])
                    ->columns(2),
            ]);
    }
}
