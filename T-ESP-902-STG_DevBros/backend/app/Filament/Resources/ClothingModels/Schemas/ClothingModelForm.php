<?php

namespace App\Filament\Resources\ClothingModels\Schemas;

use App\Support\AdminOptions;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class ClothingModelForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Modele 3D')
                    ->schema([
                        TextInput::make('name')
                            ->label('Nom')
                            ->required()
                            ->maxLength(255),
                        Select::make('slots')
                            ->label('Slot')
                            ->options(AdminOptions::clothingSlots())
                            ->searchable(),
                        TextInput::make('model')
                            ->label('Chemin GLB')
                            ->required()
                            ->maxLength(255),
                        TextInput::make('texture')
                            ->label('Texture par defaut')
                            ->maxLength(255),
                    ])
                    ->columns(2),
            ]);
    }
}
