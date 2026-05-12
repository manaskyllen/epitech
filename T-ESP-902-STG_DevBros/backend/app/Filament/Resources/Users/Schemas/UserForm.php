<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Compte')
                    ->schema([
                        TextInput::make('firstname')
                            ->label('Prenom')
                            ->required()
                            ->maxLength(255),
                        TextInput::make('lastname')
                            ->label('Nom')
                            ->required()
                            ->maxLength(255),
                        TextInput::make('email')
                            ->email()
                            ->required()
                            ->maxLength(255),
                        TextInput::make('profilePictureUrl')
                            ->label('Photo de profil')
                            ->url()
                            ->maxLength(255),
                        TextInput::make('sso')
                            ->label('Provider SSO')
                            ->maxLength(255),
                        TextInput::make('password')
                            ->password()
                            ->revealable()
                            ->required(fn (string $operation): bool => $operation === 'create')
                            ->dehydrated(fn (?string $state): bool => filled($state))
                            ->minLength(8)
                            ->maxLength(255),
                        DateTimePicker::make('email_verified_at')
                            ->label('Email verifie le'),
                    ])
                    ->columns(2),
                Section::make('Statut et permissions')
                    ->schema([
                        Toggle::make('isActif')
                            ->label('Compte actif')
                            ->default(true),
                        Toggle::make('newsletter')
                            ->label('Newsletter'),
                        Toggle::make('is_admin')
                            ->label('Acces admin'),
                    ])
                    ->columns(3),
            ]);
    }
}
