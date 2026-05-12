<?php

namespace App\DTOs;

final readonly class GeneratedTextureResultDto
{
    public function __construct(
        public AssetFileDataDto $texture,
        public ?AssetFileDataDto $palettePreview,
        public string $baseTextureSharedPath,
        public array $meta = [],
    ) {
    }

    public function toArray(): array
    {
        return [
            'texture' => $this->texture->toArray(),
            'palette_preview' => $this->palettePreview?->toArray(),
            'base_texture_shared_path' => $this->baseTextureSharedPath,
            'meta' => $this->meta,
        ];
    }
}
