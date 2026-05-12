<?php

namespace App\Filament\Resources\Favorites\Tables;

use App\Models\Favorite;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class FavoritesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn (Builder $query): Builder => $query->with(['user', 'clothing', 'outfit']))
            ->columns([
                TextColumn::make('user.full_name')
                    ->label('Utilisateur')
                    ->default('-'),
                TextColumn::make('user.email')
                    ->label('Email')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('target_type')
                    ->label('Type')
                    ->state(fn (Favorite $record): string => $record->clothing_id ? 'Vetement' : ($record->outfit_id ? 'Outfit' : 'Incomplet'))
                    ->badge(),
                TextColumn::make('clothing.itemSubtype')
                    ->label('Vetement')
                    ->default('-')
                    ->searchable(),
                TextColumn::make('outfit.name')
                    ->label('Outfit')
                    ->default('-')
                    ->searchable(),
                TextColumn::make('created_at')
                    ->label('Cree le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
            ])
            ->filters([
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
