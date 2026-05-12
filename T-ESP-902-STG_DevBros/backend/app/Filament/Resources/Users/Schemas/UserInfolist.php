<?php

namespace App\Filament\Resources\Users\Schemas;

use App\Models\User;
use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class UserInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Profil')
                    ->schema([
                        ImageEntry::make('profilePictureUrl')
                            ->label('Photo')
                            ->circular(),
                        TextEntry::make('full_name')
                            ->label('Nom complet'),
                        TextEntry::make('email')
                            ->label('Email'),
                        TextEntry::make('sso')
                            ->label('SSO')
                            ->default('-'),
                        TextEntry::make('email_verified_at')
                            ->label('Email verifie')
                            ->dateTime()
                            ->placeholder('-'),
                    ])
                    ->columns(2),
                Section::make('Etat du compte')
                    ->schema([
                        IconEntry::make('isActif')
                            ->label('Actif')
                            ->boolean(),
                        IconEntry::make('newsletter')
                            ->label('Newsletter')
                            ->boolean(),
                        IconEntry::make('is_admin')
                            ->label('Admin')
                            ->boolean(),
                        TextEntry::make('created_at')
                            ->label('Cree le')
                            ->dateTime(),
                        TextEntry::make('updated_at')
                            ->label('Mis a jour le')
                            ->dateTime(),
                    ])
                    ->columns(3),
                Section::make('Activite')
                    ->schema([
                        TextEntry::make('addresses_total')
                            ->label('Adresses')
                            ->state(fn (User $record): int => $record->addresses()->count()),
                        TextEntry::make('clothings_total')
                            ->label('Vetements')
                            ->state(fn (User $record): int => $record->clothings()->count()),
                        TextEntry::make('outfits_total')
                            ->label('Outfits')
                            ->state(fn (User $record): int => $record->outfits()->count()),
                        TextEntry::make('favorites_total')
                            ->label('Favoris')
                            ->state(fn (User $record): int => $record->favorites()->count()),
                        TextEntry::make('suitcases_total')
                            ->label('Valises')
                            ->state(fn (User $record): int => $record->suitcases()->count()),
                    ])
                    ->columns(5),
            ]);
    }
}
