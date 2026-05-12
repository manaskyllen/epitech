<?php

namespace App\Filament\Resources\OutfitItems\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class OutfitItemsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn (Builder $query): Builder => $query->with(['outfit', 'clothing']))
            ->columns([
                TextColumn::make('outfit.name')
                    ->label('Outfit')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('clothing.itemSubtype')
                    ->label('Vetement')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('clothing.color')
                    ->label('Couleur')
                    ->default('-'),
                TextColumn::make('created_at')
                    ->label('Cree le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
            ])
            ->filters([
                SelectFilter::make('outfit_id')
                    ->label('Outfit')
                    ->relationship('outfit', 'name'),
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
