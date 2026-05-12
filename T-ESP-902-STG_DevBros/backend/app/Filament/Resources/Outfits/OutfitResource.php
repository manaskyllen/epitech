<?php

namespace App\Filament\Resources\Outfits;

use App\Filament\Resources\Outfits\Pages\CreateOutfit;
use App\Filament\Resources\Outfits\Pages\EditOutfit;
use App\Filament\Resources\Outfits\Pages\ListOutfits;
use App\Filament\Resources\Outfits\Pages\ViewOutfit;
use App\Filament\Resources\Outfits\RelationManagers\OutfitItemsRelationManager;
use App\Filament\Resources\Outfits\Schemas\OutfitForm;
use App\Filament\Resources\Outfits\Schemas\OutfitInfolist;
use App\Filament\Resources\Outfits\Tables\OutfitsTable;
use App\Models\Outfit;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class OutfitResource extends Resource
{
    protected static ?string $model = Outfit::class;

    protected static ?string $recordTitleAttribute = 'name';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedSparkles;

    protected static string|UnitEnum|null $navigationGroup = 'Dressing';

    protected static ?int $navigationSort = 3;

    protected static ?string $modelLabel = 'outfit';

    protected static ?string $pluralModelLabel = 'outfits';

    public static function form(Schema $schema): Schema
    {
        return OutfitForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return OutfitInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return OutfitsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            OutfitItemsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListOutfits::route('/'),
            'create' => CreateOutfit::route('/create'),
            'view' => ViewOutfit::route('/{record}'),
            'edit' => EditOutfit::route('/{record}/edit'),
        ];
    }
}
