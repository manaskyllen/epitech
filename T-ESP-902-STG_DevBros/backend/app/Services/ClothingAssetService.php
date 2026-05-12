<?php

namespace App\Services;

use App\DTOs\AssetFileDataDto;
use App\DTOs\PreparedClothingAssetsDto;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Throwable;

class ClothingAssetService
{
    private const MODEL_FILE_NAMES = [
        'T-shirt' => 'tshirt.glb',
        't-shirt' => 'tshirt.glb',
        'tshirt' => 'tshirt.glb',
        'Sweatshirt' => 'sweatshirt.glb',
        'sweatshirt' => 'sweatshirt.glb',
        'Jeans' => 'jeans.glb',
        'jeans' => 'jeans.glb',
        'Jean' => 'jeans.glb',
        'jean' => 'jeans.glb',
        'Shoes' => 'shoes.glb',
        'shoes' => 'shoes.glb',
        'shoe' => 'shoes.glb',
        'Sneakers' => 'shoes.glb',
        'sneakers' => 'shoes.glb',
        'Boots' => 'shoes.glb',
        'boots' => 'shoes.glb',
        'Sandals' => 'shoes.glb',
        'sandals' => 'shoes.glb',
        'Heels' => 'shoes.glb',
        'heels' => 'shoes.glb',
    ];

    public function prepareAssets(string $itemType, string $itemSubtype): PreparedClothingAssetsDto
    {
        $model = $this->resolveModelAsset($itemType, $itemSubtype);
        $model = $model->withSharedPath($this->cacheModelInSharedData($model));

        return new PreparedClothingAssetsDto(
            model: $model,
            textures: $this->listTextureAssets($itemType, $itemSubtype),
        );
    }

    public function assetsForModel(
        string $modelKey,
        ?string $slots,
        string $name,
        ?string $selectedTexture = null
    ): PreparedClothingAssetsDto {
        $textures = $this->listTextureAssets($slots ?: 'top', $name);

        if ($selectedTexture !== null && $selectedTexture !== '') {
            $knownTextureKeys = array_map(
                static fn (AssetFileDataDto $texture): string => $texture->key,
                $textures
            );

            if (!in_array($selectedTexture, $knownTextureKeys, true)) {
                $textures[] = $this->createAssetFileData(
                    key: $selectedTexture,
                    filename: basename($selectedTexture),
                    source: $this->detectAssetSource($selectedTexture),
                )->withSelected();
            }
        }

        return new PreparedClothingAssetsDto(
            model: $this->createAssetFileData(
                key: $modelKey,
                filename: basename($modelKey),
                source: $this->detectAssetSource($modelKey),
            ),
            textures: $textures,
        );
    }

    public function resolveModelAsset(string $itemType, string $itemSubtype): AssetFileDataDto
    {
        $typeDirectory = $this->resolveTypeDirectory($itemType);
        $filename = $this->resolveModelFileName($itemSubtype);

        $primaryMinioKey = "character-assets/clothes/{$typeDirectory}/{$filename}";
        $fallbackMinioKeys = [
            $primaryMinioKey,
            "models/{$filename}",
            $filename,
        ];

        foreach ($fallbackMinioKeys as $key) {
            if ($this->minioExists($key)) {
                return $this->createAssetFileData(
                    key: $key,
                    filename: $filename,
                    source: 'minio',
                );
            }
        }

        $localRelativePath = "character-assets/clothes/{$typeDirectory}/{$filename}";
        $localAbsolutePath = public_path($localRelativePath);

        if (is_file($localAbsolutePath)) {
            if ($this->safeMinioPut($primaryMinioKey, file_get_contents($localAbsolutePath))) {
                return $this->createAssetFileData(
                    key: $primaryMinioKey,
                    filename: $filename,
                    source: 'minio',
                );
            }

            return $this->createAssetFileData(
                key: $localRelativePath,
                filename: $filename,
                source: 'public',
            );
        }

        throw new \RuntimeException("No GLB template found for subtype {$itemSubtype}");
    }

    public function cacheModelInSharedData(AssetFileDataDto $model): string
    {
        $sharedPath = 'models/' . $model->filename;

        if (Storage::disk('shared_data')->exists($sharedPath)) {
            return $sharedPath;
        }

        if ($model->source === 'minio') {
            Storage::disk('shared_data')->put($sharedPath, Storage::disk('minio')->get($model->key));
            return $sharedPath;
        }

        Storage::disk('shared_data')->put($sharedPath, file_get_contents(public_path($model->key)));

        return $sharedPath;
    }

    /**
     * @return AssetFileDataDto[]
     */
    public function listTextureAssets(string $itemType, string $itemSubtype): array
    {
        $typeDirectory = $this->resolveTypeDirectory($itemType);
        $slug = $this->resolveSubtypeSlug($itemSubtype);
        $prefixes = [
            "character-assets/textures/{$typeDirectory}/{$slug}",
            "textures/{$typeDirectory}/{$slug}",
            "textures/{$slug}",
        ];

        $files = [];
        foreach ($prefixes as $prefix) {
            foreach ($this->safeMinioFiles($prefix) as $file) {
                $files[$file] = $this->createAssetFileData(
                    key: $file,
                    filename: basename($file),
                    source: 'minio',
                );
            }
        }

        return array_values($files);
    }

    public function detectAssetSource(string $path): string
    {
        if ($this->minioExists($path)) {
            return 'minio';
        }

        if (is_file(public_path($path))) {
            return 'public';
        }

        return 'unknown';
    }

    public function buildAssetUrl(string $path, string $source): ?string
    {
        return match ($source) {
            'minio' => url('/api/minio-assets/' . ltrim($path, '/')),
            'public' => asset($path),
            default => null,
        };
    }

    private function resolveTypeDirectory(string $itemType): string
    {
        return match ($itemType) {
            'top' => 'top',
            'bottom' => 'bottom',
            'shoes' => 'shoes',
            'accessories' => 'accessories',
            'Headwear' => 'headwear',
            default => Str::of($itemType)->lower()->slug('')->value(),
        };
    }

    private function resolveModelFileName(string $itemSubtype): string
    {
        return self::MODEL_FILE_NAMES[$itemSubtype]
            ?? $this->resolveSubtypeSlug($itemSubtype) . '.glb';
    }

    private function resolveSubtypeSlug(string $itemSubtype): string
    {
        return Str::of($itemSubtype)
            ->lower()
            ->replace(['-', ' '], '')
            ->value();
    }

    private function minioExists(string $path): bool
    {
        try {
            return Storage::disk('minio')->exists($path);
        } catch (Throwable) {
            return false;
        }
    }

    private function safeMinioPut(string $path, string $contents): bool
    {
        try {
            return Storage::disk('minio')->put($path, $contents);
        } catch (Throwable) {
            return false;
        }
    }

    private function safeMinioFiles(string $prefix): array
    {
        try {
            return Storage::disk('minio')->files($prefix);
        } catch (Throwable) {
            return [];
        }
    }

    private function createAssetFileData(
        string $key,
        string $filename,
        string $source,
        ?string $sharedPath = null,
        bool $selected = false
    ): AssetFileDataDto {
        return new AssetFileDataDto(
            key: $key,
            filename: $filename,
            source: $source,
            url: $this->buildAssetUrl($key, $source),
            sharedPath: $sharedPath,
            selected: $selected,
        );
    }
}
