<?php

namespace App\Filament\Resources\Outfits\RelationManagers;

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

class OutfitItemsRelationManager extends RelationManager
{
    protected static string $relationship = 'outfitItems';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('clothing_id')
                    ->label('Vetement')
                    ->relationship('clothing', 'itemSubtype')
                    ->searchable()
                    ->preload()
                    ->required(),
            ]);
    }

    public function infolist(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('clothing.itemSubtype')->label('Vetement')->default('-'),
                TextEntry::make('clothing.color')->label('Couleur')->default('-'),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('id')
            ->columns([
                TextColumn::make('clothing.itemSubtype')
                    ->label('Vetement')
                    ->searchable(),
                TextColumn::make('clothing.color')
                    ->label('Couleur')
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
