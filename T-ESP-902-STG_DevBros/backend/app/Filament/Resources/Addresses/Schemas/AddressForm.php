<?php

namespace App\Filament\Resources\Addresses\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class AddressForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Adresse')
                    ->schema([
                        Select::make('user_id')
                            ->label('Utilisateur')
                            ->relationship('user', 'email')
                            ->searchable()
                            ->preload()
                            ->required(),
                        TextInput::make('street1')
                            ->label('Adresse 1')
                            ->required()
                            ->maxLength(255),
                        TextInput::make('street2')
                            ->label('Adresse 2')
                            ->maxLength(255),
                        TextInput::make('city')
                            ->label('Ville')
                            ->required()
                            ->maxLength(255),
                        TextInput::make('zipCode')
                            ->label('Code postal')
                            ->required()
                            ->maxLength(20),
                        TextInput::make('country')
                            ->label('Pays')
                            ->required()
                            ->maxLength(100),
                    ])
                    ->columns(2),
            ]);
    }
}
