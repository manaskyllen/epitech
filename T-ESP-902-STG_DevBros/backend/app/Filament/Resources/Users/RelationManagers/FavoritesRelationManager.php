<?php

namespace App\Filament\Resources\Users\RelationManagers;

use App\Models\Favorite;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\Select;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class FavoritesRelationManager extends RelationManager
{
    protected static string $relationship = 'favorites';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('clothing_id')
                    ->label('Vetement')
                    ->relationship('clothing', 'itemSubtype')
                    ->searchable()
                    ->preload(),
                Select::make('outfit_id')
                    ->label('Outfit')
                    ->relationship('outfit', 'name')
                    ->searchable()
                    ->preload(),
            ]);
    }

    public function infolist(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('target_type')
                    ->label('Type')
                    ->state(fn (Favorite $record): string => $record->clothing_id ? 'Vetement' : ($record->outfit_id ? 'Outfit' : 'Incomplet')),
                TextEntry::make('clothing.itemSubtype')->label('Vetement')->default('-'),
                TextEntry::make('outfit.name')->label('Outfit')->default('-'),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('id')
            ->columns([
                TextColumn::make('target_type')
                    ->label('Type')
                    ->state(fn (Favorite $record): string => $record->clothing_id ? 'Vetement' : ($record->outfit_id ? 'Outfit' : 'Incomplet'))
                    ->badge(),
                TextColumn::make('clothing.itemSubtype')
                    ->label('Vetement')
                    ->default('-'),
                TextColumn::make('outfit.name')
                    ->label('Outfit')
                    ->default('-'),
                TextColumn::make('created_at')
                    ->label('Cree le')
                    ->dateTime(),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                CreateAction::make(),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
