<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Http\UploadedFile;

class ClothingService
{
    private string $aiURL;

    public function __construct()
    {
        $this->aiURL = config('services.clothing.key') ?? '';
    }

    public function inspect(UploadedFile $file)
    {
        $response = Http::attach(
            'file',
            file_get_contents($file),
            $file->getClientOriginalName()
        )->withQueryParameters([
            'force_analysis' => true
        ])->post($this->aiURL);

        if ($response->failed()) return [];

        $data = $response->json();

        return [
            'itemType'    => strtolower($data['data']['ItemType'] ?? 'top'),
            'itemSubtype' => $data['data']['ItemSubtype'] ?? null,
            'size'        => $data['data']['Size'] ?? 'M',
            'color'       => $data['data']['Color'],
            'season'      => $data['data']['Season'] ?? 'autumn',
            'gender'      => $this->mapGender($data['data']['Gender'] ?? null),
            'texture'     => $data['data']['material'] ?? 'standard',
            'style'       => $data['data']['Style'] ?? 'casual',
        ];
    }

    private function mapGender($gender)
    {
        $map = [
            'Ladies' => 'female',
            'Men'    => 'male',
            'Unisex' => 'unisex'
        ];
        return $map[$gender] ?? 'unisex';
    }
}
