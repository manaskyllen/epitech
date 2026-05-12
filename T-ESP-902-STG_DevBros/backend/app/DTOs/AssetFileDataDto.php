<?php

namespace App\DTOs;

final readonly class AssetFileDataDto
{
    public function __construct(
        public string $key,
        public string $filename,
        public string $source,
        public ?string $url = null,
        public ?string $sharedPath = null,
        public bool $selected = false,
    ) {
    }

    public function withSharedPath(string $sharedPath): self
    {
        return new self(
            key: $this->key,
            filename: $this->filename,
            source: $this->source,
            url: $this->url,
            sharedPath: $sharedPath,
            selected: $this->selected,
        );
    }

    public function withSelected(bool $selected = true): self
    {
        return new self(
            key: $this->key,
            filename: $this->filename,
            source: $this->source,
            url: $this->url,
            sharedPath: $this->sharedPath,
            selected: $selected,
        );
    }

    public function toArray(): array
    {
        return array_filter([
            'key' => $this->key,
            'filename' => $this->filename,
            'source' => $this->source,
            'shared_path' => $this->sharedPath,
            'url' => $this->url,
            'selected' => $this->selected,
        ], static fn (mixed $value): bool => $value !== null);
    }
}
