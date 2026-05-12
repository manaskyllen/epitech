<?php

namespace App\Filament\Resources\Users\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class UsersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('firstname')
                    ->label('Prenom')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('lastname')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('email')
                    ->label('Email')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('addresses_count')
                    ->label('Adresses')
                    ->counts('addresses')
                    ->sortable(),
                TextColumn::make('clothings_count')
                    ->label('Vetements')
                    ->counts('clothings')
                    ->sortable(),
                TextColumn::make('outfits_count')
                    ->label('Outfits')
                    ->counts('outfits')
                    ->sortable()
                    ->toggleable(),
                TextColumn::make('suitcases_count')
                    ->label('Valises')
                    ->counts('suitcases')
                    ->sortable()
                    ->toggleable(),
                IconColumn::make('isActif')
                    ->label('Actif')
                    ->boolean(),
                IconColumn::make('is_admin')
                    ->label('Admin')
                    ->boolean(),
                IconColumn::make('newsletter')
                    ->label('Newsletter')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('email_verified_at')
                    ->label('Verifie')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
                TextColumn::make('created_at')
                    ->label('Cree le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                TernaryFilter::make('isActif')->label('Actif'),
                TernaryFilter::make('is_admin')->label('Admin'),
                TernaryFilter::make('newsletter')->label('Newsletter'),
            ])
            ->defaultSort('created_at', 'desc')
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
