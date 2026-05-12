<?php

namespace App\Filament\Resources\Clothing\Tables;

use App\Support\AdminOptions;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class ClothingTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn (Builder $query): Builder => $query->with(['user', 'clothingModel']))
            ->columns([
                TextColumn::make('itemSubtype')
                    ->label('Sous-type')
                    ->badge()
                    ->searchable()
                    ->sortable(),
                TextColumn::make('itemType')
                    ->label('Type')
                    ->badge()
                    ->color(fn (?string $state): string => match ($state) {
                        'top' => 'primary',
                        'bottom' => 'warning',
                        'accessories' => 'success',
                        'shoes' => 'danger',
                        default => 'gray',
                    })
                    ->sortable(),
                TextColumn::make('user.full_name')
                    ->label('Utilisateur')
                    ->default('-'),
                TextColumn::make('user.email')
                    ->label('Email')
                    ->searchable()
                    ->toggleable(),
                TextColumn::make('clothingModel.name')
                    ->label('Modele 3D')
                    ->searchable()
                    ->default('-'),
                TextColumn::make('color')
                    ->label('Couleur')
                    ->searchable()
                    ->default('-'),
                TextColumn::make('size')
                    ->label('Taille')
                    ->default('-'),
                TextColumn::make('season')
                    ->label('Saison')
                    ->default('-')
                    ->toggleable(),
                TextColumn::make('gender')
                    ->label('Genre')
                    ->default('-')
                    ->toggleable(),
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
                SelectFilter::make('itemType')
                    ->label('Type')
                    ->options(AdminOptions::clothingItemTypes()),
                SelectFilter::make('season')
                    ->label('Saison')
                    ->options(AdminOptions::seasons()),
                SelectFilter::make('gender')
                    ->label('Genre')
                    ->options(AdminOptions::genders()),
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
