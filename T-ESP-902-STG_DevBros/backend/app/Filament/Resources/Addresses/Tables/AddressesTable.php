<?php

namespace App\Filament\Resources\Addresses\Tables;

use App\Models\Address;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class AddressesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.full_name')
                    ->label('Utilisateur')
                    ->default('-'),
                TextColumn::make('user.email')
                    ->label('Email')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('street1')
                    ->label('Adresse 1')
                    ->searchable(),
                TextColumn::make('city')
                    ->label('Ville')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('zipCode')
                    ->label('Code postal')
                    ->searchable(),
                TextColumn::make('country')
                    ->label('Pays')
                    ->badge()
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label('Cree le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
            ])
            ->filters([
                SelectFilter::make('country')
                    ->label('Pays')
                    ->options(fn (): array => Address::query()
                        ->orderBy('country')
                        ->pluck('country', 'country')
                        ->all()),
                SelectFilter::make('user_id')
                    ->label('Utilisateur')
                    ->relationship('user', 'email'),
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
