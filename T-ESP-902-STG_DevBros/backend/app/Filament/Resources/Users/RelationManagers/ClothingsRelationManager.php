<?php

namespace App\Filament\Resources\Users\RelationManagers;

use App\Support\AdminOptions;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ClothingsRelationManager extends RelationManager
{
    protected static string $relationship = 'clothings';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('clothingModel_id')
                    ->label('Modele 3D')
                    ->relationship('clothingModel', 'name')
                    ->searchable()
                    ->preload()
                    ->required(),
                Select::make('itemType')
                    ->label('Type')
                    ->options(AdminOptions::clothingItemTypes())
                    ->required(),
                Select::make('itemSubtype')
                    ->label('Sous-type')
                    ->options(AdminOptions::clothingItemSubtypes())
                    ->searchable()
                    ->required(),
                TextInput::make('color')
                    ->label('Couleur')
                    ->maxLength(255),
                TextInput::make('size')
                    ->label('Taille')
                    ->maxLength(255),
                Select::make('season')
                    ->label('Saison')
                    ->options(AdminOptions::seasons()),
                Select::make('gender')
                    ->label('Genre')
                    ->options(AdminOptions::genders()),
            ]);
    }

    public function infolist(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('itemSubtype')->label('Sous-type'),
                TextEntry::make('itemType')->label('Type'),
                TextEntry::make('clothingModel.name')->label('Modele 3D')->default('-'),
                TextEntry::make('color')->label('Couleur')->default('-'),
                TextEntry::make('size')->label('Taille')->default('-'),
                TextEntry::make('season')->label('Saison')->default('-'),
                TextEntry::make('gender')->label('Genre')->default('-'),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('itemSubtype')
            ->columns([
                TextColumn::make('itemSubtype')
                    ->label('Sous-type')
                    ->badge()
                    ->searchable(),
                TextColumn::make('itemType')
                    ->label('Type')
                    ->badge(),
                TextColumn::make('clothingModel.name')
                    ->label('Modele 3D')
                    ->default('-'),
                TextColumn::make('color')
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
