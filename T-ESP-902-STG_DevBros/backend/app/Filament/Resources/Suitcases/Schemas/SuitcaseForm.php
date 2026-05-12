<?php

namespace App\Filament\Resources\Suitcases\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class SuitcaseForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Valise')
                    ->schema([
                        Select::make('user_id')
                            ->label('Utilisateur')
                            ->relationship('user', 'email')
                            ->searchable()
                            ->preload()
                            ->required(),
                        TextInput::make('name')
                            ->label('Nom')
                            ->required()
                            ->maxLength(255),
                        TextInput::make('destination')
                            ->label('Destination')
                            ->required()
                            ->maxLength(255),
                        DatePicker::make('departure_date')
                            ->label('Date de depart')
                            ->required(),
                        DatePicker::make('end_date')
                            ->label('Date de fin')
                            ->required(),
                    ])
                    ->columns(2),
            ]);
    }
}
