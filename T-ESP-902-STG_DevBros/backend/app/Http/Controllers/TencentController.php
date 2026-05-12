<?php

namespace App\Http\Controllers;

use App\DTOs\AssetFileDataDto;
use App\Http\Requests\TencentRequest;
use App\Models\Clothing;
use App\Models\ClothingModel;
use App\Services\ClothingAssetService;
use App\Services\TextureGenerationService;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Throwable;

class TencentController
{
    public function convertImageOnGlb(
        TencentRequest $request,
        ClothingAssetService $clothingAssetService,
        TextureGenerationService $textureGenerationService
    )
    {
        try {
            $validated = $request->validated();
            $file = $request->file('file');
            $photoSharedPath = $file->store('inspirations', 'shared_data');

            $assets = $clothingAssetService->prepareAssets($validated['itemType'], $validated['itemSubtype']);
            $defaultTexture = $assets->defaultTexture()?->key;

            $clothingModel = ClothingModel::firstOrNew([
                'name' => $validated['itemSubtype'],
                'slots' => $validated['itemType'],
            ]);

            $clothingModel->model = $assets->model->key;
            $clothingModel->texture = $defaultTexture;
            $clothingModel->save();

            $clothing = Clothing::create([
                'itemType' => $validated['itemType'],
                'itemSubtype' => $validated['itemSubtype'],
                'user_id' => $validated['user_id'],
                'color' => $validated['color'] ?? $validated['front_color'] ?? null,
                'texture' => $defaultTexture,
                'clothingModel_id' => $clothingModel->id,
            ]);

            $referencePhotoKey = sprintf(
                'references/%s/%d.%s',
                Str::of($validated['itemSubtype'])->lower()->slug(''),
                $clothing->id,
                $file->getClientOriginalExtension()
            );

            if (!Storage::disk('minio')->put($referencePhotoKey, Storage::disk('shared_data')->get($photoSharedPath))) {
                throw new \RuntimeException('Unable to store reference photo in MinIO');
            }

            $generatedTexture = $textureGenerationService->generate(
                photoSharedPath: $photoSharedPath,
                baseTexture: $assets->defaultTexture(),
                itemType: $validated['itemType'],
                itemSubtype: $validated['itemSubtype'],
                clothingId: $clothing->id,
                options: array_filter([
                    'size' => $validated['size'] ?? null,
                    'direction' => $validated['direction'] ?? null,
                    'palette_size' => $validated['palette_size'] ?? null,
                    'noise' => $validated['noise'] ?? null,
                    'detail_strength' => $validated['detail_strength'] ?? null,
                    'gradient_strength' => $validated['gradient_strength'] ?? null,
                    'seed' => $validated['seed'] ?? null,
                    'color' => $validated['color'] ?? null,
                    'front_color' => $validated['front_color'] ?? null,
                ], static fn (mixed $value): bool => $value !== null),
            );

            $clothing->texture = $generatedTexture->texture->key;
            $clothing->color = $validated['color']
                ?? $validated['front_color']
                ?? ($generatedTexture->meta['applied_color'] ?? $generatedTexture->meta['dominant_color'] ?? $clothing->color);
            $clothing->save();

            $availableTextures = $assets->textures;
            $availableTextureKeys = array_map(
                static fn (AssetFileDataDto $texture): string => $texture->key,
                $availableTextures
            );
            if (!in_array($generatedTexture->texture->key, $availableTextureKeys, true)) {
                $availableTextures[] = $generatedTexture->texture;
            }

            $referencePhoto = new AssetFileDataDto(
                key: $referencePhotoKey,
                filename: basename($referencePhotoKey),
                source: 'minio',
                url: url('/api/minio-assets/' . ltrim($referencePhotoKey, '/')),
                sharedPath: $photoSharedPath,
            );

            return response()->json([
                'message' => 'Assets prepared and texture generated successfully',
                'data' => [
                    'clothing' => $clothing,
                    'model' => $assets->model->toArray(),
                    'reference_photo' => $referencePhoto->toArray(),
                    'available_textures' => array_map(
                        static fn (AssetFileDataDto $texture): array => $texture->toArray(),
                        $availableTextures
                    ),
                    'generated_texture' => $generatedTexture->texture->toArray(),
                    'palette_preview' => $generatedTexture->palettePreview?->toArray(),
                    'python_inputs' => [
                        'photo' => $photoSharedPath,
                        'model' => $assets->model->sharedPath,
                        'base_texture' => $generatedTexture->baseTextureSharedPath,
                    ],
                    'generation_meta' => $generatedTexture->meta,
                ],
            ], 200);
        } catch (Throwable $th) {
            Log::error('Tencent convertImageOnGlb failed', [
                'message' => $th->getMessage(),
                'exception' => $th::class,
                'file' => $th->getFile(),
                'line' => $th->getLine(),
                'itemType' => $request->input('itemType'),
                'itemSubtype' => $request->input('itemSubtype'),
                'user_id' => $request->input('user_id'),
                'has_file' => $request->hasFile('file'),
                'file_name' => $request->file('file')?->getClientOriginalName(),
                'content_type' => $request->header('Content-Type'),
            ]);

            return response()->json([
                'message' => 'Error preparing clothing assets',
                'error' => $th->getMessage(),
                'exception' => $th::class,
                'file' => $th->getFile(),
                'line' => $th->getLine(),
                'request_context' => [
                    'itemType' => $request->input('itemType'),
                    'itemSubtype' => $request->input('itemSubtype'),
                    'user_id' => $request->input('user_id'),
                    'size' => $request->input('size'),
                    'direction' => $request->input('direction'),
                    'palette_size' => $request->input('palette_size'),
                    'noise' => $request->input('noise'),
                    'detail_strength' => $request->input('detail_strength'),
                    'gradient_strength' => $request->input('gradient_strength'),
                    'seed' => $request->input('seed'),
                    'content_type' => $request->header('Content-Type'),
                    'has_file' => $request->hasFile('file'),
                    'file_name' => $request->file('file')?->getClientOriginalName(),
                    'file_mime' => $request->file('file')?->getMimeType(),
                    'file_size' => $request->file('file')?->getSize(),
                ],
                'trace' => array_map(
                    static fn (array $frame): array => [
                        'file' => $frame['file'] ?? null,
                        'line' => $frame['line'] ?? null,
                        'function' => $frame['function'],
                        'class' => $frame['class'] ?? null,
                    ],
                    array_slice($th->getTrace(), 0, 10)
                ),
            ], 500);
        }
    }
}
