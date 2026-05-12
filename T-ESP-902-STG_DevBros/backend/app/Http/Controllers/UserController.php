<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

/**
 * @group Users
 *
 * Endpoints for managing users.
 */
class UserController extends Controller
{
    public function index()
    {
        $users = User::all();

        if ($users->isEmpty()) {
            return response()->json(['message' => 'No users found'], 404);
        }

        return response()->json($users, 200);
    }

    public function show($id)
    {
        $user = User::find($id);

        if (empty($user)) {
            return response()->json(['message' => 'User not found'], 404);
        }

        return response()->json($user, 200);
    }

    public function store(Request $request)
    {
         $request->validate([
            'firstname' => 'required|string|max:255',
            'lastname' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email|max:255',
            'profilePictureUrl' => 'nullable|url|max:255',
            'sso' => 'nullable|string|max:255',
            'password' => 'required|string|min:8|confirmed',
            'isActif' => 'nullable|boolean',
            'newsletter' => 'nullable|boolean',
        ]);

        $user = User::create($request->all());

        return response()->json($user, 201);
    }

    public function update(Request $request, $id)
    {
         $user = User::find($id);

        if (empty($user)) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $request->validate([
            'firstname' => 'sometimes|required|string|max:255',
            'lastname' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|unique:users,email|max:255',
            'profilePictureUrl' => 'sometimes|nullable|url|max:255',
            'password' => 'sometimes|required|string|min:8|confirmed',
            'sso' => 'sometimes|nullable|string|max:255',
            'isActif' => 'sometimes|nullable|boolean',
            'newsletter' => 'sometimes|nullable|boolean',
        ]);

        $user->update($request->all());

        return response()->json($user);
    }

    public function destroy($id)
    {
        $user = User::find($id);

        if (empty($user)) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $user->delete();

        return response()->json(['message' => 'User deleted successfully'], 204);
    }
}
