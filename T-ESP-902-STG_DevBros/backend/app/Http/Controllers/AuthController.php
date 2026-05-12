<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Notifications\SendOtpNotification;
use Carbon\Carbon;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Illuminate\Auth\Events\Registered;
use Illuminate\Support\Facades\Mail;

/**
 * @group Authentification
 * @unauthenticated
 * Endpoints for managing authentification.
 */
class AuthController extends Controller
{
    /**
     * @unauthenticated
     * @bodyParam firstname string required The user's first name.
     * @bodyParam lastname string required The user's last name.
     * @bodyParam email string required The user's email address.
     * @bodyParam password string required The user's password. Example: password12345
     * @bodyParam password_confirmation string required Confirmation of the user's password. Example: password12345
     * @bodyParam profilePictureUrl string nullable URL of the user's profile picture.
     * @bodyParam newsletter boolean nullable Whether the user wants to subscribe to the newsletter.
     **/
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'firstname' => 'required|string|max:255',
            'lastname' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:4|confirmed',
            'profilePictureUrl' => 'nullable|url',
            'newsletter' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::create([
            'firstname' => $request->firstname,
            'lastname' => $request->lastname,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'newsletter' => $request->newslette ?? false,
            'isActif' => false,
        ]);

        event(new Registered($user));

        return response()->json([
            'user' => $user,
        ], 201);
    }

    /**
     * @unauthenticated
     * @bodyParam email string required The user's email address.
     * @bodyParam password string required The user's password.
     **/
    public function login(Request $request)
    {
        $credentials = $request->only('email', 'password');

        $user = User::where('email', $credentials['email'])->first();

        if (!$user) { 
            return response()->json(['message' => 'Utilisateur inexistant'], 404);
        }

        if (!Auth::attempt($credentials)) {
            return response()->json(['message' => 'Identifiants incorrects'], 401);
        }

        if (!$user->isActif) {
            return response()->json(['message' => 'Compte inactif.'], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ], 200);
    }

    /**
     * @unauthenticated
     * @bodyParam email string required The user's email address.
     **/
    public function forgetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['error' => 'Email not found'], 404);
        }

        $otp = rand(100000, 999999);

        $user->update([
            'otp' => $otp,
            'otpGeneratedAt' => now(),
        ]);

        $user->notify(new SendOtpNotification($otp));

        return response()->json(['message' => 'OTP sent to your email'], 200);
    }

    /**
     * @unauthenticated
     * @bodyParam email string required The user's email address.
     * @bodyParam otp integer required The OTP sent to the user's email.
     **/
    public function sendOtp(User $user)
    {

        $otp = rand(100000, 999999);
        $user->update(['otp' => $otp]);
        $user->update(['otpGeneratedAt' => now()]);

        return $otp;
    }

    /**
     * @unauthenticated
     * @bodyParam email string required The user's email address.
     * @bodyParam otp integer required The OTP sent to the user's email.
     **/
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|digits:6',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['error' => 'Email not found'], 404);
        }

        if ($user->otpGeneratedAt && Carbon::parse($user->otpGeneratedAt)->diffInMinutes(now()) > 1) {
            return response()->json(['error' => 'OTP expired'], 400);
        }

        if ($user->otp != $request->otp) {
            return response()->json(['error' => 'Invalid OTP'], 400);
        }

        $user->update([
            'otp' => null,
            'otpGeneratedAt' => null,
            'email_verified_at' => now(),
            'isActif' => true,
        ]);

        return response()->json(['message' => 'OTP verified successfully'], 200);
    }

    public function passwordResetVerifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|digits:6',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['error' => 'Email not found'], 404);
        }

        if ($user->otpGeneratedAt && Carbon::parse($user->otpGeneratedAt)->diffInMinutes(now()) > 2) {
            return response()->json(['error' => 'OTP expired'], 400);
        }

        if ($user->otp != $request->otp) {
            return response()->json(['error' => 'Invalid OTP'], 400);
        }

        return response()->json(['message' => 'OTP verified successfully'], 200);
    }

    /**
     * @unauthenticated
     * @bodyParam email string required The user's email address.
     * @bodyParam otp integer required The OTP sent to the user's email.
     * @bodyParam password string required The new password.
     * @bodyParam password_confirmation string required Confirmation of the new password.
     **/
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|digits:6',
            'password' => 'required|min:8|confirmed',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['error' => 'Email not found'], 404);
        }

        if ($user->otpGeneratedAt && Carbon::parse($user->otpGeneratedAt)->diffInMinutes(now()) > 2) {
            $user->otp = null; // Clear the OTP
            $user->otpGeneratedAt = null; // Clear the OTP generated timestamp
            $user->save();
            return response()->json(['error' => 'OTP expired'], 400);
        }

        if ($user->otp != $request->otp) {
            return response()->json(['error' => 'Invalid OTP'], 400);
        }

        $user->password = bcrypt($request->password);
        $user->otp = null; // Clear the OTP
        $user->otpGeneratedAt = null; // Clear the OTP generated timestamp
        $user->save();

        return response()->json(['message' => 'Password reset successful'], 200);
    }

    public function me(Request $request)
    {
        return response()->json($request->user(), 200);
    }
}
