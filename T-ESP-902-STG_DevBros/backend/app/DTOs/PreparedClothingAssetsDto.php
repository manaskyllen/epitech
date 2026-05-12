<?php

namespace App\DTOs;

final readonly class PreparedClothingAssetsDto
{
    /**
     * @param AssetFileDataDto[] $textures
     */
    public function __construct(
        public AssetFileDataDto $model,
        public array $textures,
    ) {
    }

    public function defaultTexture(): ?AssetFileDataDto
    {
        return $this->textures[0] ?? null;
    }

    public function toArray(): array
    {
        return [
            'model' => $this->model->toArray(),
            'textures' => array_map(
                static fn (AssetFileDataDto $texture): array => $texture->toArray(),
                $this->textures
            ),
        ];
    }
}
