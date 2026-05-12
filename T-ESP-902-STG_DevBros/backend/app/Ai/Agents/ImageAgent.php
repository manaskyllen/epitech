<?php

namespace App\Ai\Agents;

use Illuminate\Contracts\JsonSchema\JsonSchema;
use Laravel\Ai\Contracts\Agent;
use Laravel\Ai\Contracts\Conversational;
use Laravel\Ai\Contracts\HasStructuredOutput;
use Laravel\Ai\Contracts\HasTools;
use Laravel\Ai\Contracts\Tool;
use Laravel\Ai\Messages\Message;
use Laravel\Ai\Promptable;
use Stringable;

class ImageAgent implements Agent, Conversational, HasStructuredOutput, HasTools
{
    use Promptable;

    /**
     * Get the instructions that the agent should follow.
     */
    public function instructions(): Stringable|string
    {
        return 'You are role is to analyze the image provided and return a description of the image.';
    }

    /**
     * Get the list of messages comprising the conversation so far.
     *
     * @return Message[]
     */
    public function messages(): iterable
    {
        return [];
    }

    /**
     * Get the tools available to the agent.
     *
     * @return Tool[]
     */
    public function tools(): iterable
    {
        return [];
    }

    /**
     * Get the agent's structured output schema definition.
     */
    public function schema(JsonSchema $schema): array
    {
        return [
            'success' => $schema->boolean()->description('Whether the image analysis was successful.'),
            'validation' => $schema->object([
                'clothing_detected' => $schema->boolean()->description('Whether clothing was detected in the image.'),
                'confidence' => $schema->number()->description('The confidence level of the clothing detection.'),
                'bypassed' => $schema->boolean()->description('Whether the analysis was bypassed due to low confidence.'),
            ])->description('Validation details of the image analysis.'),
            'data' => $schema->object([
                'ItemType' => $schema->string()->enum(['top', 'bottom', 'accessories', 'shoes', 'Headwear'])->nullable()->description('The type of clothing item detected (e.g., Top, Bottom, Dress).'),
                'ItemSubtype' => $schema->string()->enum([[
                'T-shirt', 'Tank top', 'Blouse', 'Sweatshirt', 'Sweater', 'Cardigan',
                'Jeans', 'Pants', 'Shorts', 'Skirt', 'Leggings', 'Dress', 'Jumpsuit',
                'Jacket', 'Coat', 'Trench coat', 'Puffer jacket', 'Swimsuit',
                'Bra', 'Panties', 'Pajamas', 'Sneakers', 'Boots', 'Sandals',
                'Heels', 'Hat', 'Scarf', 'Belt', 'Bag'
            ]])->nullable()->description('The subtype of the clothing item (e.g., Sweater, Jeans).'),
                'Color' => $schema->array()->description('The color(s) of the clothing item detected.'),
                'Size' => $schema->string()->enum(['XS', 'S', 'M', 'L', 'XL', 'XXL'])->nullable()->description('The size of the clothing item detected.'),
                'Season' => $schema->string()->enum(['Spring', 'Summer', 'Autumn', 'Winter'])->nullable()->description('The season for which the clothing item is suitable (e.g., Autumn, Winter).'),
                'Gender' => $schema->string()->nullable()->description('The intended gender for the clothing item (e.g., Ladies, Gentlemen, Unisex).'),
                "Material" => $schema->string()->nullable()->description('The primary apparent material or texture of the clothing item (e.g., Denim, Leather, Knit, Silk, Cotton). Return null if the material cannot be reasonably guessed from the visual texture alone.'),
                "Style" => $schema->string()->nullable()->description('The style of the clothing item (e.g., Casual, Formal).'),
                'confidence' => $schema->number()->description('The confidence level of the clothing item analysis.'),
            ])->description('Data about the analyzed clothing item.'),

        ];
    }
}