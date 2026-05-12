<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Throwable;

/**
 * @group Minio
 * Endpoints for managing minio.    
 */
class MinioController
{
   public function upload(Request $request)
    {
        $request->validate([
            'file' => 'required|file',
        ]);

        $file = $request->file('file');
        $path = Storage::disk('minio')->put('', $file);

        return response()->json([
            'code' => 201,
            'message' => 'File uploaded successfully',
            'path' => $path,
        ]);
    }

    public function get($filename)
    {
        return $this->streamMinioPath($filename, $filename);
    }

    public function stream(string $path)
    {
        return $this->streamMinioPath($path, basename($path));
    }

    private function streamMinioPath(string $path, string $downloadName)
    {
        try {
            $fileContent = Storage::disk('minio')->get($path);
        } catch (Throwable) {
            return response()->json(['message' => 'File not found'], 404);
        }

        try {
            $mimeType = Storage::disk('minio')->mimeType($path);
        } catch (Throwable) {
            $mimeType = 'application/octet-stream';
        }

        return response($fileContent, 200)
            ->header('Content-Type', $mimeType)
            ->header('Content-Disposition', 'inline; filename="' . $downloadName . '"');
    }
}
