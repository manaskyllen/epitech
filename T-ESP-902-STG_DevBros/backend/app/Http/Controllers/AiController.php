<?php

namespace App\Http\Controllers;

use App\Services\AiService;
use Illuminate\Http\Request;

class AiController
{
    public function __construct(private AiService $aiService) {}
    public function analyzeClothingImage(Request $request)
    {
        $request->validate([
            'file' => 'required|file|mimes:jpeg,png,jpg,gif,webp|max:5120',
        ]);

        $file = $request->file('file');

        $response = $this->aiService->inspectClothingFile($file);

        return response()->json($response);
    }
}
