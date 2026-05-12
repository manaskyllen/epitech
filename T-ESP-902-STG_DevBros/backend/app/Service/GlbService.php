<?php

namespace App\Service;

use Illuminate\Routing\Controller;


class GlbService extends Controller
{
    public function parseGlbFile($data)
    {
        // Vérifier l’entête GLB
        if (substr($data, 0, 4) !== "glTF") {
            return null;
        }

        // Taille du chunk JSON (octets 12 → 15)
        $jsonLength = unpack("V", substr($data, 12, 4))[1];

        // Le JSON commence à l’offset 20
        $json = substr($data, 20, $jsonLength);

        // Décodage du JSON interne
        $parsed = json_decode($json, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            return null;
        }

        if (!isset($parsed['nodes']) || !isset($parsed['materials'])) {
            return null;
        }

        $modelName = $parsed['nodes'][0]['name'] ?? 'unknown_name';
        $defaultTexture = $parsed['materials'][0]['name'] ?? 'unknown_texture';

        if($modelName == 'unknown_name' || $defaultTexture == 'unknown_texture') {
            return null;
        }

        return [
            'name' => $modelName,
            'texture' => $defaultTexture,
            'parsed' => $parsed
        ];
    }
}
