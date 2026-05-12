<?php

namespace App\Filament\Resources\Clothing\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class ClothingInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Vetement')
                    ->schema([
                        TextEntry::make('display_name')
                            ->label('Nom'),
                        TextEntry::make('itemType')
                            ->label('Type'),
                        TextEntry::make('itemSubtype')
                            ->label('Sous-type'),
                        TextEntry::make('user.full_name')
                            ->label('Utilisateur')
                            ->default('-'),
                        TextEntry::make('user.email')
                            ->label('Email')
                            ->default('-'),
                        TextEntry::make('clothingModel.name')
                            ->label('Modele 3D')
                            ->default('-'),
                        TextEntry::make('color')
                            ->label('Couleur')
                            ->default('-'),
                        TextEntry::make('size')
                            ->label('Taille')
                            ->default('-'),
                        TextEntry::make('style')
                            ->label('Style')
                            ->default('-'),
                        TextEntry::make('season')
                            ->label('Saison')
                            ->default('-'),
                        TextEntry::make('gender')
                            ->label('Genre')
                            ->default('-'),
                        TextEntry::make('fabric')
                            ->label('Matiere')
                            ->default('-'),
                        TextEntry::make('texture')
                            ->label('Texture')
                            ->default('-'),
                    ])
                    ->columns(3),
            ]);
    }
}
