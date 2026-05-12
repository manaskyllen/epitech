<?php

namespace App\Filament\Resources\ClothingModels\Tables;

use App\Support\AdminOptions;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ClothingModelsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('slots')
                    ->label('Slot')
                    ->badge()
                    ->formatStateUsing(fn (?string $state): string => AdminOptions::clothingSlots()[$state] ?? ($state ?? '-')),
                TextColumn::make('texture')
                    ->label('Texture')
                    ->default('-'),
                TextColumn::make('model')
                    ->label('Chemin GLB')
                    ->limit(40)
                    ->tooltip(fn ($record): ?string => $record->model),
                TextColumn::make('clothings_count')
                    ->label('Vetements')
                    ->counts('clothings')
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label('Cree le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
            ])
            ->filters([
                //
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
