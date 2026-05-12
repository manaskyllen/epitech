<?php

namespace App\Http\Controllers;

use Illuminate\Routing\Controller;
use Illuminate\Auth\Events\Verified;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;

/**
 * @group Email
 *
 * Endpoints for managing email.
 */
class EmailVerificationController extends Controller
{
    public function verify(Request $request, $id, $hash)
    {
        $user = User::findOrFail($id);

        if (! hash_equals((string) $hash, sha1($user->getEmailForVerification()))) {
            return response()->json(['message' => 'Lien de verification invalide.'], 400);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json(['message' => 'Utilisateur deja verifie.'], 200);
        }

        $user->markEmailAsVerified();

        event(new Verified($user));

        return response()->json(['message' => 'Utilisateur verifie.'], 201);
    }
}
