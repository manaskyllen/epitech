<?php

namespace App\Http\Controllers;

use App\Models\Suitcase;
use App\Models\Clothing;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use App\Services\WeatherService;
use App\Services\SuitcaseGenerator;

/**
 * @group Suitcases
 * Gestion des valises de l'utilisateur (CRUD + vêtements).
 */
class SuitcaseController extends Controller
{
    /**
     * Liste toutes les valises de l'utilisateur
     *
     * @authenticated
     *
     * @response 200 scenario="success" {
     *   {
     *     "id": 1,
     *     "name": "Voyage Paris",
     *     "departure_date": "2025-10-28",
     *     "end_date": "2025-10-30",
     *     "destination": "Paris",
     *     "clothings": [...]
     *   }
     * }
     */
    public function index(Request $request)
    {
        $suitcases = $request->user()
            ->suitcases()
            ->with('clothings')
            ->get();

        return response()->json($suitcases);
    }


    /**
     * Créer une valise et générer les vêtements recommandés
     *
     * @authenticated
     *
     * @bodyParam name string required Nom de la valise. Example: Vacances Paris
     * @bodyParam departure_date date required Date de départ. Example: 2025-10-28
     * @bodyParam end_date date required Date de retour. Example: 2025-10-30
     * @bodyParam destination string required Destination. Example: Paris
     *
     * @response 201 scenario="success" {
     *   "id": 1,
     *   "name": "Vacances Paris",
     *   "destination": "Paris",
     *   "clothings": [...]
     * }
     */
    public function store(
        Request $request,
        WeatherService $weatherService,
        SuitcaseGenerator $suitcaseGenerator
    ) {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'departure_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:departure_date',
            'destination' => 'required|string|max:255',
        ]);

        $suitcase = Suitcase::create([
            ...$validated,
            'user_id' => $request->user()->id,
        ]);

        $forecast = $weatherService->getWeather(
            $suitcase->destination,
            $suitcase->departure_date->format('Y-m-d'),
            $suitcase->end_date->format('Y-m-d')
        );

        $generatorResult = $suitcaseGenerator->generate($suitcase, $forecast, $request->user()->id);

        $finalResponse = array_merge($generatorResult, [
            'weather' => $forecast
        ]);

        return response()->json($finalResponse, 201);
    }


    /**
     * Affiche une valise
     *
     * @authenticated
     * @urlParam id integer required L'ID de la valise. Example: 1
     *
     * @response 200 scenario="success" {
     *   "id": 1,
     *   "name": "Vacances Paris",
     *   "clothings": [...]
     * }
     * @response 404 {"message": "Suitcase not found"}
     */
    public function show($id)
    {
        $suitcase = Suitcase::find($id);

        if (empty($suitcase)) {
            return response()->json(['message' => 'Suitcase not found.'], 404);
        }

        return response()->json($suitcase->load('clothings'));
    }


    /**
     * Mettre à jour une valise
     *
     * @authenticated
     * @urlParam id integer required ID de la valise. Example: 1
     *
     * @bodyParam name string Nom de la valise.
     * @bodyParam departure_date date Date de départ.
     * @bodyParam end_date date Date de retour.
     * @bodyParam destination string Destination.
     *
     * @response 200 scenario="success" {
     *   "message": "Suitcase updated",
     *   "data": {...}
     * }
     */
    public function update($id, Request $request)
    {
        $suitcase = Suitcase::find($id);

        if (empty($suitcase)) {
            return response()->json(['message' => 'Suitcase not found.'], 404);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'departure_date' => 'sometimes|date',
            'end_date' => 'sometimes|date|after_or_equal:departure_date',
            'destination' => 'sometimes|string|max:255',
        ]);

        $suitcase->update($validated);

        return response()->json($suitcase->load('clothings'));
    }


    /**
     * Supprimer une valise
     *
     * @authenticated
     * @urlParam id integer required L'ID de la valise. Example: 1
     *
     * @response 200 {"message": "Valise supprimée avec succès"}
     * @response 404 {"message": "Suitcase not found"}
     */
    public function destroy($id)
    {
        $suitcase = Suitcase::find($id);

        if (empty($suitcase)) {
            return response()->json(['message' => 'Suitcase not found.'], 404);
        }

        $suitcase->clothings()->detach();
        $suitcase->delete();

        return response()->json(['message' => 'Valise supprimée avec succès']);
    }


    /**
     * Ajouter un vêtement à la valise
     *
     * @authenticated
     * @urlParam id integer required Id de la valise. Example: 1
     *
     * @bodyParam clothing_id integer required Id du vêtement. Example: 3
     *
     * @response 200 {
     *   "message": "Clothe add into suitcase",
     *   "suitcase": {...}
     * }
     */
    public function addClothing(Request $request, $id)
    {
        $suitcase = Suitcase::find($id);

        if (empty($suitcase)) {
            return response()->json(['message' => 'Valise introuvable.'], 404);
        }

        $validated = $request->validate([
            'clothing_id' => 'required|exists:clothing,id',
        ]);

        $clothing = Clothing::where('id', $validated['clothing_id'])
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $suitcase->clothings()->syncWithoutDetaching([$clothing->id]);

        return response()->json([
            'message' => 'Clothe add into suitcase',
            'suitcase' => $suitcase->load('clothings'),
        ]);
    }


    /**
     * Retirer un vêtement d'une valise
     *
     * @authenticated
     * @urlParam id integer required Id de la valise. Example: 1
     *
     * @bodyParam clothing_id integer required Id du vêtement. Example: 3
     *
     * @response 200 {
     *   "message": "Clothe remove from suitcase",
     *   "suitcase": {...}
     * }
     */
    public function removeClothing(Request $request, $id)
    {
        $suitcase = Suitcase::find($id);

        if (empty($suitcase)) {
            return response()->json(['message' => 'Suitcase not found.'], 404);
        }

        $validated = $request->validate([
            'clothing_id' => 'required|exists:clothing,id',
        ]);

        $clothing = Clothing::where('id', $validated['clothing_id'])
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $suitcase->clothings()->detach($clothing->id);

        return response()->json([
            'message' => 'Clothe remove from suitcase',
            'suitcase' => $suitcase->load('clothings'),
        ]);
    }
}
