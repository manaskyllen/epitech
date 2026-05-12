<?php

namespace App\Http\Controllers;

use Illuminate\Routing\Controller;
use App\Models\Clothing;
use App\Models\ClothingModel;
use App\Models\User;
use App\Services\ClothingService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

/**
 * @group Clothings
 *
 * Endpoints for managing clothings.
 */
class ClothingController extends Controller
{
    public function index()
    {
        $clothings = Clothing::all();

        if ($clothings->isEmpty()) {
            return response()->json(['message' => 'No clothing items found'], 404);
        }

        return response()->json($clothings, 200);
    }

    public function show($id)
    {
        $clothing = Clothing::find($id);

        if (empty($clothing)) {
            return response()->json(['message' => 'Clothing item not found'], 404);
        }

        return response()->json($clothing, 200);
    }

    public function getClothingByUserId($userId)
    {
        $user = User::find($userId);

        if (empty($user)) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $clothings = $user->clothings;

        if ($clothings->isEmpty()) {
            return response()->json(['message' => 'No clothing items found for this user'], 404);
        }

        return response()->json($clothings, 200);
    }

    public function AIResult(Request $request, ClothingService $aiService)
    {
        $request->validate([
            'file' => 'required|image|max:5120', // 5MB max
        ]);

        // Analyse de l'IA
        $aiData = $aiService->inspect($request->file('file'));

        if (!$aiData) {
            return response()->json(['message' => 'AI Inspection failed'], 500);
        }

        // On retourne simplement les résultats de l'IA au front-end
        return response()->json([
            'message' => 'AI Inspection successful',
            'data' => [
                'itemType' => $aiData['itemType'],
                'itemSubtype' => $aiData['itemSubtype'],
                'texture' => $aiData['texture'],
                'color' => $aiData['color'],
                'season' => $aiData['season'],
                'size' => $aiData['size'],
                'gender' => $aiData['gender'],
                'style' => $aiData['style'],
                // On peut aussi suggérer le chemin du GLB ici sans le créer en DB
                'suggested_glb' => "templates/{$aiData['itemSubtype']}.glb"
            ]
        ], 200);
    }

    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'itemType' => 'required|string|max:255',
            'itemSubtype' => 'required|string|max:255',
            'color' => 'sometimes|string|max:255',
            'size' => 'sometimes|string|max:255',
            'style' => 'sometimes|string|max:255',
            'season' => 'sometimes|string|max:255',
            'gender' => 'sometimes|string|max:255',
            'texture' => 'sometimes|string|max:255',
            'user_id' => 'sometimes|exists:users,id',
            'file' => 'required|image|max:5120'
        ]);

        $subtype = $validatedData['itemSubtype'];
        $templateFileName = "templates/{$subtype}.glb";

        $clothingModel = ClothingModel::firstOrCreate(
            ['name' => $subtype],
            [
                'model' => $templateFileName,
                'texture' => $validatedData['texture'] ?? null,
                'slots' => ($validatedData['itemType'] === 'top') ? 'body' : 'legs'
            ]
        );

        $clothingData = array_merge($validatedData, [
            'user_id' => $validatedData['user_id'] ?? auth()->id(),
            'clothingModel_id' => $clothingModel->id,
        ]);

        $clothing = Clothing::create($clothingData);

        $file = $request->file('file');

        $fileName = "{$clothing->id}.jpeg";

        $path = Storage::disk('minio')->putFileAs('', $file, $fileName);
        
        return response()->json([
            'message' => 'Clothing and Model processed successfully',
            'data' => $clothing->load('clothingModel') // On charge la relation pour confirmation
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $clothing = Clothing::find($id);

        if (empty($clothing)) {
            return response()->json(['message' => 'Clothing item not found'], 404);
        }

        $request->validate([
            'itemType' => 'sometimes|string|max:255|in:top,bottom,accessories,shoes,Headwear',
            'itemSubtype' => 'sometimes|string|max:255|in:T-shirt,Tank top,Blouse,Sweatshirt,Sweater,Cardigan,Jeans,Pants,Shorts,Skirt,Leggings,Dress,Jumpsuit,Jacket,Coat,Trench coat,Puffer jacket,Swimsuit,Bra,Panties,Pajamas,Sneakers,Boots,Sandals,Heels,Hat,Scarf,Belt,Bag',
            'color' => 'sometimes|string|max:255',
            'size' => 'sometimes|string|max:255',
            'style' => 'sometimes|string|max:255',
            'season' => 'sometimes|string|max:255|in:Spring,Summer,Autumn,Winter',
            'fabric' => 'sometimes|string|max:255',
            'gender' => 'sometimes|string|max:255|in:male,female,unisex',
            'texture' => 'sometimes|string|max:255',
            'user_id' => 'sometimes|exists:users,id',
            'clothingModel_id' => 'sometimes|exists:clothing_models,id',
        ]);

        $clothing->update($request->all());

        return response()->json($clothing, 200);
    }

    public function destroy($id)
    {
        $clothing = Clothing::find($id);

        if (empty($clothing)) {
            return response()->json(['message' => 'Clothing item not found'], 404);
        }

        $clothing->delete();

        return response()->json(['message' => 'Clothing item deleted successfully'], 204);
    }
}
