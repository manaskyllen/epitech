<?php

namespace App\Http\Controllers;

use App\Models\OutfitItem;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

/**
 * @group Outfits Items
 *
 * Endpoints for managing outfits items.
 */
class OutfitItemController extends Controller
{
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'outfit_id' => 'required|exists:outfits,id',
            'clothing_id' => 'required|exists:clothing,id',
        ]);

        OutfitItem::create($validatedData);

        $outfitItem = OutfitItem::create($request->all());


        return response()->json([$outfitItem], 201);
    }

    public function destroy($id)
    {
        $outfitItem = OutfitItem::find($id);

        if (empty($outfitItem)) {
            return response()->json(['message' => 'Outfit item not found'], 404);
        }

        $outfitItem->delete();

        return response()->json(['message' => 'Outfit item deleted successfully'], 204);
    }
}
