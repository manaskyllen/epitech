<?php

namespace App\Filament\Resources\Suitcases\RelationManagers;

use Filament\Actions\AttachAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DetachAction;
use Filament\Actions\DetachBulkAction;
use Filament\Actions\ViewAction;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

/**
 * @property \App\Models\Suitcase $ownerRecord
 */
class ClothingsRelationManager extends RelationManager
{
    protected static string $relationship = 'clothings';

    public function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn (Builder $query): Builder => $query->with(['clothingModel']))
            ->recordTitleAttribute('itemSubtype')
            ->columns([
                TextColumn::make('itemSubtype')
                    ->label('Sous-type')
                    ->badge()
                    ->searchable(),
                TextColumn::make('itemType')
                    ->label('Type')
                    ->badge(),
                TextColumn::make('color')
                    ->label('Couleur')
                    ->default('-'),
                TextColumn::make('clothingModel.name')
                    ->label('Modele 3D')
                    ->default('-'),
                TextColumn::make('created_at')
                    ->label('Ajoute le')
                    ->dateTime(),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                AttachAction::make()
                    ->preloadRecordSelect()
                    ->recordSelectSearchColumns(['itemSubtype', 'color'])
                    ->recordSelectOptionsQuery(fn (Builder $query) => $query->where('user_id', $this->ownerRecord->user_id)),
            ])
            ->recordActions([
                ViewAction::make(),
                DetachAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DetachBulkAction::make(),
                ]),
            ]);
    }
}
