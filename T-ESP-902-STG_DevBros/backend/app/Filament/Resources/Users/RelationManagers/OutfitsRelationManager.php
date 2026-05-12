<?php

namespace App\Filament\Resources\Users\RelationManagers;

use App\Models\Outfit;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class OutfitsRelationManager extends RelationManager
{
    protected static string $relationship = 'outfits';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->label('Nom')
                    ->required()
                    ->maxLength(255),
            ]);
    }

    public function infolist(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('name')->label('Nom'),
                TextEntry::make('items_total')
                    ->label('Items')
                    ->state(fn (Outfit $record): int => $record->outfitItems()->count()),
                TextEntry::make('favorites_total')
                    ->label('Favoris')
                    ->state(fn (Outfit $record): int => $record->favorites()->count()),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('name')
            ->columns([
                TextColumn::make('name')
                    ->label('Nom')
                    ->searchable(),
                TextColumn::make('outfit_items_count')
                    ->label('Items')
                    ->counts('outfitItems'),
                TextColumn::make('favorites_count')
                    ->label('Favoris')
                    ->counts('favorites'),
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
