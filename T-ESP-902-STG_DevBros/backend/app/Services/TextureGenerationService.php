<?php

namespace App\Services;

use App\DTOs\AssetFileDataDto;
use App\DTOs\GeneratedTextureResultDto;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class TextureGenerationService
{
    private function textureGenerationEndpoint(): string
    {
        return rtrim((string) config('services.texture_generation.url'), '/') . '/generate';
    }

    public function generate(
        string $photoSharedPath,
        ?AssetFileDataDto $baseTexture,
        string $itemType,
        string $itemSubtype,
        int $clothingId,
        array $options = [],
    ): GeneratedTextureResultDto {
        $typeDirectory = $this->resolveTypeDirectory($itemType);
        $subtypeSlug = $this->resolveSubtypeSlug($itemSubtype);

        $baseTextureSharedPath = $baseTexture !== null
            ? $this->cacheAssetInSharedData($baseTexture, "base-textures/{$typeDirectory}/{$subtypeSlug}")
            : $this->ensureDefaultBaseTexture($typeDirectory, $subtypeSlug);

        $token = Str::lower(Str::random(8));
        $textureSharedPath = "generated-textures/{$typeDirectory}/{$subtypeSlug}/{$clothingId}_{$token}.png";
        $paletteSharedPath = "generated-textures/{$typeDirectory}/{$subtypeSlug}/{$clothingId}_{$token}_palette.png";

        $payload = array_filter([
            'photo' => $photoSharedPath,
            'base' => $baseTextureSharedPath,
            'out' => $textureSharedPath,
            'palette_preview' => $paletteSharedPath,
            'item_type' => $itemType,
            'item_subtype' => $itemSubtype,
            'size' => $options['size'] ?? null,
            'direction' => $options['direction'] ?? null,
            'palette_size' => $options['palette_size'] ?? null,
            'noise' => $options['noise'] ?? null,
            'detail_strength' => $options['detail_strength'] ?? null,
            'gradient_strength' => $options['gradient_strength'] ?? null,
            'seed' => $options['seed'] ?? null,
            'color' => $options['color'] ?? null,
            'front_color' => $options['front_color'] ?? null,
        ], static fn (mixed $value): bool => $value !== null);

        $response = Http::timeout(180)->post($this->textureGenerationEndpoint(), $payload);

        if ($response->failed()) {
            throw new \RuntimeException('Python texture generation failed: ' . $response->body());
        }

        if (!Storage::disk('shared_data')->exists($textureSharedPath)) {
            throw new \RuntimeException("Generated texture file missing: {$textureSharedPath}");
        }

        $textureKey = "textures/{$typeDirectory}/{$subtypeSlug}/" . basename($textureSharedPath);
        if (!Storage::disk('minio')->put($textureKey, Storage::disk('shared_data')->get($textureSharedPath))) {
            throw new \RuntimeException('Unable to upload generated texture to MinIO');
        }

        $palettePreview = null;
        if (Storage::disk('shared_data')->exists($paletteSharedPath)) {
            $paletteKey = "textures/{$typeDirectory}/{$subtypeSlug}/" . basename($paletteSharedPath);
            if (!Storage::disk('minio')->put($paletteKey, Storage::disk('shared_data')->get($paletteSharedPath))) {
                throw new \RuntimeException('Unable to upload generated palette preview to MinIO');
            }

            $palettePreview = new AssetFileDataDto(
                key: $paletteKey,
                filename: basename($paletteKey),
                source: 'minio',
                url: url('/api/minio-assets/' . ltrim($paletteKey, '/')),
                sharedPath: $paletteSharedPath,
            );
        }

        return new GeneratedTextureResultDto(
            texture: (new AssetFileDataDto(
                key: $textureKey,
                filename: basename($textureKey),
                source: 'minio',
                url: url('/api/minio-assets/' . ltrim($textureKey, '/')),
                sharedPath: $textureSharedPath,
            ))->withSelected(),
            palettePreview: $palettePreview,
            baseTextureSharedPath: $baseTextureSharedPath,
            meta: $response->json('meta') ?? [],
        );
    }

    private function cacheAssetInSharedData(AssetFileDataDto $asset, string $directory): string
    {
        $sharedPath = "{$directory}/{$asset->filename}";

        if (Storage::disk('shared_data')->exists($sharedPath)) {
            return $sharedPath;
        }

        if ($asset->source === 'minio') {
            Storage::disk('shared_data')->put($sharedPath, Storage::disk('minio')->get($asset->key));
            return $sharedPath;
        }

        Storage::disk('shared_data')->put($sharedPath, file_get_contents(public_path($asset->key)));

        return $sharedPath;
    }

    private function ensureDefaultBaseTexture(string $typeDirectory, string $subtypeSlug): string
    {
        $sharedPath = "base-textures/{$typeDirectory}/{$subtypeSlug}/default.png";

        if (Storage::disk('shared_data')->exists($sharedPath)) {
            return $sharedPath;
        }

        $absolutePath = Storage::disk('shared_data')->path($sharedPath);
        $directory = dirname($absolutePath);
        if (!is_dir($directory)) {
            mkdir($directory, 0777, true);
        }

        $image = imagecreatetruecolor(1024, 1024);
        $baseColor = imagecolorallocate($image, 232, 232, 232);
        $lineColor = imagecolorallocate($image, 214, 214, 214);
        imagefill($image, 0, 0, $baseColor);

        for ($x = 0; $x < 1024; $x += 48) {
            imageline($image, $x, 0, $x, 1024, $lineColor);
        }

        for ($y = 0; $y < 1024; $y += 48) {
            imageline($image, 0, $y, 1024, $y, $lineColor);
        }

        imagepng($image, $absolutePath);
        imagedestroy($image);

        return $sharedPath;
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

    private function resolveSubtypeSlug(string $itemSubtype): string
    {
        return Str::of($itemSubtype)
            ->lower()
            ->replace(['-', ' '], '')
            ->value();
    }
}
