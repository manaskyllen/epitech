<?php

namespace App\Filament\Resources\ClothingModels;

use App\Filament\Resources\ClothingModels\Pages\CreateClothingModel;
use App\Filament\Resources\ClothingModels\Pages\EditClothingModel;
use App\Filament\Resources\ClothingModels\Pages\ListClothingModels;
use App\Filament\Resources\ClothingModels\Pages\ViewClothingModel;
use App\Filament\Resources\ClothingModels\Schemas\ClothingModelForm;
use App\Filament\Resources\ClothingModels\Schemas\ClothingModelInfolist;
use App\Filament\Resources\ClothingModels\Tables\ClothingModelsTable;
use App\Models\ClothingModel;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class ClothingModelResource extends Resource
{
    protected static ?string $model = ClothingModel::class;

    protected static ?string $recordTitleAttribute = 'name';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCube;

    protected static string|UnitEnum|null $navigationGroup = 'Dressing';

    protected static ?int $navigationSort = 2;

    protected static ?string $modelLabel = 'modele 3D';

    protected static ?string $pluralModelLabel = 'modeles 3D';

    public static function form(Schema $schema): Schema
    {
        return ClothingModelForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return ClothingModelInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return ClothingModelsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListClothingModels::route('/'),
            'create' => CreateClothingModel::route('/create'),
            'view' => ViewClothingModel::route('/{record}'),
            'edit' => EditClothingModel::route('/{record}/edit'),
        ];
    }
}
