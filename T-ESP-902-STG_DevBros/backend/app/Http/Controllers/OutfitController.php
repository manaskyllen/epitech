<?php

namespace App\Http\Controllers;

use App\Models\Outfit;
use App\Models\OutfitItem;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

/**
 * @group Outfits
 *
 * Endpoints for managing outfits.
 */
class OutfitController extends Controller
{
    public function index()
    {
        $outfits = Outfit::all();

        if ($outfits->isEmpty()) {
            return response()->json(['message' => 'No outfits found'], 404);
        }

        return response()->json($outfits);
    }   

    public function show($id){
        $outfit = Outfit::find($id);

        if (empty($outfit)) {
            return response()->json(['message' => 'Outfit not found'], 404);
        }

        return response()->json($outfit);
    }

    public function getOutfitsByUserId($userId)
    {
        $user = User::find($userId);

        if (empty($user)) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $outfits = $user->outfits;

        if ($outfits->isEmpty()) {
            return response()->json(['message' => 'No outfits found for this user'], 404);
        }

        return response()->json($outfits);

    }

    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'name' => 'required|string|max:255',
        ]);

        $outfit = Outfit::create($request->all());

        return response()->json($outfit, 201);
    }

    public function update(Request $request, $id)
    {
        $outfit = Outfit::find($id);

        if (empty($outfit)) {
            return response()->json(['message' => 'Outfit not found'], 404);
        }

        $request->validate([
            'user_id' => 'sometimes|required|exists:users,id',
            'name' => 'sometimes|required|string|max:255',
        ]);

        $outfit->update($request->all());

        return response()->json($outfit);
    }

    public function destroy($id)
    {
        $outfit = Outfit::find($id);

        if (empty($outfit)) {
            return response()->json(['message' => 'Outfit not found'], 404);
        }

        $outfit->delete();

        return response()->json(['message' => 'Outfit deleted successfully'], 204);
    }

    public function getClothingByOutfitId($id)
    {
        $clothingItems = OutfitItem::where('outfit_id', $id)->get();
        $clothings = [];

        if ($clothingItems->isEmpty()) {
            return response()->json(['message' => 'No clothing items found for this outfit'], 404);
        }

        foreach ($clothingItems as $clothingItem) {
            array_push($clothings, $clothingItem->clothing);
        }

        return response()->json($clothings);
    }
}
