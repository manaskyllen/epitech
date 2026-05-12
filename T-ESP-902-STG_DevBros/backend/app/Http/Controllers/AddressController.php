<?php

namespace App\Http\Controllers;

use Illuminate\Routing\Controller;
use App\Models\Address;
use App\Models\User;
use Illuminate\Http\Request;


/**
 * @group Addresses
 *
 * Endpoints for managing addresses.
 */
class AddressController extends Controller
{
    public function index()
    {
        $address = Address::all();

        if ($address->isEmpty()) {
            return response()->json(['message' => 'No address found'], 404);
        }

        return response()->json($address, 200);
    }

    public function show($id) 
    {
        $address = Address::find($id);

        if (empty($address)) {
            return response()->json(['message' => 'Address not found'], 404);
        }

        return response()->json($address, 200);
    }

    public function getAddressByUserId($userId)
    {
        $user = User::find($userId);

        if (empty($user)) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $address = $user->addresses;

        if ($address->isEmpty()) {
            return response()->json(['message' => 'No address found for this user'], 404);
        }

        return response()->json($address, 200);
    }

    public function store(Request $request)
    {
        $request->validate([
            'street1' => 'required|string|max:255',
            'street2' => 'nullable|string|max:255',
            'city' => 'required|string|max:255',
            'zipCode' => 'required|string|max:20',
            'country' => 'required|string|max:100',
            'user_id' => 'required|exists:users,id',
        ]);

        $address = Address::create($request->all());

        return response()->json($address, 201);
    }

    public function update(Request $request, $id)
    {
        $address = Address::find($id);

        if (empty($address)) {
            return response()->json(['message' => 'Address not found'], 404);
        }

        $request->validate([
            'street1' => 'sometimes|required|string|max:255',
            'street2' => 'sometimes|nullable|string|max:255',
            'city' => 'sometimes|required|string|max:255',
            'zipCode' => 'sometimes|required|string|max:20',
            'country' => 'sometimes|required|string|max:100',
            'user_id' => 'sometimes|required|exists:users,id',
        ]);

        $address->update($request->all());

        return response()->json($address, 200);
    }

    public function destroy($id)
    {
        $address = Address::find($id);

        if (empty($address)) {
            return response()->json(['message' => 'Address not found'], 404);
        }

        $address->delete();

        return response()->json(['message' => 'Address deleted successfully'], 204);
    }
}
