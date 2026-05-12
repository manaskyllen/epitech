<?php

namespace App\Http\Controllers;

use App\Models\ClothingModel;
use App\Service\GlbService;
use App\Services\ClothingAssetService;
use Illuminate\Routing\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Throwable;

/**
 * @group Clothings Models
 *
 * Endpoints for managing clothings models.
 */
class ClothingModelController extends Controller
{
    public function index()
    {
        $clothingModels = ClothingModel::all();

        if ($clothingModels->isEmpty()) {
            return response()->json(['message' => 'No clothing models found'], 404);
        }

        return response()->json($clothingModels, 200);
    }

    public function show($id)
    {
        $clothingModel = ClothingModel::find($id);

        if (empty($clothingModel)) {
            return response()->json(['message' => 'Clothing model not found'], 404);
        }

        return response()->json($clothingModel, 200);
    }

    public function update(Request $request, $id)
    {
        $clothingModel = ClothingModel::find($id);

        if (empty($clothingModel)) {
            return response()->json(['message' => 'Clothing model not found'], 404);
        }

        $validatedData = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'model' => 'sometimes|required|string|max:255',
            'texture' => 'sometimes|required|string|max:255',
            'slots' => 'sometimes|required|string|max:255',
        ]);

        $clothingModel->update($validatedData);

        return response()->json($clothingModel, 200);
    }

    public function destroy($id)
    {
        $clothingModel = ClothingModel::find($id);

        if (empty($clothingModel)) {
            return response()->json(['message' => 'Clothing model not found'], 404);
        }

        $clothingModel->delete();

        return response()->json(['message' => 'Clothing model deleted successfully'], 204);
    }

    public function store(Request $request)
    {
        if (!$request->hasFile('model3d') || !$request->file('model3d')->isValid()) {
            return response()->json(['message' => 'No valid file uploaded'], 400);
        }

        $request->validate([
            'model3d' => 'required|file|mimes:glb|max:51200', // max 50MB
        ]);

        $slots = $request->input('slots', 'unknown_slots');

        $file = $request->file('model3d');

        // Sauvegarder le fichier dans le dossier storage/app/public/models
        $path = Storage::disk('public')->put('models', $file);

        // Lire les données du fichier
        $data = file_get_contents($file->getRealPath());

        $glbService = new GlbService();
        $parsedData = $glbService->parseGlbFile($data);

        if ($parsedData === null) {
            return response()->json(['message' => 'Invalid GLB file'], 400);
        }

        $clothingModel = ClothingModel::create([
            'name' => $parsedData['name'],
            'model' => $path,
            'texture' => $parsedData['texture'],
            'slots' => $slots
        ]);

        $clothingModel->save();

        return response()->json([
            'message' => 'GLB file uploaded and parsed successfully',
            'model_name' => $parsedData['name'],
            'default_texture' => $parsedData['texture'],
            'path' => $path,
        ], 201);
    }

    public function getModelFile(int $id, ClothingAssetService $clothingAssetService)
    {
        $clothingModel = ClothingModel::find($id);

        if (empty($clothingModel)) {
            return response()->json(['message' => 'Clothing model not found'], 404);
        }

        $modelPath = trim((string) $clothingModel->model);

        if ($modelPath === '') {
            return response()->json(['message' => 'Model file is not configured'], 404);
        }

        try {
            if (Storage::disk('minio')->exists($modelPath)) {
                $minioFileContent = Storage::disk('minio')->get($modelPath);

                if ($minioFileContent !== '') {
                    return response($minioFileContent, 200)
                        ->header('Content-Type', 'model/gltf-binary')
                        ->header('Content-Disposition', 'inline; filename="' . basename($modelPath) . '"');
                }
            }
        } catch (Throwable) {
            // Fallback to local public storage for templates that are not in MinIO.
        }

        if (filter_var($modelPath, FILTER_VALIDATE_URL)) {
            try {
                $response = Http::timeout(10)->get($modelPath);

                if ($response->successful() && $response->body() !== '') {
                    $contentType = $response->header('Content-Type');
                    if ($contentType === '') {
                        $contentType = 'model/gltf-binary';
                    }

                    return response($response->body(), 200)
                        ->header('Content-Type', $contentType)
                        ->header('Content-Disposition', 'inline; filename="' . basename(Str::before($modelPath, '?')) . '"');
                }
            } catch (Throwable) {
                // Fallback to 404 below.
            }
        }

        $localCandidates = [
            public_path($modelPath),
            storage_path('app/public/' . ltrim($modelPath, '/')),
        ];

        foreach ($localCandidates as $filePath) {
            if (!is_file($filePath) || filesize($filePath) === 0) {
                continue;
            }

            return response()->file($filePath, [
                'Content-Type' => 'model/gltf-binary',
                'Content-Disposition' => 'inline; filename="' . basename($filePath) . '"',
            ]);
        }

        try {
            $resolvedModel = $clothingAssetService->resolveModelAsset(
                (string) ($clothingModel->slots ?? ''),
                (string) $clothingModel->name
            );

            if ($resolvedModel->source === 'minio') {
                $resolvedContent = Storage::disk('minio')->get($resolvedModel->key);

                if ($resolvedContent !== '') {
                    return response($resolvedContent, 200)
                        ->header('Content-Type', 'model/gltf-binary')
                        ->header('Content-Disposition', 'inline; filename="' . $resolvedModel->filename . '"');
                }
            }

            if ($resolvedModel->source === 'public') {
                $resolvedPath = public_path($resolvedModel->key);

                if (is_file($resolvedPath) && filesize($resolvedPath) > 0) {
                    return response()->file($resolvedPath, [
                        'Content-Type' => 'model/gltf-binary',
                        'Content-Disposition' => 'inline; filename="' . basename($resolvedPath) . '"',
                    ]);
                }
            }
        } catch (Throwable) {
            // Fall through to 404 when legacy values cannot be resolved.
        }

        return response()->json(['message' => 'File not found'], 404);
    }

    public function getAssets(int $id, ClothingAssetService $clothingAssetService)
    {
        $clothingModel = ClothingModel::find($id);

        if (empty($clothingModel)) {
            return response()->json(['message' => 'Clothing model not found'], 404);
        }

        return response()->json([
            'data' => $clothingAssetService
                ->assetsForModel(
                    $clothingModel->model,
                    $clothingModel->slots,
                    $clothingModel->name,
                    $clothingModel->texture
                )
                ->toArray(),
        ], 200);
    }
}
