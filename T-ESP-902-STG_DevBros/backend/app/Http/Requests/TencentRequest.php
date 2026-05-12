<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Validation\Rule;

class TencentRequest extends FormRequest
{
    private const ITEM_TYPES = [
        'top',
        'bottom',
        'accessories',
        'shoes',
        'Headwear',
    ];

    private const ITEM_SUBTYPES = [
        'T-shirt',
        'Tank top',
        'Blouse',
        'Sweatshirt',
        'Sweater',
        'Cardigan',
        'Jeans',
        'Pants',
        'Shorts',
        'Skirt',
        'Leggings',
        'Dress',
        'Jumpsuit',
        'Jacket',
        'Coat',
        'Trench coat',
        'Puffer jacket',
        'Swimsuit',
        'Bra',
        'Panties',
        'Pajamas',
        'Sneakers',
        'Boots',
        'Sandals',
        'Heels',
        'Hat',
        'Scarf',
        'Belt',
        'Bag',
    ];

    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'itemType' => is_string($this->itemType) ? trim($this->itemType) : $this->itemType,
            'itemSubtype' => is_string($this->itemSubtype) ? trim($this->itemSubtype) : $this->itemSubtype,
        ]);
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'itemType' => ['required', 'string', 'max:255', Rule::in(self::ITEM_TYPES)],
            'itemSubtype' => ['required', 'string', 'max:255', Rule::in(self::ITEM_SUBTYPES)],
            'user_id' => 'required|exists:users,id',
            'file' => 'required|file',
            'size' => 'sometimes|integer|min:128|max:4096',
            'direction' => ['sometimes', 'string', Rule::in(['vertical', 'horizontal', 'diagonal', 'radial'])],
            'palette_size' => 'sometimes|integer|min:2|max:12',
            'noise' => 'sometimes|numeric|min:0|max:1',
            'detail_strength' => 'sometimes|numeric|min:0|max:2',
            'gradient_strength' => 'sometimes|numeric|min:0|max:1',
            'seed' => 'sometimes|integer',
            'color' => ['sometimes', 'string', 'regex:/^#?[0-9A-Fa-f]{6}$/'],
            'front_color' => ['sometimes', 'string', 'regex:/^#?[0-9A-Fa-f]{6}$/'],
        ];
    }

    protected function failedValidation(Validator $validator): void
    {
        $file = $this->file('file');

        throw new HttpResponseException(response()->json([
            'message' => 'Tencent request validation failed',
            'error_code' => 'VALIDATION_ERROR',
            'errors' => $validator->errors(),
            'received' => [
                'itemType' => $this->input('itemType'),
                'itemSubtype' => $this->input('itemSubtype'),
                'user_id' => $this->input('user_id'),
                'size' => $this->input('size'),
                'direction' => $this->input('direction'),
                'palette_size' => $this->input('palette_size'),
                'noise' => $this->input('noise'),
                'detail_strength' => $this->input('detail_strength'),
                'gradient_strength' => $this->input('gradient_strength'),
                'seed' => $this->input('seed'),
                'content_type' => $this->header('Content-Type'),
                'has_file' => $this->hasFile('file'),
                'file_name' => $file?->getClientOriginalName(),
                'file_mime' => $file?->getMimeType(),
                'file_size' => $file?->getSize(),
            ],
        ], 422));
    }
}
