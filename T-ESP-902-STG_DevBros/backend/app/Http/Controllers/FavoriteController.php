<?php

namespace App\Http\Controllers;

use App\Models\Favorite;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

/**
 * @group Favorites
 *
 * Endpoints for managing favorites.
 */
class FavoriteController extends Controller
{
    public function index()
    {
        $favorites = Favorite::all();

        if ($favorites->isEmpty()) {
            return response()->json(['message' => 'No favorites found'], 404);
        }

        return response()->json($favorites, 200);
    }

    public function show($id)
    {
        $favorite = Favorite::find($id);

        if (empty($favorite)) {
            return response()->json(['message' => 'Favorite not found'], 404);
        }

        return response()->json($favorite, 200);
    }

    public function getFavoritesByUserId($userId)
    {
       $user = User::find($userId);

        if (empty($user)) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $favorites = $user->favorites;

        if ($favorites->isEmpty()) {
            return response()->json(['message' => 'No favorites found for this user'], 404);
        }

        return response()->json($favorites, 200);
    }

    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'clothing_id' => 'nullable|exists:clothing,id',
            'outfit_id' => 'nullable|exists:outfits,id',
        ]);

        $favorite = Favorite::create($request->all());

        return response()->json($favorite, 201);
    }

    public function update(Request $request, $id)
    {
        $favorite = Favorite::find($id);

        if (empty($favorite)) {
            return response()->json(['message' => 'Favorite not found'], 404);
        }

        $request->validate([
            'user_id' => 'sometimes|exists:users,id',
            'clothing_id' => 'sometimes|nullable|exists:clothing,id',
            'outfit_id' => 'sometimes|nullable|exists:outfits,id',
        ]);

        $favorite->update($request->all());

        return response()->json($favorite, 200);
    }

    public function destroy($id)
    {
        $favorite = Favorite::find($id);

        if (empty($favorite)) {
            return response()->json(['message' => 'Favorite not found'], 404);
        }

        $favorite->delete();

        return response()->json(['message' => 'Favorite deleted successfully'], 204);
    }   
}
