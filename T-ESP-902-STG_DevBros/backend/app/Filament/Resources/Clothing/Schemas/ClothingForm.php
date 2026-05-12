<?php

namespace App\Filament\Resources\Clothing\Schemas;

use App\Support\AdminOptions;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class ClothingForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Vetement')
                    ->schema([
                        Select::make('user_id')
                            ->label('Utilisateur')
                            ->relationship('user', 'email')
                            ->searchable()
                            ->preload()
                            ->required(),
                        Select::make('clothingModel_id')
                            ->label('Modele 3D')
                            ->relationship('clothingModel', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),
                        Select::make('itemType')
                            ->label('Type')
                            ->options(AdminOptions::clothingItemTypes())
                            ->required(),
                        Select::make('itemSubtype')
                            ->label('Sous-type')
                            ->options(AdminOptions::clothingItemSubtypes())
                            ->searchable()
                            ->required(),
                        TextInput::make('color')
                            ->label('Couleur')
                            ->maxLength(255),
                        TextInput::make('size')
                            ->label('Taille')
                            ->maxLength(255),
                        TextInput::make('style')
                            ->label('Style')
                            ->maxLength(255),
                        Select::make('season')
                            ->label('Saison')
                            ->options(AdminOptions::seasons())
                            ->searchable(),
                        Select::make('gender')
                            ->label('Genre')
                            ->options(AdminOptions::genders()),
                        TextInput::make('fabric')
                            ->label('Matiere')
                            ->maxLength(255),
                        TextInput::make('texture')
                            ->label('Texture')
                            ->maxLength(255),
                    ])
                    ->columns(2),
            ]);
    }
}
