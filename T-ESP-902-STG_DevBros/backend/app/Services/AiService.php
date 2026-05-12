<?php

namespace App\Services;

use App\Ai\Agents\ImageAgent;
use Illuminate\Http\UploadedFile;
use Laravel\Ai\Enums\Lab;

class AiService
{
    public function __construct(private ImageAgent $imageAgent) {}

    public function inspectClothingFile(UploadedFile $file)
    {


            $response = $this->imageAgent
                ->prompt(
                    'Analyze the provided image and return a description of the image.',
                    attachments: [$file],
                    provider: Lab::Gemini,
                    model: 'gemini-3.1-flash-lite-preview'
                );

        return $response;
    }
}